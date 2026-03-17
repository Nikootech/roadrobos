import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

enum DriverApprovalStatus { none, pending, approved, rejected }
enum DriverTripStatus { none, enroutePickup, arrived, otpVerify, started, completed }

class DriverTrip {
  final String id;
  final String passengerName;
  final String passengerPhone;
  final LatLng pickupLocation;
  final LatLng dropoffLocation;
  final String pickupAddress;
  final String dropoffAddress;
  final double fare;
  final double distance;
  final String eta;
  final DriverTripStatus status;

  DriverTrip({
    required this.id,
    required this.passengerName,
    required this.passengerPhone,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.fare,
    required this.distance,
    required this.eta,
    this.status = DriverTripStatus.none,
  });

  DriverTrip copyWith({DriverTripStatus? status}) {
    return DriverTrip(
      id: id,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      fare: fare,
      distance: distance,
      eta: eta,
      status: status ?? this.status,
    );
  }
}

class DriverState {
  final bool isOnline;
  final double todayEarnings;
  final double bonus;
  final String onlineTime;
  final int totalRides;
  final String acceptanceRate;
  final DriverApprovalStatus approvalStatus;
  final DriverTrip? currentTrip;
  final double weeklyEarnings;
  final int weeklyRides;

  DriverState({
    this.isOnline = false,
    this.todayEarnings = 1250.0,
    this.bonus = 120.0,
    this.onlineTime = '4h 30m',
    this.totalRides = 8,
    this.acceptanceRate = '95%',
    this.approvalStatus = DriverApprovalStatus.approved, // Defaulting to approved for existing demo
    this.currentTrip,
    this.weeklyEarnings = 8450.0,
    this.weeklyRides = 42,
  });

  DriverState copyWith({
    bool? isOnline,
    double? todayEarnings,
    double? bonus,
    String? onlineTime,
    int? totalRides,
    String? acceptanceRate,
    DriverApprovalStatus? approvalStatus,
    DriverTrip? currentTrip,
    double? weeklyEarnings,
    int? weeklyRides,
  }) {
    return DriverState(
      isOnline: isOnline ?? this.isOnline,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      bonus: bonus ?? this.bonus,
      onlineTime: onlineTime ?? this.onlineTime,
      totalRides: totalRides ?? this.totalRides,
      acceptanceRate: acceptanceRate ?? this.acceptanceRate,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      currentTrip: currentTrip ?? this.currentTrip,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      weeklyRides: weeklyRides ?? this.weeklyRides,
    );
  }
}

class DriverNotifier extends StateNotifier<DriverState> {
  DriverNotifier() : super(DriverState());

  void toggleOnline() {
    state = state.copyWith(isOnline: !state.isOnline);
  }

  void submitDocuments() {
    state = state.copyWith(approvalStatus: DriverApprovalStatus.pending);
  }

  void approveDriver() {
    state = state.copyWith(approvalStatus: DriverApprovalStatus.approved);
  }

  void acceptRide(DriverTrip trip) {
    state = state.copyWith(currentTrip: trip.copyWith(status: DriverTripStatus.enroutePickup));
  }

  void updateTripStatus(DriverTripStatus status) {
    if (state.currentTrip != null) {
      state = state.copyWith(currentTrip: state.currentTrip!.copyWith(status: status));
    }
  }

  void completeTrip() {
    if (state.currentTrip != null) {
      final fare = state.currentTrip!.fare;
      state = state.copyWith(
        todayEarnings: state.todayEarnings + fare,
        weeklyEarnings: state.weeklyEarnings + fare,
        totalRides: state.totalRides + 1,
        weeklyRides: state.weeklyRides + 1,
        currentTrip: null,
      );
    }
  }

  void addEarning(double amount) {
    state = state.copyWith(
      todayEarnings: state.todayEarnings + amount,
      totalRides: state.totalRides + 1,
    );
  }
}

final driverProvider = StateNotifierProvider<DriverNotifier, DriverState>((ref) {
  return DriverNotifier();
});
