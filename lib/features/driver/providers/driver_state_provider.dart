import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

enum VerificationStatus { pending, approved, rejected }

// Verification Status Provider
class VerificationNotifier extends StateNotifier<VerificationStatus> {
  VerificationNotifier() : super(VerificationStatus.pending) {
    _startMockVerification();
  }

  void _startMockVerification() {
    // Mocking a long verification, but for testing purposes we speed it up,
    // or we can expose a method to force approval.
    // The prompt says "Mock verification timer (24hrs) -> auto-approve",
    // we'll implement a 2-minute timer for actual usability, but display 24hrs.
    Timer(const Duration(minutes: 2), () {
      if (mounted) state = VerificationStatus.approved;
    });
  }

  Future<void> refreshStatus() async {
    // Simulating a pull-to-refresh network call
    await Future.delayed(const Duration(seconds: 2));
    // Random chance to approve if they pull to refresh, for interactivity
    if (DateTime.now().second % 3 == 0) {
      state = VerificationStatus.approved;
    }
  }

  void forceApprove() => state = VerificationStatus.approved;
  void forceReject() => state = VerificationStatus.rejected;
  void resubmit() => state = VerificationStatus.pending;
}

final verificationProvider = StateNotifierProvider<VerificationNotifier, VerificationStatus>((ref) {
  return VerificationNotifier();
});

// Mock Earnings Provider
class DriverEarnings {
  final double todayEarnings;
  final double bonusTarget;
  final double bonusAchieved;

  DriverEarnings({required this.todayEarnings, required this.bonusTarget, required this.bonusAchieved});
}

final earningsProvider = Provider<DriverEarnings>((ref) {
  return DriverEarnings(todayEarnings: 850.0, bonusTarget: 1050.0, bonusAchieved: 850.0);
});

// Ride Requests Provider
class RideRequest {
  final String id;
  final String riderName;
  final String distance;
  final double fare;
  final double rating;
  final String pickup;
  final String dropoff;

  RideRequest({
    required this.id,
    required this.riderName,
    required this.distance,
    required this.fare,
    required this.rating,
    required this.pickup,
    required this.dropoff,
  });
}

class RideRequestsNotifier extends StateNotifier<List<RideRequest>> {
  RideRequestsNotifier() : super([]) {
    _startSimulatedRequests();
  }

  Timer? _timer;

  void _startSimulatedRequests() {
    // Generate an initial request very quickly for demonstration
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && state.isEmpty) {
        state = [
          RideRequest(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            riderName: 'Anil K',
            distance: '2.4km',
            fare: 45.0,
            rating: 4.8,
            pickup: 'MG Road',
            dropoff: 'Koramangala',
          )
        ];
      }
    });

    // Generate a new request every 8 seconds if empty
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted && state.isEmpty) {
        state = [
          RideRequest(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            riderName: 'Priya S',
            distance: '1.2km',
            fare: 65.0,
            rating: 4.9,
            pickup: 'Indiranagar',
            dropoff: 'Domlur',
          )
        ];
      }
    });
  }

  void acceptRequest(String id) {
    state = state.where((req) => req.id != id).toList();
    // Logic for transitioning to active ride goes here
  }

  void rejectRequest(String id) {
    state = state.where((req) => req.id != id).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final rideRequestsProvider = StateNotifierProvider<RideRequestsNotifier, List<RideRequest>>((ref) {
  return RideRequestsNotifier();
});

// Mock Map State Provider (Current Location in Bengaluru)
class MapState {
  final double lat;
  final double lng;
  final bool isOnline;

  MapState({required this.lat, required this.lng, required this.isOnline});

  MapState copyWith({double? lat, double? lng, bool? isOnline}) {
    return MapState(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

class MapStateNotifier extends StateNotifier<MapState> {
  // Center of Bengaluru roughly
  MapStateNotifier() : super(MapState(lat: 12.9716, lng: 77.5946, isOnline: false));

  void toggleOnline() {
    state = state.copyWith(isOnline: !state.isOnline);
  }
}

final mapStateProvider = StateNotifierProvider<MapStateNotifier, MapState>((ref) {
  return MapStateNotifier();
});
