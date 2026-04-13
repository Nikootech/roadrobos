import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';
import 'features/rentals/rental_providers.dart';
import 'shared/widgets/rental_completion_dialog.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notification_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter/foundation.dart';
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wrap the app in runZonedGuarded to catch async errors and ensure consistent zone usage
  runZonedGuarded(
    () async {
      // Load environment variables
      await dotenv.load(fileName: ".env");

      // Initialize Firebase (Keep for Messaging/Crashlytics)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Supabase (Primary Database & Auth)
      await Supabase.initialize(
        url: dotenv.get('SUPABASE_URL'),
        anonKey: dotenv.get('SUPABASE_ANON_KEY'),
      );

      // Initialize Notifications
      final notificationService = NotificationService();
      await notificationService.initialize();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Pass all uncaught errors to Crashlytics
      FlutterError.onError = (errorDetails) {
        if (kIsWeb) {
          debugPrint('Web Error: ${errorDetails.exception}');
        } else {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        }
      };

      runApp(const ProviderScope(child: RoadRobosApp()));
    },
    (error, stack) {
      if (kIsWeb) {
        debugPrint('Web Zoned Error: $error\n$stack');
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
    // Global listener for rental completion
    ref.listen(activeRentalProvider, (previous, next) {
      if (next?.status == RentalStatus.completed && previous?.status != RentalStatus.completed) {
        _showCompletionDialog(context, ref, next!.vehicle['name'] ?? 'Vehicle');
      }
    });

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'RoAdRoBos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
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
