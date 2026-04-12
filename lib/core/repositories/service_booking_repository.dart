import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_booking.dart';

final serviceBookingRepositoryProvider = Provider((ref) => ServiceBookingRepository());

class ServiceBookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createServiceBooking(ServiceBooking booking) async {
    try {
      final docRef = _firestore.collection('service_bookings').doc();
      final finalBooking = ServiceBooking(
        id: docRef.id,
        customerId: booking.customerId,
        vehicleName: booking.vehicleName,
        vehiclePlate: booking.vehiclePlate,
        packageName: booking.packageName,
        date: booking.date,
        time: booking.time,
        totalCost: booking.totalCost,
        details: booking.details,
        createdAt: booking.createdAt,
      );
      
      await docRef.set(finalBooking.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create service booking: $e');
    }
  }

  Stream<List<ServiceBooking>> getCustomerServiceBookings(String customerId) {
    return _firestore
        .collection('service_bookings')
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ServiceBooking.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> updateServiceStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('service_bookings').doc(bookingId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update service status: $e');
    }
  }
}
