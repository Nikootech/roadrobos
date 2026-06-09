import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'navigation/app_router.dart';
import 'features/rentals/rental_providers.dart';
import 'shared/widgets/rental_completion_dialog.dart';
import 'shared/widgets/error_screen.dart';
import 'core/providers/favorites_provider.dart';
import 'core/services/notification_service.dart';
import 'core/services/payment_service.dart';
import 'core/security/jailbreak_guard.dart';
import 'core/security/encrypted_column.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/utils/app_debugger.dart';
import 'shared/widgets/startup_error_app.dart';

import 'package:flutter/foundation.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = rootNavigatorKey;

// ── Top-level FCM background handler (must be top-level function) ────────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Intentionally minimal — no complex logic in background isolate
  if (kDebugMode) {
    debugPrint('FCM Background message received.');
  }
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SharedPreferences? prefs;
      bool isCompromised = false;
      String? criticalError;

      // 1. Initialize AppConfig
      try {
        AppDebugger.logStep('AppConfig', 'Initializing...');
        AppConfig.init();
        AppDebugger.logStep('AppConfig', 'SUCCESS');
      } catch (e) {
        criticalError = 'Config initialization failed: $e';
        AppDebugger.logStep('AppConfig', 'FAILED', error: e.toString());
      }

      // ── DEBUG DIAGNOSTICS (debug mode only) ─────────────────────────────────
      if (kDebugMode) {
        AppDebugger.run();
        AppDebugger.printKnownIssues();
      }

      if (criticalError == null) {
        // 2. Initialize SharedPreferences (Critical)
        try {
          AppDebugger.logStep('SharedPreferences', 'Initializing...');
          prefs = await SharedPreferences.getInstance().timeout(const Duration(seconds: 3));
          AppDebugger.logStep('SharedPreferences', 'SUCCESS');
        } catch (e) {
          criticalError = 'Failed to load SharedPreferences: $e';
          AppDebugger.logStep('SharedPreferences', 'FAILED', error: e.toString());
        }

        // 3. Initialize Jailbreak Guard (Non-critical)
        try {
          AppDebugger.logStep('Jailbreak Guard', 'Initializing...');
          isCompromised = await JailbreakGuard.check().timeout(const Duration(seconds: 2));
          AppDebugger.logStep('Jailbreak Guard', 'SUCCESS');
        } catch (e) {
          AppDebugger.logStep('Jailbreak Guard', 'FAILED', error: e.toString());
        }
      }

      if (criticalError == null) {
        // 4. Initialize other integrations in parallel with individual safety bounds
        await Future.wait([
          (() async {
            try {
              AppDebugger.logStep('Firebase', 'Initializing...');
              await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
                  .timeout(const Duration(seconds: 4));
              AppDebugger.logStep('Firebase', 'SUCCESS');
            } catch (e) {
              AppDebugger.logStep('Firebase', 'FAILED', error: e.toString());
            }
          })(),
          (() async {
            try {
              AppDebugger.logStep('Supabase', 'Initializing...');
              if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
                throw ArgumentError('Supabase URL or Anon Key is empty. Check .dart_defines');
              }
              await Supabase.initialize(
                url: AppConfig.supabaseUrl,
                anonKey: AppConfig.supabaseAnonKey,
                debug: kDebugMode,
              ).timeout(const Duration(seconds: 4));
              AppDebugger.logStep('Supabase', 'SUCCESS');
            } catch (e) {
              AppDebugger.logStep('Supabase', 'FAILED', error: e.toString());
              // Fallback initialization to construct a valid client singleton
              // and prevent crashes when other services read Supabase.instance.client
              try {
                await Supabase.initialize(
                  url: 'https://placeholder.supabase.co',
                  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsYWNlaG9sZGVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNDc1NzMsImV4cCI6MjA5MTYyMzU3M30.VuJ13qv1rEyJyfdAvpCI_qUvPSQPcZqbluLWWo4loBM',
                  debug: kDebugMode,
                );
              } catch (_) {}
            }
          })(),
          (() async {
            try {
              AppDebugger.logStep('Encryption Key', 'Initializing...');
              await ColumnEncryptionKey.prefetch().timeout(const Duration(seconds: 2));
              AppDebugger.logStep('Encryption Key', 'SUCCESS');
            } catch (e) {
              AppDebugger.logStep('Encryption Key', 'FAILED', error: e.toString());
            }
          })(),
        ]);
      }

      // If we have a critical error, run the diagnostic error screen
      if (criticalError != null) {
        runApp(StartupErrorApp(
          errorMessage: criticalError,
          onRetry: () {
            main();
          },
        ));
        return;
      }

      // ── LAUNCH APP ──────────────────────────────────────────────────────────
      final prefsValue = prefs!;
      const sentryDsn = AppConfig.sentryDsn;
      if (sentryDsn.isNotEmpty) {
        await SentryFlutter.init(
          (options) {
            options.dsn = sentryDsn;
            options.tracesSampleRate = 1.0;
          },
          appRunner: () => runApp(ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefsValue),
              jailbreakProvider.overrideWithValue(isCompromised),
            ],
            child: const RoadRobosApp(),
          )),
        );
      } else {
        if (kDebugMode) debugPrint('Sentry disabled: SENTRY_DSN is not set.');
        runApp(ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefsValue),
            jailbreakProvider.overrideWithValue(isCompromised),
          ],
          child: const RoadRobosApp(),
        ));
      }

      // ── POST-FRAME DEFERRED SETUP ───────────────────────────────────────────
      // Nothing here blocks the first render. All heavy setup is deferred.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ① Sentry & Crashlytics error handlers
        FlutterError.onError = (FlutterErrorDetails details) {
          Sentry.captureException(details.exception, stackTrace: details.stack);
          final errorStr = details.exception.toString();
          if (kIsWeb &&
              errorStr.contains('the `web` parameter needs to be set')) {
            return; // known non-fatal web warning
          }
          if (!kDebugMode) {
            FirebaseCrashlytics.instance.recordFlutterFatalError(details);
          } else {
            FlutterError.presentError(details);
          }
        };

        PlatformDispatcher.instance.onError = (error, stack) {
          Sentry.captureException(error, stackTrace: stack);
          if (!kDebugMode) {
            FirebaseCrashlytics.instance
                .recordError(error, stack, fatal: true);
          }
          return false;
        };

        // ② FCM background handler (must register before any token fetch)
        if (!kIsWeb) {
          FirebaseMessaging.onBackgroundMessage(
              _firebaseMessagingBackgroundHandler);
        }

        // ③ Notification service (non-blocking)
        unawaited(
          NotificationService().initialize().then((_) {
            // Request permission on app start (critical for Android 13+)
            return NotificationService().requestNotificationPermission();
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
      // Zone-level uncaught error handler
      Sentry.captureException(error, stackTrace: stack);
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } else {
        debugPrint('Uncaught error: $error\n$stack');
      }
    },
  );
}

// ── App widget ────────────────────────────────────────────────────────────────

class RoadRobosApp extends ConsumerWidget {
  const RoadRobosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Global listener for rental completion dialog
    ref.listen(activeRentalProvider, (previous, next) {
      if (next?.status == RentalStatus.completed &&
          previous?.status != RentalStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = rootNavigatorKey.currentContext;
          if (ctx != null && ctx.mounted) {
            _showCompletionDialog(ctx, ref, next!.vehicle['name'] ?? 'Vehicle');
          }
        });
      }
    });

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'RoadRobos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails details) =>
            GlobalErrorScreen(errorDetails: details);
        return child!;
      },
    );
  }

  void _showCompletionDialog(
      BuildContext context, WidgetRef ref, String vehicleName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RentalCompletionDialog(
        vehicleName: vehicleName,
        onCompletePayment: () async {
          final activeRental = ref.read(activeRentalProvider);
          if (activeRental == null) return;
          final priceStr =
              activeRental.vehicle['price']?.toString() ?? '150';
          final hourly = double.tryParse(
                  priceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              150.0;
          final totalCost = hourly *
              (activeRental.duration.inHours > 0
                  ? activeRental.duration.inHours
                  : 1);
          final paymentService =
              ref.read(paymentServiceProvider.notifier);
          try {
            await ref.read(activeRentalProvider.notifier).completePayment(
                  totalCost: totalCost,
                  paymentService: paymentService,
                );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            if (kDebugMode) debugPrint('Payment failed: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          }
        },
        onReschedule: () => Navigator.pop(context),
      ),
    );
  }
}
