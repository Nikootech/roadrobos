import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rental_booking.dart';

final rentalBookingRepositoryProvider = Provider((ref) => RentalBookingRepository());

class RentalBookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createRentalBooking(RentalBooking booking) async {
    try {
      final docRef = _firestore.collection('rental_bookings').doc();
      final finalBooking = RentalBooking(
        id: docRef.id,
        customerId: booking.customerId,
        vehicleName: booking.vehicleName,
        rentalType: booking.rentalType,
        startTime: booking.startTime,
        duration: booking.duration,
        totalCost: booking.totalCost,
        details: booking.details,
      );
      
      await docRef.set(finalBooking.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create rental booking: $e');
    }
  }

  Future<void> updateRentalStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('rental_bookings').doc(bookingId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update rental status: $e');
    }
  }
}
