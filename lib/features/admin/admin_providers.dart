import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/admin_ops_repository.dart';
import 'package:roadrobos/core/repositories/technician_job_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/extensions/datetime_extensions.dart';
import '../../core/models/user_role.dart';
import '../../features/profile/user_provider.dart';

// --- Models (kept for UI compatibility) ---
class CustomerOp {
  final int activeBookings;
  final int activeRentals;
  final int activeServices;
  final List<CustomerRide> recentRides;
  CustomerOp(this.activeBookings, this.activeRentals, this.activeServices,
      this.recentRides);
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
  final int pending;
  final List<ServiceJob> recentServices;
  TechOp(this.inService, this.progress, this.completed, this.pending,
      this.recentServices);
}

class ServiceJob {
  final String regNo;
  final String tech;
  final String status;
  final double invoiceAmount;
  final String timeLabel;
  ServiceJob(this.regNo, this.tech, this.status, this.invoiceAmount,
      {this.timeLabel = ''});
}

class EmergencyAlert {
  final String id;
  final String userId;
  final String message;
  final DateTime timestamp;
  final bool isAcknowledged;

  EmergencyAlert(this.id, this.userId, this.message, this.timestamp,
      {this.isAcknowledged = false});
}

// --- Providers backed by Supabase ---

final customersOpProvider = StreamProvider<CustomerOp>((ref) {
  final repo = ref.watch(adminOpsRepositoryProvider);
  return repo.watchRecentBookings().map((bookings) {
    final rides = bookings
        .map((b) => CustomerRide(
              b['id'] ?? '',
              b['customer'] ?? 'Unknown',
              b['vehicle'] ?? 'N/A',
              b['status'] ?? 'Active',
              b['date'] ?? 'Today',
            ))
        .toList();

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
    final topPending = (data['topPending'] as List)
        .map((d) => PendingDriver(
              d['id'],
              d['name'],
              d['uploadDate'],
              d['docsCount'],
            ))
        .toList();

    return DriverOp(
      data['online'] ?? 0,
      data['pending'] ?? 0,
      data['total'] ?? 0,
      topPending,
    );
  });
});

/// Real-time technician ops provider backed by the technician_jobs Supabase table.
/// Emits live job counts AND the 5 most recent/active jobs for the admin card.
final techOpProvider = StreamProvider<TechOp>((ref) {
  final repo = ref.watch(technicianJobRepositoryProvider);
  return repo.watchAllJobs().map((jobs) {
    final scheduled = jobs.where((j) => j.status == 'SCHEDULED').length;
    final inProgress = jobs
        .where((j) => j.status == 'IN PROGRESS' || j.status == 'ACCEPTED')
        .length;
    final completed = jobs.where((j) => j.status == 'COMPLETED').length;
    final pending = scheduled + inProgress;

    // Sort: active first, then scheduled, then completed; newest first within groups
    final sorted = [...jobs]..sort((a, b) {
        int priority(String s) {
          if (s == 'IN PROGRESS' || s == 'ACCEPTED') return 0;
          if (s == 'SCHEDULED') return 1;
          return 2;
        }

        final p = priority(a.status).compareTo(priority(b.status));
        if (p != 0) return p;
        return b.createdAt.compareTo(a.createdAt);
      });

    final recentServices = sorted.take(5).map((j) {
      // Labels computed first (needed in all code paths)
      final regLabel =
          j.vehiclePlate.isNotEmpty ? j.vehiclePlate : j.vehicleModel;
      final techLabel = j.assignedTechId?.isNotEmpty == true
          ? j.assignedTechId!.substring(0, 8).toUpperCase()
          : 'Unassigned';

      // Parse price to double (strip ₹ and other symbols)
      double amt = 0;
      try {
        amt = double.parse(j.price.replaceAll(RegExp(r'[^\d.]'), ''));
      } catch (_) {}

      // Human-readable time since job was created
      String timeLabel = 'Just now';
      try {
        final diff = DateTime.now().difference(j.createdAt);
        if (diff.inMinutes < 60) {
          timeLabel = '${diff.inMinutes}m ago';
        } else if (diff.inHours < 24) {
          timeLabel = '${diff.inHours}h ago';
        } else {
          timeLabel = '${diff.inDays}d ago';
        }
      } catch (_) {}

      return ServiceJob(regLabel, techLabel, j.status, amt,
          timeLabel: timeLabel);
    }).toList();

    return TechOp(scheduled, inProgress, completed, pending, recentServices);
  });
});

final emergencyAlertsProvider = StreamProvider<List<EmergencyAlert>>((ref) {
  final supabase = Supabase.instance.client;
  return supabase
      .from('emergency_alerts')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .limit(5)
      .map((list) =>
          list.where((data) => !(data['is_acknowledged'] ?? false)).map((data) {
            return EmergencyAlert(
              data['id'].toString(),
              data['user_id'] ?? 'Unknown',
              data['message'] ?? 'Emergency Triggered',
              DateTime.parse(data['created_at'] ?? DateTime.now().utcIso),
              isAcknowledged: data['is_acknowledged'] ?? false,
            );
          }).toList());
});

/// Allows SuperAdmin / Founder to preview the dashboard as any of the 14 roles.
final impersonatedRoleProvider = StateProvider<UserRole?>((ref) => null);

/// Geographic zone scoping (e.g. "All Zones", "Mumbai - South", "Delhi - NCR", etc.)
final selectedZoneProvider = StateProvider<String>((ref) => 'All Zones');

/// The effective role used to drive dashboard layout (either real or impersonated).
final effectiveAdminRoleProvider = Provider<UserRole>((ref) {
  final impersonated = ref.watch(impersonatedRoleProvider);
  if (impersonated != null) return impersonated;
  final user = ref.watch(userProvider).user;
  return user?.role ?? UserRole.admin;
});
