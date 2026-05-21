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
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    }

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
      if (kIsWeb) {
        // Safe-guard: VAPID key is required on Web for getToken()
        token = await _fcm.getToken();
      } else {
        token = await _fcm.getToken();
      }
      debugPrint('FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('FCM Token Error: $e');
      return null;
    }
  }

  /// Sync the FCM token to the user's profile in Supabase
  Future<void> syncTokenToBackend(String uid) async {
    if (uid.isEmpty) return;
    
    try {
      final token = await getToken();
      if (token != null) {
        // We use a low-level Supabase call or a repository here
        // For clean architecture, we'll assume the caller passes the repository or we use a static update
        await Supabase.instance.client
            .from('profiles')
            .update({'fcm_token': token})
            .eq('id', uid);
        debugPrint('FCM Token synced for user: $uid');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('FCM Token Sync Failure: $e');
      } else if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: 'FCM token sync failed for user: $uid');
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
      showWhen: true,
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
    print("Handling a background message: ${message.messageId}");
  }
}

