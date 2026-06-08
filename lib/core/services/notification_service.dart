import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart' show scaffoldMessengerKey, navigatorKey;
import '../theme/app_colors.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    // Permissions are no longer requested automatically on app launch.
    // They must be explicitly requested via requestNotificationPermission()
    // during onboarding or after login to comply with Android/Web best practices.

    // 2. Local Notifications Setup (for foreground alerts)
    if (!kIsWeb) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);
      await _localNotifications.initialize(initializationSettings);
    }

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!kIsWeb) {
        _showLocalNotification(message);
      } else {
        debugPrint('Foreground Message: ${message.notification?.title}');
      }
    });

    // 4. Handle Background Messages (Open App)
    FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationNavigation);

    // 5. Handle Cold Start
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        handleNotificationNavigation(initialMessage);
      });
    }

    // 6. Handle Token Refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          await Supabase.instance.client.from('profiles').update({'fcm_token': newToken}).eq('id', user.id);
        } catch (_) {}
        try {
          await Supabase.instance.client.from('drivers').update({'fcm_token': newToken}).eq('id', user.id);
        } catch (_) {}
      }
    });
  }

  Future<bool> requestNotificationPermission() async {
    final NotificationSettings settings = await _fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        debugPrint('User granted notification permission');
      }
      return true;
    } else {
      if (kDebugMode) {
        debugPrint('User declined or has not accepted notification permissions');
      }
      return false;
    }
  }

  void handleNotificationNavigation(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final id = message.data['id'] as String?;
    
    final context = navigatorKey.currentContext;
    if (context == null || type == null) return;

    switch (type) {
      case 'ride_request':
        context.push('/taxi/home');
        break;
      case 'booking_update':
        context.push('/main/bookings');
        break;
      case 'payment_success':
        context.push('/wallet');
        break;
      case 'kyc_approved':
        context.push('/account-settings');
        break;
      case 'chat_message':
        final roomId = id ?? 'default_room';
        context.push('/chat/$roomId');
        break;
    }
  }

  Future<String?> getToken() async {
    String? token;
    try {
      token = await _fcm.getToken();
      // ✅ Never log the actual token — only its length for debug confirmation
      if (kDebugMode) {
        debugPrint('FCM Token obtained. Length: ${token?.length ?? 0} chars.');
      }
      return token;
    } catch (e) {
      if (kDebugMode) debugPrint('FCM Token Error: $e');
      return null;
    }
  }

  Future<void> syncTokenToBackend(String uid) async {
    if (uid.isEmpty) return;
    try {
      final token = await getToken();
      if (token != null) {
        try {
          await Supabase.instance.client
              .from('profiles')
              .update({'fcm_token': token})
              .eq('id', uid);
        } catch (_) {}
        try {
          await Supabase.instance.client
              .from('drivers')
              .update({'fcm_token': token})
              .eq('id', uid);
        } catch (_) {}
        // ✅ Never log UID or token — only confirm success
        if (kDebugMode) debugPrint('FCM Token synced successfully.');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('FCM Token Sync Failure: $e');
      } else if (!kIsWeb) {
        // ignore: unawaited_futures
        FirebaseCrashlytics.instance.recordError(
          e, stack,
          reason: 'FCM token sync failed',
          // ✅ Never include uid in Crashlytics metadata
        );
      }
    }
  }

  void showError(String title, {String? message, dynamic error, StackTrace? stackTrace}) {
    // 1. Log to Crashlytics
    if (!kIsWeb) {
      FirebaseCrashlytics.instance.recordError(
        error ?? title,
        stackTrace,
        reason: title,
      );
    } else {
      debugPrint('Web Error: $title - $error');
    }

    // 2. Show Premium SnackBar
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.dangerRed,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.dangerRed.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Iconsax.warning_2, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (message != null)
                      Text(
                        message,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    
    _localNotifications.show(
      0,
      message.notification?.title ?? 'New Update',
      message.notification?.body ?? 'Touch to view',
      platformDetails,
    );
  }
}

// Background handler must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}

