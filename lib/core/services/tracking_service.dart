import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../extensions/datetime_extensions.dart';

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService();
});

class TrackingService {
  StreamSubscription<Position>? _positionStream;
  Timer? _upsertTimer;
  Position? _latestPosition;
  String? _trackingDriverId;
  SupabaseClient get _supabase => Supabase.instance.client;

  TrackingService();

  Future<void> startTracking(String driverId) async {
    _trackingDriverId = driverId;

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 4),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText:
              'App will continue to receive your location even when you aren\'t using it',
          notificationTitle: 'Location Tracking Active',
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 10,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _latestPosition = position;
    });

    _upsertTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_latestPosition != null) {
        _supabase.from('driver_locations').upsert({
          'driver_id': _trackingDriverId,
          'lat': _latestPosition!.latitude,
          'lng': _latestPosition!.longitude,
          'updated_at': DateTime.now().utcIso,
          'status': 'active',
        }).catchError((e) => null);
      }
    });
  }

  Future<void> stopTracking() async {
    // ignore: unawaited_futures
    _positionStream?.cancel();
    _positionStream = null;

    _upsertTimer?.cancel();
    _upsertTimer = null;

    if (_trackingDriverId != null) {
      await _supabase.from('driver_locations').upsert({
        'driver_id': _trackingDriverId,
        'status': 'offline',
        'updated_at': DateTime.now().utcIso,
      }).catchError((e) => null);
      _trackingDriverId = null;
    }
  }
}
