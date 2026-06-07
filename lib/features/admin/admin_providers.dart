import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/admin_ops_repository.dart';
import 'package:roadrobos/core/repositories/technician_job_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/extensions/datetime_extensions.dart';


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

final driversOpProvider = StreamProvider<DriverOp>((ref) {
  final repo = ref.watch(adminOpsRepositoryProvider);
  return repo.watchDriverMetrics().map((data) {
    final topPending = (data['topPending'] as List).map((d) => PendingDriver(
      d['id'],
      d['name'],
      d['uploadDate'],
      d['docsCount'],
    )).toList();

    return DriverOp(
      data['online'] ?? 0,
      data['pending'] ?? 0,
      data['total'] ?? 0,
      topPending,
    );
  });
});

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
  final supabase = Supabase.instance.client;
  return supabase
      .from('emergency_alerts')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .limit(5)
      .map((list) => list.map((data) {
            return EmergencyAlert(
              data['id'].toString(),
              data['user_id'] ?? 'Unknown',
              data['message'] ?? 'Emergency Triggered',
              DateTime.parse(data['created_at'] ?? DateTime.now().utcIso),
              isAcknowledged: data['is_acknowledged'] ?? false,
            );
          }).toList());
});
