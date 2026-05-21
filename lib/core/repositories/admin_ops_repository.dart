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
      final rideRes = await _supabase
          .from('ride_bookings')
          .select('id')
          .neq('status', 'completed');
      
      final serviceRes = await _supabase
          .from('service_bookings')
          .select('id')
          .not('status', 'in', '("completed", "paid")');
          
      final rentalRes = await _supabase
          .from('rental_bookings')
          .select('id')
          .neq('status', 'paid');
          
      final jobsRes = await _supabase
          .from('technician_jobs')
          .select('id')
          .eq('status', 'COMPLETED');
          
      final usersRes = await _supabase
          .from('profiles')
          .select('id')
          .eq('role', 'customer');

      return AdminLiveMetrics(
        activeRides: rideRes.length,
        pendingServices: serviceRes.length,
        activeRentals: rentalRes.length,
        totalCustomers: usersRes.length,
        completedJobs: jobsRes.length,
      );
    });
  }

  // Removed _count helper as it's no longer needed

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

  /// Approve a pending driver
  Future<void> approveDriver(String id) async {
    await _supabase
        .from('drivers')
        .update({
          'approval_status': 'approved',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);

    // Synchronize KYC status in profile
    await _supabase
        .from('profiles')
        .update({'kyc_status': 'verified'})
        .eq('id', id);
  }

  /// Real-time driver operations metrics
  Stream<Map<String, dynamic>> watchDriverMetrics() {
    return _supabase.from('drivers').stream(primaryKey: ['id']).map((list) {
      final total = list.length;
      final online = list.where((d) => d['is_online'] == true).length;
      final pending = list.where((d) => d['approval_status'] == 'pending').length;
      
      final topPending = list
          .where((d) => d['approval_status'] == 'pending')
          .take(5)
          .map((d) => {
                'id': d['id'].toString(),
                'name': d['name'] ?? 'New Driver',
                'uploadDate': d['created_at'] != null 
                    ? d['created_at'].toString().split('T')[0] 
                    : 'Today',
                'docsCount': (d['kyc_documents'] as List?)?.length ?? 0,
              })
          .toList();

      return {
        'online': online,
        'pending': pending,
        'total': total,
        'topPending': topPending,
      };
    });
  }

  /// Get all customers from profiles table
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('role', 'customer')
        .order('created_at', ascending: false);
    return response;
  }

  /// Get all technicians from profiles table
  Future<List<Map<String, dynamic>>> getAllTechnicians() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('role', 'technician')
        .order('created_at', ascending: false);
    return response;
  }

  /// Get all drivers with their stats
  Future<List<Map<String, dynamic>>> getAllDrivers() async {
    final response = await _supabase
        .from('drivers')
        .select()
        .order('created_at', ascending: false);
    return response;
  }

  /// Update driver KYC document status
  Future<void> updateDriverKycStatus(String driverId, String docTitle, String status) async {
    // 1. Fetch current docs
    final res = await _supabase.from('drivers').select('kyc_documents').eq('id', driverId).single();
    List docs = res['kyc_documents'] as List? ?? [];
    
    // 2. Update the specific doc
    final updatedDocs = docs.map((d) {
      if (d['title'] == docTitle) {
        return {...d, 'status': status, 'updated_at': DateTime.now().toIso8601String()};
      }
      return d;
    }).toList();

    // 3. Save back
    await _supabase.from('drivers').update({'kyc_documents': updatedDocs}).eq('id', driverId);
  }

  /// Approve wallet withdrawal
  Future<void> approveWalletWithdrawal(String driverId) async {
    // In a real app, this would trigger a payment gateway or ledger entry
    await _supabase.from('drivers').update({
      'wallet_request': 0,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', driverId);
  }
}

final adminOpsRepositoryProvider = Provider<AdminOpsRepository>((ref) {
  return AdminOpsRepository();
});
