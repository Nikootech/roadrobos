import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../core/repositories/technician_job_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Models (kept for UI compatibility) ---
class CustomerOp {
  final int activeBookings;
  final int activeRentals;
  final int activeServices;
  final List<CustomerRide> recentRides;
  CustomerOp(this.activeBookings, this.activeRentals, this.activeServices, this.recentRides);
}

class CustomerRide {
  final String id;
  final String customer;
  final String vehicle;
  final String status;
  final String time;
  CustomerRide(this.id, this.customer, this.vehicle, this.status, this.time);
}

class DriverOp {
  final int online;
  final int pending;
  final int total;
  final List<PendingDriver> topPending;
  DriverOp(this.online, this.pending, this.total, this.topPending);
}

class PendingDriver {
  final String id;
  final String name;
  final String uploadDate;
  final int docsCount;
  PendingDriver(this.id, this.name, this.uploadDate, this.docsCount);
}

class TechOp {
  final int inService;
  final int progress;
  final int completed;
  final List<ServiceJob> recentServices;
  TechOp(this.inService, this.progress, this.completed, this.recentServices);
}

class ServiceJob {
  final String regNo;
  final String tech;
  final String status;
  final double invoiceAmount;
  ServiceJob(this.regNo, this.tech, this.status, this.invoiceAmount);
}

class EmergencyAlert {
  final String id;
  final String userId;
  final String message;
  final DateTime timestamp;
  final bool isAcknowledged;

  EmergencyAlert(this.id, this.userId, this.message, this.timestamp, {this.isAcknowledged = false});
}

// --- Providers backed by Firestore ---

final customersOpProvider = StreamProvider<CustomerOp>((ref) {
  final repo = ref.watch(adminOpsRepositoryProvider);
  return repo.watchRecentBookings().map((bookings) {
    final rides = bookings.map((b) => CustomerRide(
      b['id'] ?? '',
      b['customer'] ?? 'Unknown',
      b['vehicle'] ?? 'N/A',
      b['status'] ?? 'Active',
      b['date'] ?? 'Today',
    )).toList();

    return CustomerOp(
      bookings.where((b) => b['type'] == 'Ride').length,
      bookings.where((b) => b['type'] == 'Rental').length,
      bookings.where((b) => b['type'] == 'Service').length,
      rides,
    );
  });
});

class DriversOpNotifier extends Notifier<AsyncValue<DriverOp>> {
  @override
  AsyncValue<DriverOp> build() {
    _init();
    return const AsyncValue.loading();
  }

  void _init() async {
    // TODO: When driver collection is fully migrated, stream from Firestore
    // For now, provide reasonable defaults so UI doesn't crash
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(DriverOp(0, 0, 0, []));
  }

  void approve(String id) {
    if (state.value == null) return;
    final current = state.value!;
    final newPending = current.topPending.where((d) => d.id != id).toList();
    state = AsyncValue.data(DriverOp(current.online + 1, current.pending - 1, current.total, newPending));
  }
}
final driversOpProvider = NotifierProvider<DriversOpNotifier, AsyncValue<DriverOp>>(() => DriversOpNotifier());

final techOpProvider = StreamProvider<TechOp>((ref) {
  final repo = ref.watch(technicianJobRepositoryProvider);
  return repo.watchJobMetrics().map((metrics) {
    return TechOp(
      metrics['scheduled'] ?? 0,
      metrics['inProgress'] ?? 0,
      metrics['completed'] ?? 0,
      [], // Recent services list is shown via the main dashboard feed instead
    );
  });
});

final emergencyAlertsProvider = StreamProvider<List<EmergencyAlert>>((ref) {
  return FirebaseFirestore.instance
      .collection('emergency_alerts')
      .orderBy('timestamp', descending: true)
      .limit(5)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return EmergencyAlert(
              doc.id,
              data['userId'] ?? 'Unknown',
              data['message'] ?? 'Emergency Triggered',
              (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isAcknowledged: data['isAcknowledged'] ?? false,
            );
          }).toList());
});
