import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../main.dart' show scaffoldMessengerKey, navigatorKey;
import '../../navigation/nav_helpers.dart';

// ── Abstract interface ────────────────────────────────────────────────────────
// Allows mock injection in widget and integration tests.

abstract class INotificationService {
  Future<void> initialize();
  Future<bool> requestNotificationPermission();
  void handleNotificationNavigation(RemoteMessage message);
  Future<String?> getToken();
  Future<void> syncTokenToBackend(String uid);
  void showError(String title,
      {String? message, dynamic error, StackTrace? stackTrace});
}

// ── Riverpod provider ─────────────────────────────────────────────────────────
// Riverpod fully controls the lifecycle. No singleton pattern — every test
// can inject a MockNotificationService via ProviderScope overrides.

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref);
});

// ── Implementation ────────────────────────────────────────────────────────────

class NotificationService implements INotificationService {
  /// Constructor accepts Ref to satisfy Riverpod provider instantiation.
  NotificationService(Ref? ref);

  FirebaseMessaging? get _fcm =>
      Firebase.apps.isNotEmpty ? FirebaseMessaging.instance : null;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      debugPrint(
          'NotificationService: Skipping init. Firebase not initialized.');
      return;
    }

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

      // Create Android Notification Channels
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'dispatch_alerts',
            'Urgent Dispatch & SOS Alerts',
            description:
                'Instant alerts for driver ride dispatches, work orders and SOS',
            importance: Importance.max,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'rides_channel',
            'Rides & Service Updates',
            description: 'Live updates on taxi arrivals and service progress',
            importance: Importance.high,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'chat_messages',
            'Chat & In-App Messaging',
            description: 'Messages from drivers and customer support',
            importance: Importance.high,
          ),
        );
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'promotions_channel',
            'Promotions & Offers',
            description: 'Discounts, coupons and seasonal deals',
          ),
        );
      }
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
    final fcm = _fcm;
    if (fcm != null) {
      final initialMessage = await fcm.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(const Duration(milliseconds: 500), () {
          handleNotificationNavigation(initialMessage);
        });
      }

      // 6. Handle Token Refresh
      fcm.onTokenRefresh.listen((newToken) async {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          try {
            await Supabase.instance.client
                .from('profiles')
                .update({'fcm_token': newToken}).eq('id', user.id);
          } catch (_) {}
          try {
            await Supabase.instance.client
                .from('drivers')
                .update({'fcm_token': newToken}).eq('id', user.id);
          } catch (_) {}
        }
      });
    }
  }

  @override
  Future<bool> requestNotificationPermission() async {
    final fcm = _fcm;
    if (fcm == null) {
      debugPrint('FCM requestPermission skipped: Firebase not initialized.');
      return false;
    }

    final NotificationSettings settings = await fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) debugPrint('User granted notification permission');
      return true;
    } else {
      if (kDebugMode) {
        debugPrint(
            'User declined or has not accepted notification permissions');
      }
      return false;
    }
  }

  @override
  void handleNotificationNavigation(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final id = message.data['id'] as String?;

    final context = navigatorKey.currentContext;
    if (context == null || type == null) return;

    switch (type) {
      // ── Rides & Taxi ──
      case 'ride_request':
        context.push('/taxi/home');
        break;
      case 'driver_allocated':
      case 'driver_arrived':
      case 'ride_started':
        context.push('/live-tracking');
        break;
      case 'ride_completed':
      case 'driver_cancelled':
      case 'booking_update':
      case 'order_update':
        context.push('/main/bookings');
        break;

      // ── Rentals ──
      case 'rental_confirmed':
      case 'rental_pickup_reminder':
      case 'rental_return_warning':
      case 'rental_completed':
        context.push('/main/bookings');
        break;

      // ── Marketing & Rewards ──
      case 'promotion':
      case 'we_miss_you':
        context.push('/main/home');
        break;
      case 'referral_reward':
        context.push('/wallet');
        break;

      // ── Account & Security ──
      case 'payment_success':
      case 'payment_failed':
      case 'wallet_low_balance':
        context.push('/wallet');
        break;
      case 'kyc_approved':
      case 'new_login':
        context.push('/account-settings');
        break;

      case 'chat_message':
        final roomId = id ?? 'default_room';
        context.push('/chat/$roomId');
        break;
    }
  }

  @override
  Future<String?> getToken() async {
    final fcm = _fcm;
    if (fcm == null) {
      debugPrint('FCM getToken skipped: Firebase not initialized.');
      return null;
    }

    String? token;
    try {
      token = await fcm.getToken();
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

  @override
  Future<void> syncTokenToBackend(String uid) async {
    if (uid.isEmpty) return;
    try {
      final token = await getToken();
      if (token != null) {
        try {
          await Supabase.instance.client
              .from('profiles')
              .update({'fcm_token': token}).eq('id', uid);
        } catch (_) {}
        try {
          await Supabase.instance.client
              .from('drivers')
              .update({'fcm_token': token}).eq('id', uid);
        } catch (_) {}
        // ✅ Never log UID or token — only confirm success
        if (kDebugMode) debugPrint('FCM Token synced successfully.');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('FCM Token Sync Failure: $e');
      } else if (!kIsWeb) {
        unawaited(FirebaseCrashlytics.instance.recordError(
          e,
          stack,
          reason: 'FCM token sync failed',
          // ✅ Never include uid in Crashlytics metadata
        ));
      }
    }
  }

  @override
  void showError(
    String title, {
    String? message,
    dynamic error,
    StackTrace? stackTrace,
  }) {
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

    final rawDesc =
        message ?? (error != null ? NavHelpers.cleanErrorMessage(error) : null);

    // 2. Show React Sonner-style floating Toast
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark slate glassmorphism
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: const Color(0xFFEF4444).withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Iconsax.warning_2,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (rawDesc != null && rawDesc.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        rawDesc,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ],
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
    final type = message.data['type'] ?? '';
    AndroidNotificationDetails androidDetails;

    if (['promotion', 'we_miss_you', 'referral_reward'].contains(type)) {
      androidDetails = const AndroidNotificationDetails(
        'promotions_channel',
        'Promotions & Offers',
      );
    } else if ([
      'payment_failed',
      'wallet_low_balance',
      'kyc_approved',
      'new_login'
    ].contains(type)) {
      androidDetails = const AndroidNotificationDetails(
        'account_alerts_channel',
        'Account & Security',
        importance: Importance.high,
        priority: Priority.high,
      );
    } else if ([
      'order_update',
      'booking_update',
      'driver_allocated',
      'driver_arrived',
      'ride_started',
      'ride_completed',
      'driver_cancelled',
      'rental_confirmed',
      'rental_pickup_reminder',
      'rental_return_warning',
      'rental_completed'
    ].contains(type)) {
      androidDetails = const AndroidNotificationDetails(
        'rides_channel',
        'Rides & Rentals',
        importance: Importance.max,
        priority: Priority.high,
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
    }

    final NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    // ── Notification ID strategy ──────────────────────────────────────────
    // Use a hash of message type + entity ID so that:
    //   - Different notifications get unique IDs (no replacement).
    //   - Updates for the SAME entity replace each other intentionally.
    // Masked to a positive int to avoid Android notification ID overflow.
    final entityId = message.data['id'] ?? message.messageId ?? '';
    final notificationId = '${type}_$entityId'.hashCode & 0x7FFFFFFF;

    _localNotifications.show(
      notificationId,
      message.notification?.title ?? 'New Update',
      message.notification?.body ?? 'Touch to view',
      platformDetails,
    );
  }
}

// NOTE: The FCM background handler is defined in main.dart as
// _firebaseMessagingBackgroundHandler and registered via
// FirebaseMessaging.onBackgroundMessage() in the post-frame callback.
// Do NOT add a second top-level handler here — it would never be registered.
