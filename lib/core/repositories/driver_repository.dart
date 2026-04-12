import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../models/driver_model.dart';
import '../models/ride_booking.dart';

final driverRepositoryProvider = Provider((ref) => DriverRepository());

class DriverRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream of a specific driver's profile and real-time state
  Stream<DriverModel?> watchDriver(String uid) {
    return _firestore
        .collection('drivers')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? DriverModel.fromMap(doc.data()!, doc.id) : null);
  }

  /// Toggle driver online/offline status
  Future<void> updateOnlineStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection('drivers').doc(uid).set({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update online status: $e');
    }
  }

  /// Update driver's real-time location
  Future<void> updatePosition(String uid, LatLng position) async {
    try {
      await _firestore.collection('drivers').doc(uid).update({
        'lat': position.latitude,
        'lng': position.longitude,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't throw for silent background updates, but log if needed
    }
  }

  /// Stream of pending ride requests for drivers to accept
  Stream<List<RideBooking>> watchPendingRides() {
    return _firestore
        .collection('ride_bookings')
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RideBooking.fromMap(doc.data(), doc.id)).toList();
    });
  }

  /// Accept a ride request
  Future<void> acceptRide(String rideId, String driverId) async {
    try {
      // Atomic update to prevent multiple drivers from accepting the same ride
      await _firestore.runTransaction((transaction) async {
        final rideDoc = await transaction.get(_firestore.collection('ride_bookings').doc(rideId));
        
        if (!rideDoc.exists) throw Exception('Ride not found');
        if (rideDoc.data()?['status'] != 'pending') throw Exception('Ride already taken');

        transaction.update(rideDoc.reference, {
          'driverId': driverId,
          'status': 'booked',
          'acceptedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      throw Exception('Failed to accept ride: $e');
    }
  }

  /// Update trip status (Enroute -> Arrived -> Started -> Completed)
  Future<void> updateTripStatus(String rideId, String status) async {
    try {
      await _firestore.collection('ride_bookings').doc(rideId).update({
        'status': status,
        '${status}At': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update trip status: $e');
    }
  }

  /// Update FCM token for push notifications
  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _firestore.collection('drivers').doc(uid).update({
        'fcmToken': token,
      });
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
  }) async {
    try {
      await _firestore.collection('drivers').doc(uid).set({
        'name': name,
        'phone': phone,
        'vehicleModel': vehicleModel,
        'chassisNumber': chassisNumber,
        'licenseNumber': licenseNumber,
        'approvalStatus': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': false,
        'todayEarnings': 0.0,
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }
}
