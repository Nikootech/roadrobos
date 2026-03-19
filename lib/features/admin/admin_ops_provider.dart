import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Global Providers 

final adminMetricsStreamProvider = StreamProvider<AdminOpsMetrics>((ref) async* {
  yield AdminOpsMetrics(activeRides: 5, pendingServices: 3, walletRequests: 2);
  // Simulating live updates
  await for (final _ in Stream.periodic(const Duration(seconds: 10))) {
    yield AdminOpsMetrics(
      activeRides: 5 + (DateTime.now().second % 3),
      pendingServices: 3 + (DateTime.now().second % 2),
      walletRequests: 2 + (DateTime.now().second % 4),
    );
  }
});

final adminBookingsProvider = StreamProvider<List<BookingOp>>((ref) async* {
  yield [
    BookingOp(id: 'B1042', customer: 'Arjun K.', vehicle: 'Sedan (DL 1C)', status: 'Active', date: 'Today, 14:30'),
    BookingOp(id: 'B1043', customer: 'Neha S.', vehicle: 'Hatchback', status: 'Pending', date: 'Today, 15:00'),
    BookingOp(id: 'R9021', customer: 'Priya D.', vehicle: 'Innova (Rent)', status: 'Active', date: 'Today, 09:00'),
  ];
});

class ServiceOpsNotifier extends Notifier<AsyncValue<List<ServiceOp>>> {
  @override
  AsyncValue<List<ServiceOp>> build() {
    _init();
    return const AsyncValue.loading();
  }

  void _init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data([
      ServiceOp(id: 'S401', vehicleReg: 'MH 02 AB 1234', tech: 'Unassigned', status: 'Pending'),
      ServiceOp(id: 'S402', vehicleReg: 'TS 09 GH 2345', tech: 'Rajesh (T04)', status: 'In Progress'),
    ]);
  }

  void approveService(String id) {
    if (state.value == null) return;
    final current = state.value!;
    state = AsyncValue.data(
      current.map((s) => s.id == id ? ServiceOp(id: s.id, vehicleReg: s.vehicleReg, tech: s.tech, status: 'Approved') : s).toList()
    );
  }
}

final adminServicesProvider = NotifierProvider<ServiceOpsNotifier, AsyncValue<List<ServiceOp>>>(() => ServiceOpsNotifier());
