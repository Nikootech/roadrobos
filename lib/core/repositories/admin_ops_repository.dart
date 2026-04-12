import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aggregated admin metrics computed live from Firestore collections
class AdminLiveMetrics {
  final int activeRides;
  final int pendingServices;
  final int activeRentals;
  final int totalCustomers;
  final int onlineDrivers;
  final int completedJobs;

  AdminLiveMetrics({
    this.activeRides = 0,
    this.pendingServices = 0,
    this.activeRentals = 0,
    this.totalCustomers = 0,
    this.onlineDrivers = 0,
    this.completedJobs = 0,
  });
}

class AdminOpsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Real-time aggregated metrics from all booking collections
  Stream<AdminLiveMetrics> watchMetrics() {
    // We'll combine multiple collection streams into one metrics object
    return _firestore.collection('ride_bookings').snapshots().asyncMap((rideSnap) async {
      final serviceSnap = await _firestore.collection('service_bookings').get();
      final rentalSnap = await _firestore.collection('rental_bookings').get();
      final techJobsSnap = await _firestore.collection('technician_jobs').get();
      final usersSnap = await _firestore.collection('users')
          .where('role', isEqualTo: 'customer')
          .get();

      final activeRides = rideSnap.docs
          .where((d) => d.data()['status'] != 'completed')
          .length;
      final pendingServices = serviceSnap.docs
          .where((d) => d.data()['status'] != 'completed' && d.data()['status'] != 'paid')
          .length;
      final activeRentals = rentalSnap.docs
          .where((d) => d.data()['status'] != 'paid')
          .length;
      final completedJobs = techJobsSnap.docs
          .where((d) => d.data()['status'] == 'COMPLETED')
          .length;

      return AdminLiveMetrics(
        activeRides: activeRides,
        pendingServices: pendingServices,
        activeRentals: activeRentals,
        totalCustomers: usersSnap.docs.length,
        completedJobs: completedJobs,
      );
    });
  }

  /// Recent bookings from all collections (combined feed)
  Stream<List<Map<String, dynamic>>> watchRecentBookings() {
    return _firestore.collection('service_bookings')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'customer': data['customerId'] ?? 'Unknown',
            'vehicle': data['vehicleName'] ?? 'N/A',
            'status': data['status'] ?? 'pending',
            'date': data['date'] ?? 'Today',
            'type': 'Service',
          };
        }).toList());
  }

  /// Active service operations for admin panel
  Stream<List<Map<String, dynamic>>> watchActiveServices() {
    return _firestore.collection('technician_jobs')
        .where('status', whereIn: ['SCHEDULED', 'ACCEPTED', 'IN PROGRESS'])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'vehicleReg': data['vehiclePlate'] ?? 'N/A',
            'tech': data['assignedTechId'] ?? 'Unassigned',
            'status': data['status'] ?? 'Pending',
            'vehicleModel': data['vehicleModel'] ?? '',
          };
        }).toList());
  }

  /// Update service status in Firestore
  Future<void> updateServiceStatus(String id, String status) async {
    await _firestore.collection('technician_jobs').doc(id).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final adminOpsRepositoryProvider = Provider<AdminOpsRepository>((ref) {
  return AdminOpsRepository();
});
