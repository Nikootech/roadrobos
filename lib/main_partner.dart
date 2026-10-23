import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';
import 'core/config/app_config.dart';
import 'core/config/app_flavor.dart';
import 'app_partner.dart';
import 'navigation/partner_router.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'core/security/jailbreak_guard.dart';
import 'core/utils/app_debugger.dart';
import 'shared/widgets/startup_error_app.dart';
import 'core/services/background_service.dart';
import 'core/theme/system_ui_service.dart';
import 'core/network/supabase_http_client.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    partnerScaffoldMessengerKey;
final GlobalKey<NavigatorState> navigatorKey = partnerRootNavigatorKey;

// Top-level FCM background handler for partner app
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    debugPrint('Partner FCM Background message received.');
  }
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      AppFlavor.setOverride(AppFlavor.partner);
      await initializeBackgroundService();
      SystemUiService.configureEdgeToEdge();

      SharedPreferences? prefs;
      bool isCompromised = false;
      String? criticalError;

      // 1. Initialize AppConfig
      try {
        AppDebugger.logStep('AppConfig', 'Initializing Partner App...');
        AppConfig.init();
        AppDebugger.logStep('AppConfig', 'SUCCESS');
      } catch (e) {
        criticalError = 'Config initialization failed: $e';
        AppDebugger.logStep('AppConfig', 'FAILED', error: e.toString());
      }

      if (kDebugMode) {
        AppDebugger.run();
      }

      if (criticalError == null) {
        // 2. Initialize SharedPreferences
        try {
          AppDebugger.logStep('SharedPreferences', 'Initializing...');
          prefs = await SharedPreferences.getInstance()
              .timeout(const Duration(seconds: 3));
          AppDebugger.logStep('SharedPreferences', 'SUCCESS');
        } catch (e) {
          criticalError = 'Failed to load SharedPreferences: $e';
          AppDebugger.logStep('SharedPreferences', 'FAILED', error: e.toString());
        }

        // 3. Initialize Jailbreak Guard
        try {
          AppDebugger.logStep('Jailbreak Guard', 'Initializing...');
          isCompromised =
              await JailbreakGuard.check().timeout(const Duration(seconds: 2));
          AppDebugger.logStep('Jailbreak Guard', 'SUCCESS');
        } catch (e) {
          AppDebugger.logStep('Jailbreak Guard', 'FAILED', error: e.toString());
        }
      }

      if (criticalError == null) {
        // 4. Initialize Firebase & Supabase in parallel
        await Future.wait([
          (() async {
            try {
              AppDebugger.logStep('Firebase', 'Initializing...');
              await Firebase.initializeApp(
                      options: DefaultFirebaseOptions.currentPlatform)
                  .timeout(const Duration(seconds: 4));
              AppDebugger.logStep('Firebase', 'SUCCESS');
            } catch (e) {
              AppDebugger.logStep('Firebase', 'FAILED', error: e.toString());
            }
          })(),
          (() async {
            try {
              AppDebugger.logStep('Supabase', 'Initializing...');
              if (AppConfig.supabaseUrl.isEmpty ||
                  AppConfig.supabaseAnonKey.isEmpty) {
                throw ArgumentError(
                    'Supabase URL or Anon Key is empty. Check .dart_defines');
              }
              await Supabase.initialize(
                url: AppConfig.supabaseUrl,
                anonKey: AppConfig.supabaseAnonKey,
                httpClient: SupabaseHttpClient(),
                debug: kDebugMode,
              ).timeout(const Duration(seconds: 15));
              AppDebugger.logStep('Supabase', 'SUCCESS');
            } catch (e) {
              AppDebugger.logStep('Supabase', 'FAILED', error: e.toString());
            }
          })(),
        ]);
      }

      if (criticalError != null) {
        runApp(StartupErrorApp(
          errorMessage: criticalError,
          onRetry: () {
            main();
          },
        ));
        return;
      }

      // Launch App with Partner Flavor
      final prefsValue = prefs!;
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefsValue),
          jailbreakProvider.overrideWithValue(isCompromised),
          appFlavorProvider.overrideWithValue(AppFlavor.partner),
        ],
      );

      const sentryDsn = AppConfig.sentryDsn;
      if (sentryDsn.isNotEmpty) {
        await SentryFlutter.init(
          (options) {
            options.dsn = sentryDsn;
            options.tracesSampleRate = kDebugMode ? 1.0 : 0.2;
          },
          appRunner: () => runApp(UncontrolledProviderScope(
            container: container,
            child: const PartnerApp(),
          )),
        );
      } else {
        if (kDebugMode) debugPrint('Sentry disabled: SENTRY_DSN is not set.');
        runApp(UncontrolledProviderScope(
          container: container,
          child: const PartnerApp(),
        ));
      }

      // Deferred post-frame tasks
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PaintingBinding.instance.imageCache.maximumSize = 100;
        PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;

        FlutterError.onError = (FlutterErrorDetails details) {
          Sentry.captureException(details.exception, stackTrace: details.stack);
          if (!kDebugMode && !kIsWeb) {
            FirebaseCrashlytics.instance.recordFlutterFatalError(details);
          } else {
            FlutterError.presentError(details);
          }
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          Sentry.captureException(error, stackTrace: stack);
          if (!kDebugMode && !kIsWeb) {
            FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
          }
          return false;
        };

        if (!kIsWeb) {
          FirebaseMessaging.onBackgroundMessage(
              _firebaseMessagingBackgroundHandler);
        }

        unawaited(
          container.read(notificationServiceProvider).initialize().then((_) {
            return container
                .read(notificationServiceProvider)
                .requestNotificationPermission();
          }).catchError((e) {
            if (kDebugMode) {
              debugPrint('NotificationService init error: $e');
            }
            return false;
          }),
        );
      });
    },
    (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      if (!kDebugMode && !kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } else {
        debugPrint('Uncaught Partner App error: $error\n$stack');
      }
    },
  );
}
