import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

enum RideStatus { idle, searching, headingToPickup, headingToDropoff, completed }

class SelectedRide {
  final String name;
  final String price;
  final String eta;
  final String icon; // Icon name/path

  SelectedRide({
    required this.name,
    required this.price,
    required this.eta,
    required this.icon,
  });
}

class TaxiState {
  final RideStatus status;
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;
  final SelectedRide? selectedRide;
  final String? pickupAddress;
  final String? dropoffAddress;

  TaxiState({
    this.status = RideStatus.idle,
    this.pickupLocation = const LatLng(12.9716, 77.5946), // Default to mock Bangalore
    this.dropoffLocation,
    this.selectedRide,
    this.pickupAddress = '80, 5th Main Rd, HSR Layout', 
    this.dropoffAddress,
  });

  TaxiState copyWith({
    RideStatus? status,
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
    SelectedRide? selectedRide,
    String? pickupAddress,
    String? dropoffAddress,
  }) {
    return TaxiState(
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      selectedRide: selectedRide ?? this.selectedRide,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
    );
  }
}

class TaxiNotifier extends StateNotifier<TaxiState> {
  TaxiNotifier() : super(TaxiState());

  void setPickup(LatLng location, String address) {
    state = state.copyWith(pickupLocation: location, pickupAddress: address);
  }

  void setDropoff(LatLng location, String address) {
    state = state.copyWith(dropoffLocation: location, dropoffAddress: address);
  }

  void selectRide(SelectedRide ride) {
    state = state.copyWith(selectedRide: ride);
  }

  void updateStatus(RideStatus status) {
    state = state.copyWith(status: status);
  }

  void reset() {
    state = TaxiState();
  }
}

final taxiProvider = StateNotifierProvider<TaxiNotifier, TaxiState>((ref) {
  return TaxiNotifier();
});
