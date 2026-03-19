import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- Models ---
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

// --- Providers ---

final customersOpProvider = StreamProvider<CustomerOp>((ref) async* {
  yield CustomerOp(12, 5, 3, [
    CustomerRide('B1042', 'Arjun K.', 'Ride: Sedan', 'Active', '14:30'),
    CustomerRide('S204', 'Neha S.', 'Service: Swift', 'Scheduled', '15:00'),
    CustomerRide('R9021', 'Priya D.', 'Rental: Innova', 'Active', '09:00'),
  ]);
});

class DriversOpNotifier extends Notifier<AsyncValue<DriverOp>> {
  @override
  AsyncValue<DriverOp> build() {
    _init();
    return const AsyncValue.loading();
  }

  void _init() async {
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data(DriverOp(8, 4, 156, [
      PendingDriver('D11', 'Rajesh S.', 'Oct 24', 4),
      PendingDriver('D12', 'Vikas P.', 'Oct 24', 2),
      PendingDriver('D13', 'Arun M.', 'Oct 23', 3),
    ]));
  }

  void approve(String id) {
    if (state.value == null) return;
    final current = state.value!;
    final newPending = current.topPending.where((d) => d.id != id).toList();
    state = AsyncValue.data(DriverOp(current.online + 1, current.pending - 1, current.total, newPending));
  }
}
final driversOpProvider = NotifierProvider<DriversOpNotifier, AsyncValue<DriverOp>>(() => DriversOpNotifier());

final techOpProvider = StreamProvider<TechOp>((ref) async* {
  yield TechOp(7, 3, 15, [
    ServiceJob('MH02AB1234', 'Unassigned', 'Scheduled', 4500),
    ServiceJob('TS09GH2345', 'Rajesh (T04)', 'In Progress', 1200),
    ServiceJob('KA05EF6789', 'Karan (T12)', 'Completed', 8500),
  ]);
});
