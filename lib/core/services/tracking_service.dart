import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/profile/user_provider.dart';
import '../models/user_role.dart';

final trackingServiceProvider = Provider<TrackingService>((ref) {
  return TrackingService(ref);
});

class TrackingService {
  final Ref _ref;
  StreamSubscription<Position>? _positionStream;
  Timer? _upsertTimer;
  Position? _latestPosition;
  String? _trackingDriverId;
  final SupabaseClient _supabase = Supabase.instance.client;

  TrackingService(this._ref);

  Future<void> startTracking(String driverId) async {
    _trackingDriverId = driverId;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _latestPosition = position;
    });

    _upsertTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_latestPosition != null) {
        _supabase.from('driver_locations').upsert({
          'driver_id': _trackingDriverId,
          'lat': _latestPosition!.latitude,
          'lng': _latestPosition!.longitude,
          'updated_at': DateTime.now().toIso8601String(),
          'status': 'active',
        }).catchError((e) => null);
      }
    });
  }

  Future<void> stopTracking() async {
    _positionStream?.cancel();
    _positionStream = null;
    
    _upsertTimer?.cancel();
    _upsertTimer = null;
    
    if (_trackingDriverId != null) {
      await _supabase.from('driver_locations').upsert({
        'driver_id': _trackingDriverId,
        'status': 'offline',
        'updated_at': DateTime.now().toIso8601String(),
      }).catchError((e) => null);
      _trackingDriverId = null;
    }
  }
}
