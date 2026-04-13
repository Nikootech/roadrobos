import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Aggregated admin metrics computed live from Supabase tables
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
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Real-time aggregated metrics (simplified polling/stream for this migration)
  Stream<AdminLiveMetrics> watchMetrics() {
    // We'll use a stream on one table as a trigger to re-fetch all counts
    return _supabase.from('ride_bookings').stream(primaryKey: ['id']).asyncMap((_) async {
      final rideCount = await _supabase
          .from('ride_bookings')
          .select('count')
          .neq('status', 'completed');
      
      final serviceCount = await _supabase
          .from('service_bookings')
          .select('count')
          .not('status', 'in', '("completed", "paid")');
          
      final rentalCount = await _supabase
          .from('rental_bookings')
          .select('count')
          .neq('status', 'paid');
          
      final jobsCount = await _supabase
          .from('technician_jobs')
          .select('count')
          .eq('status', 'COMPLETED');
          
      final usersCount = await _supabase
          .from('profiles')
          .select('count')
          .eq('role', 'customer');

      return AdminLiveMetrics(
        activeRides: _count(rideCount),
        pendingServices: _count(serviceCount),
        activeRentals: _count(rentalCount),
        totalCustomers: _count(usersCount),
        completedJobs: _count(jobsCount),
      );
    });
  }

  int _count(dynamic response) {
    if (response is List && response.isNotEmpty) {
      return response.first['count'] ?? 0;
    }
    return 0;
  }

  /// Recent bookings (combined feed)
  Stream<List<Map<String, dynamic>>> watchRecentBookings() {
    return _supabase
        .from('service_bookings')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .limit(10)
        .map((list) => list.map((map) {
          return {
            'id': map['id'],
            'customer': map['customer_id'] ?? 'Unknown',
            'vehicle': map['vehicle_name'] ?? 'N/A',
            'status': map['status'] ?? 'pending',
            'date': map['booking_date'] ?? 'Today',
            'type': 'Service',
          };
        }).toList());
  }

  /// Active service operations
  Stream<List<Map<String, dynamic>>> watchActiveServices() {
    return _supabase
        .from('technician_jobs')
        .stream(primaryKey: ['id'])
        .map((list) => list
            .where((map) => ['SCHEDULED', 'ACCEPTED', 'IN PROGRESS'].contains(map['status']))
            .map((map) => {
              'id': map['id'],
              'vehicleReg': map['vehicle_plate'] ?? 'N/A',
              'tech': map['assigned_tech_id'] ?? 'Unassigned',
              'status': map['status'] ?? 'Pending',
              'vehicleModel': map['vehicle_model'] ?? '',
            }).toList());
  }

  /// Update service status
  Future<void> updateServiceStatus(String id, String status) async {
    await _supabase
        .from('technician_jobs')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }
}

final adminOpsRepositoryProvider = Provider<AdminOpsRepository>((ref) {
  return AdminOpsRepository();
});
