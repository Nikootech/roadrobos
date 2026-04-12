import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ride_booking.dart';

final rideBookingRepositoryProvider = Provider((ref) => RideBookingRepository());

class RideBookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createRideBooking(RideBooking booking) async {
    try {
      final docRef = _firestore.collection('ride_bookings').doc();
      final finalBooking = RideBooking(
        id: docRef.id,
        customerId: booking.customerId,
        pickupLocation: booking.pickupLocation,
        pickupAddress: booking.pickupAddress,
        dropLocation: booking.dropLocation,
        dropAddress: booking.dropAddress,
        fare: booking.fare,
        createdAt: booking.createdAt,
      );
      
      await docRef.set(finalBooking.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create ride booking: $e');
    }
  }

  Stream<List<RideBooking>> getCustomerRides(String customerId) {
    return _firestore
        .collection('ride_bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => RideBooking.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateRideStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('ride_bookings').doc(bookingId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update ride status: $e');
    }
  }
}
