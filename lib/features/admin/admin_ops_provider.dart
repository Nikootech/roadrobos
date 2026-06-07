import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../core/providers/rbac_provider.dart';

class AdminOpsMetrics {
  final int activeRides;
  final int pendingServices;
  final int walletRequests;
  AdminOpsMetrics({required this.activeRides, required this.pendingServices, required this.walletRequests});
}

class BookingOp {
  final String id;
  final String customer;
  final String vehicle;
  final String status;
  final String date;
  BookingOp({required this.id, required this.customer, required this.vehicle, required this.status, required this.date});
}

class ServiceOp {
  final String id;
  final String vehicleReg;
  final String tech;
  final String status;
  ServiceOp({required this.id, required this.vehicleReg, required this.tech, required this.status});
}

// --- Firestore-Backed Providers ---

final adminMetricsStreamProvider = StreamProvider<AdminOpsMetrics>((ref) {
  // Permission Guard
  final hasAdminAccess = ref.watch(hasPermissionProvider('admin_access'));
  if (!hasAdminAccess) {
    return Stream.error('Security Violation: Unauthorized Access');
  }

  final repo = ref.watch(adminOpsRepositoryProvider);
  return repo.watchMetrics().map((live) => AdminOpsMetrics(
    activeRides: live.activeRides,
    pendingServices: live.pendingServices,
    walletRequests: live.activeRentals, // Mapped to rentals count for now
  ));
});

final adminBookingsProvider = StreamProvider<List<BookingOp>>((ref) {
  // Permission Guard
  final hasAdminAccess = ref.watch(hasPermissionProvider('admin_access'));
  if (!hasAdminAccess) {
    throw Exception('Unauthorized: Admin access required');
  }

  final repo = ref.watch(adminOpsRepositoryProvider);
  return repo.watchRecentBookings().map((bookings) => bookings.map((b) => BookingOp(
    id: b['id'] ?? '',
    customer: b['customer'] ?? 'Unknown',
    vehicle: b['vehicle'] ?? 'N/A',
    status: b['status'] ?? 'Pending',
    date: b['date'] ?? 'Today',
  )).toList());
});

class ServiceOpsNotifier extends Notifier<AsyncValue<List<ServiceOp>>> {
  StreamSubscription? _subscription;

  @override
  AsyncValue<List<ServiceOp>> build() {
    // Permission Guard
    final hasAdminAccess = ref.watch(hasPermissionProvider('admin_access'));
    if (!hasAdminAccess) {
      return const AsyncValue.error('Access Denied', StackTrace.empty);
    }

    _init();
    
    // Ensure cleanup of stream listener
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const AsyncValue.loading();
  }

  void _init() {
    final repo = ref.read(adminOpsRepositoryProvider);
    _subscription = repo.watchActiveServices().listen((services) {
      state = AsyncValue.data(services.map((s) => ServiceOp(
        id: s['id'] ?? '',
        vehicleReg: s['vehicleReg'] ?? 'N/A',
        tech: s['tech'] ?? 'Unassigned',
        status: s['status'] ?? 'Pending',
      )).toList());
    }, onError: (err) {
      state = AsyncValue.error(err, StackTrace.current);
    });
  }

  Future<void> approveService(String id) async {
    try {
       // 1. Persist to Firestore
       await ref.read(adminOpsRepositoryProvider).updateServiceStatus(id, 'Approved');
       
       // 2. Optimistic Update (Local UI)
       if (state.hasValue) {
         final current = state.value!;
         state = AsyncValue.data(
           current.map((s) => s.id == id ? ServiceOp(id: s.id, vehicleReg: s.vehicleReg, tech: s.tech, status: 'Approved') : s).toList()
         );
       }
    } catch (e) {
       // Rollback or handle error
       state = AsyncValue.error('Failed to approve: $e', StackTrace.current);
    }
  }
}

final adminServicesProvider = NotifierProvider<ServiceOpsNotifier, AsyncValue<List<ServiceOp>>>(() => ServiceOpsNotifier());
