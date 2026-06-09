import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../extensions/datetime_extensions.dart';


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

class AdminOpsRepositoryException implements Exception {
  final String message;
  final dynamic details;
  AdminOpsRepositoryException(this.message, [this.details]);

  @override
  String toString() => 'AdminOpsRepositoryException: $message (${details ?? ''})';
}

class AdminOpsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Real-time aggregated metrics (simplified polling/stream for this migration)
  Stream<AdminLiveMetrics> watchMetrics() {
    // We'll use a stream on one table as a trigger to re-fetch all counts
    return _supabase.from('ride_bookings').stream(primaryKey: ['id']).asyncMap((_) async {
      try {
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
      } catch (e) {
        throw AdminOpsRepositoryException('Failed to watch metrics', e);
      }
    });
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
    try {
      await _supabase
          .from('technician_jobs')
          .update({
            'status': status,
            'updated_at': DateTime.now().utcIso,
          })
          .eq('id', id);
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to update service status', e);
    }
  }

  /// Approve a pending driver
  Future<void> approveDriver(String id) async {
    try {
      await _supabase
          .from('drivers')
          .update({
            'approval_status': 'approved',
            'updated_at': DateTime.now().utcIso,
          })
          .eq('id', id);

      // Synchronize KYC status in profile
      await _supabase
          .from('profiles')
          .update({'kyc_status': 'verified'})
          .eq('id', id);
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to approve driver', e);
    }
  }

  /// Real-time driver operations metrics
  Stream<Map<String, dynamic>> watchDriverMetrics() {
    return _supabase.from('drivers').stream(primaryKey: ['id']).asyncMap((list) async {
      try {
        final total = list.length;
        final online = list.where((d) => d['is_online'] == true).length;
        final pending = list.where((d) => d['approval_status'] == 'pending').length;
        
        // Fetch document counts from partner_kyc
        final kycResponse = await _supabase.from('partner_kyc').select('user_id');
        final Map<String, int> driverKycCounts = {};
        for (final row in kycResponse) {
          final userId = row['user_id'] as String;
          driverKycCounts[userId] = (driverKycCounts[userId] ?? 0) + 1;
        }

        final topPending = list
            .where((d) => d['approval_status'] == 'pending')
            .take(5)
            .map((d) {
              final dId = d['id'].toString();
              return {
                'id': dId,
                'name': d['name'] ?? 'New Driver',
                'uploadDate': d['created_at'] != null 
                    ? d['created_at'].toString().split('T')[0] 
                    : 'Today',
                'docsCount': driverKycCounts[dId] ?? 0,
              };
            })
            .toList();

        return {
          'online': online,
          'pending': pending,
          'total': total,
          'topPending': topPending,
        };
      } catch (e) {
        throw AdminOpsRepositoryException('Failed to process driver metrics', e);
      }
    });
  }

  /// Get all customers from profiles table
  Future<List<Map<String, dynamic>>> getAllCustomers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'customer')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to fetch customers', e);
    }
  }

  /// Get all technicians from profiles table
  Future<List<Map<String, dynamic>>> getAllTechnicians() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'technician')
          .order('created_at', ascending: false);
      return response;
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to fetch technicians', e);
    }
  }

  /// Get all drivers with their stats (KYC docs and wallet withdrawal requests aggregated)
  Future<List<Map<String, dynamic>>> getAllDrivers() async {
    try {
      final response = await _supabase
          .from('drivers')
          .select('*, wallet_withdrawal_requests(amount, status)');
      final List<Map<String, dynamic>> driversList = List<Map<String, dynamic>>.from(response);
      
      final kycDocs = await _supabase
          .from('partner_kyc')
          .select('user_id, document_type, status, created_at');

      final List<Map<String, dynamic>> result = [];
      for (final driver in driversList) {
        final driverId = driver['id'] as String;
        
        // Compute wallet request amount
        final requests = driver['wallet_withdrawal_requests'] as List? ?? [];
        final pendingAmount = requests
            .where((r) => r['status'] == 'pending')
            .fold<double>(0.0, (sum, r) => sum + (double.tryParse(r['amount'].toString()) ?? 0.0));

        // Get driver's KYC documents from partner_kyc
        final docs = kycDocs
            .where((k) => k['user_id'] == driverId)
            .map((k) => {
                  'title': k['document_type'] ?? 'Document',
                  'status': k['status'] ?? 'pending',
                  'uploaded_at': k['created_at'],
                })
            .toList();

        result.add({
          ...driver,
          'wallet_request': pendingAmount,
          'kyc_documents': docs,
        });
      }
      return result;
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to fetch drivers', e);
    }
  }

  /// Get driver KYC document list directly
  Future<List<Map<String, dynamic>>> getDriverKycDocuments(String driverId) async {
    try {
      final response = await _supabase
          .from('partner_kyc')
          .select()
          .eq('user_id', driverId);
      return response;
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to fetch KYC documents for driver $driverId', e);
    }
  }

  /// Update driver KYC document status
  Future<void> updateDriverKycStatus(String driverId, String docTitle, String status) async {
    try {
      await _supabase
          .from('partner_kyc')
          .update({
            'status': status,
            'updated_at': DateTime.now().utcIso,
          })
          .eq('user_id', driverId)
          .eq('document_type', docTitle);
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to update KYC document $docTitle status for driver $driverId', e);
    }
  }

  /// Approve wallet withdrawal
  Future<void> approveWalletWithdrawal(String driverId) async {
    try {
      await _supabase
          .from('wallet_withdrawal_requests')
          .update({
            'status': 'approved',
            'resolved_at': DateTime.now().utcIso,
          })
          .eq('driver_id', driverId)
          .eq('status', 'pending');
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to approve wallet withdrawal', e);
    }
  }

  /// Get all employees (users whose roles are NOT customer and NOT driver)
  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .not('role', 'in', '("customer", "driver")')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to fetch employees', e);
    }
  }

  /// Update employee approval status and optionally role
  Future<void> updateEmployeeApproval(String id, bool isApproved, {String? role}) async {
    try {
      final updates = <String, dynamic>{
        'is_approved': isApproved,
      };
      if (role != null) {
        updates['role'] = role;
      }
      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to update employee status', e);
    }
  }

  /// Assign a technician to a service booking and create/update its job card
  Future<void> assignTechnicianToBooking(String bookingId, String techId) async {
    try {
      // 1. Update the booking itself
      await _supabase
          .from('service_bookings')
          .update({'tech_id': techId})
          .eq('id', bookingId);

      // 2. Fetch the booking to sync details into technician_jobs
      final bookingRes = await _supabase
          .from('service_bookings')
          .select()
          .eq('id', bookingId)
          .maybeSingle();

      if (bookingRes == null) {
        throw Exception('Service booking not found');
      }

      // 3. Upsert into technician_jobs
      final existingJob = await _supabase
          .from('technician_jobs')
          .select('id')
          .eq('booking_id', bookingId)
          .maybeSingle();

      final jobPayload = {
        'assigned_tech_id': techId,
        'booking_id': bookingId,
        'status': 'SCHEDULED',
        'vehicle_model': bookingRes['vehicle_name'] ?? 'Vehicle',
        'vehicle_plate': bookingRes['vehicle_plate'] ?? 'Plate',
        'service_type': 'General Service',
        'package_name': bookingRes['package_name'] ?? 'Package',
        'date': bookingRes['booking_date'] ?? '',
        'time': bookingRes['booking_time'] ?? '',
        'price': '₹${(bookingRes['total_cost'] ?? 0.0).toString()}',
        'progress': 0.0,
        'checklist': [],
        'parts': [],
      };

      if (existingJob != null) {
        await _supabase
            .from('technician_jobs')
            .update(jobPayload)
            .eq('id', existingJob['id']);
      } else {
        await _supabase
            .from('technician_jobs')
            .insert(jobPayload);
      }
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to assign technician to booking', e);
    }
  }

  /// Fetch all unassigned service bookings
  Future<List<Map<String, dynamic>>> getUnassignedServiceBookings() async {
    try {
      final response = await _supabase
          .from('service_bookings')
          .select()
          .isFilter('tech_id', null)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to fetch unassigned service bookings', e);
    }
  }

  /// Assign a driver to a ride booking
  Future<void> assignDriverToRide(String rideId, String driverId) async {
    try {
      await _supabase
          .from('ride_bookings')
          .update({
            'driver_id': driverId,
            'status': 'accepted',
          })
          .eq('id', rideId);
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to assign driver to ride', e);
    }
  }

  /// Fetch all active or searching ride bookings
  Future<List<Map<String, dynamic>>> getActiveSearchingRides() async {
    try {
      final response = await _supabase
          .from('ride_bookings')
          .select()
          .inFilter('status', ['searching', 'accepted', 'on_trip'])
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw AdminOpsRepositoryException('Failed to fetch active/searching rides', e);
    }
  }
}

final adminOpsRepositoryProvider = Provider<AdminOpsRepository>((ref) {
  return AdminOpsRepository();
});
