import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'navigation/app_router.dart';
import 'features/rentals/rental_providers.dart';
import 'shared/widgets/rental_completion_dialog.dart';
import 'shared/widgets/error_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/favorites_provider.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  // Catch errors and ensure consistent zone usage
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // 0. Initialize App Configuration
      AppConfig.init();
      
      // 1. Initialize Firebase and Supabase sequentially
      try {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
        if (kDebugMode) debugPrint('Firebase Initialized Successfully');
      } catch (e) {
        if (kDebugMode) debugPrint('Firebase Init Error: $e');
      }

      try {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
          debug: kDebugMode,
        );
        if (kDebugMode) debugPrint('Supabase Initialized Successfully');
      } catch (e) {
        if (kDebugMode) debugPrint('Supabase Init Error: $e');
      }

      // 3. Setup Error Handlers
      FlutterError.onError = (FlutterErrorDetails details) {
        // Filter out known non-fatal Web warnings
        final errorStr = details.exception.toString();
        if (kIsWeb && errorStr.contains('the `web` parameter needs to be set')) {
          if (kDebugMode) debugPrint('Ignored Non-Fatal Web Warning: $errorStr');
          return;
        }
        
        if (!kDebugMode) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        } else {
          FlutterError.presentError(details);
        }
      };

      // Initialize Notifications (Non-blocking)
      NotificationService().initialize().catchError((e) {
        if (kDebugMode) debugPrint('Notification Initialization Error: $e');
      });

      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }
      
      final prefs = await SharedPreferences.getInstance();

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const RoadRobosApp(),
        ),
      );
    },
    (error, stack) {
      if (kIsWeb) {
        if (kDebugMode) debugPrint('Web Zoned Error: $error\n$stack');
      } else {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
    },
  );
}

class RoadRobosApp extends ConsumerWidget {
  const RoadRobosApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Global listener for rental completion
    ref.listen(activeRentalProvider, (previous, next) {
      if (next?.status == RentalStatus.completed && previous?.status != RentalStatus.completed) {
        // Ensure the navigator is ready and mounted before showing a dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = rootNavigatorKey.currentContext;
          if (context != null && context.mounted) {
            _showCompletionDialog(context, ref, next!.vehicle['name'] ?? 'Vehicle');
          }
        });
      }
    });

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'RoAdRoBos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      builder: (context, child) {
        // Global Error Boundary for the Widget Tree
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return GlobalErrorScreen(errorDetails: errorDetails);
        };
        return child!;
      },
    );
  }

  void _showCompletionDialog(BuildContext context, WidgetRef ref, String vehicleName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RentalCompletionDialog(
        vehicleName: vehicleName,
        onCompletePayment: () {
          // Fix: Pass required totalCost. For demo completion, we use a default.
          ref.read(activeRentalProvider.notifier).completePayment(totalCost: 1500.0);
          Navigator.pop(context);
        },
        onReschedule: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
