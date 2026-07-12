import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/driver_model.dart';
import '../models/ride_booking.dart';
import '../extensions/datetime_extensions.dart';


final driverRepositoryProvider = Provider((ref) => DriverRepository());

class DriverRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Stream of a specific driver's profile
  Stream<DriverModel?> watchDriver(String uid) {
    return _supabase
        .from('drivers')
        .stream(primaryKey: ['id'])
        .eq('id', uid)
        .map((list) => list.isNotEmpty ? DriverModel.fromMap(list.first, list.first['id'].toString()) : null);
  }

  /// Toggle driver online/offline status
  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    try {
      await _supabase.from('drivers').update({
        'is_online': isOnline,
        'last_active': DateTime.now().utcIso,
      }).eq('id', uid);
    } catch (e) {
      throw Exception('Failed to update online status: $e');
    }
  }

  /// Update driver's real-time location
  Future<void> updatePosition(String uid, LatLng position) async {
    try {
      await _supabase.from('drivers').update({
        'lat': position.latitude,
        'lng': position.longitude,
        'last_active': DateTime.now().utcIso,
      }).eq('id', uid);
    } catch (e) {
      // Background update - silent fail
    }
  }

  /// Get online drivers matching a vehicle type
  Future<List<DriverModel>> getOnlineDrivers(String vehicleTypeId) async {
    try {
      final response = await _supabase.from('drivers').select().eq('is_online', true);
      final List<DriverModel> allOnline = response.map((data) => DriverModel.fromMap(data, data['id'].toString())).toList();
      
      return allOnline.where((d) {
        final model = d.vehicleModel.toLowerCase();
        if (vehicleTypeId.contains('auto')) {
          return model.contains('auto') || model.contains('rickshaw') || model.contains('bajaj');
        } else if (vehicleTypeId.contains('bike')) {
          return model.contains('bike') || model.contains('splendor') || model.contains('motor') || model.contains('honda');
        } else if (vehicleTypeId.contains('cab') || vehicleTypeId.contains('car')) {
          return model.contains('car') || model.contains('swift') || model.contains('sedan') || model.contains('suv');
        }
        return true;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Stream of pending ride requests (status = 'searching')
  /// This MUST match the status written by TaxiProvider.startSearching()
  Stream<List<RideBooking>> watchPendingRides() {
    return _supabase
        .from('ride_bookings')
        .stream(primaryKey: ['id'])
        .eq('status', 'searching')
        .order('created_at')
        .map((list) {
      return list.map((map) => RideBooking.fromMap(map, map['id'].toString())).toList();
    });
  }

  /// Accept a ride request — atomically assigns driver and updates status
  /// Uses conditional update (.eq('status','searching')) to prevent race conditions
  /// where two drivers try to accept the same ride simultaneously.
  Future<void> acceptRide(String rideId, String driverId) async {
    try {
      final response = await _supabase
          .from('ride_bookings')
          .update({
            'driver_id': driverId,
            'status': 'accepted', // Customer listener watches for this
            'accepted_at': DateTime.now().utcIso,
          })
          .eq('id', rideId)
          .eq('status', 'searching') // Only accept if still searching
          .select();
      
      if (response.isEmpty) {
        throw Exception('Ride already taken by another driver');
      }
    } catch (e) {
      throw Exception('Failed to accept ride: $e');
    }
  }

  /// Update trip status
  Future<void> updateTripStatus(String rideId, String status) async {
    try {
      await _supabase.from('ride_bookings').update({
        'status': status,
        '${status}_at': DateTime.now().utcIso,
      }).eq('id', rideId);
    } catch (e) {
      throw Exception('Failed to update trip status: $e');
    }
  }

  /// Update FCM token
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _supabase.from('drivers').update({
        'fcm_token': token,
      }).eq('id', uid);
    } catch (e) {
      throw Exception('Failed to update FCM token: $e');
    }
  }

  /// Register a new driver profile
  Future<bool> registerDriver({
    required String uid,
    required String name,
    required String phone,
    required String vehicleModel,
    required String chassisNumber,
    required String licenseNumber,
    String approvalStatus = 'approved', // Auto-approve by default per new requirement
  }) async {
    try {
      await _supabase.from('drivers').upsert({
        'id': uid,
        'name': name,
        'phone': phone,
        'vehicle_model': vehicleModel,
        'chassis_number': chassisNumber,
        'license_number': licenseNumber,
        'approval_status': approvalStatus,
        'is_online': false,
        'today_earnings': 0.0,
        'created_at': DateTime.now().utcIso,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update driver details
  Future<void> updateDriver(String uid, Map<String, dynamic> data) async {
    try {
      await _supabase.from('drivers').update(data).eq('id', uid);
    } catch (e) {
      throw Exception('Failed to update driver: $e');
    }
  }
}
