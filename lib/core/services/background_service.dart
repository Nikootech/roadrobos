import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // Initialize notifications for foreground service
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // For Android, we need to show a persistent notification to keep the background service alive.
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Example background task: Syncing driver location or checking data periodically
  Timer.periodic(const Duration(seconds: 15), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await flutterLocalNotificationsPlugin.show(
          888, // Notification ID
          'RoadRobos is running in background',
          'We are keeping your connection alive...',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'background_service', // Ensure this channel exists in main
              'Background Service',
              icon: '@mipmap/launcher_icon',
              ongoing: true,
              importance: Importance.min,
              priority: Priority.min,
            ),
          ),
        );
      }
    }

    debugPrint('Background service running at ${DateTime.now()}');
    // Here we can trigger any API calls, location updates, or Supabase queries.
    // e.g. Supabase.instance.client.from('driver_locations').upsert({...})
  });
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'background_service',
    'Background Service',
    description: 'This channel is used for important background processes.',
    importance: Importance.low, // low importance keeps it silent
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      notificationChannelId: 'background_service',
      initialNotificationTitle: 'RoadRobos Background Service',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  
  await service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}
