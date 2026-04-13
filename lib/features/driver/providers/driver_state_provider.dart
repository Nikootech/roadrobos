import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/repositories/driver_repository.dart';
import '../../../core/repositories/ride_booking_repository.dart';
import '../../../features/profile/user_provider.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/models/ride_booking.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/notification_service.dart';

enum VerificationStatus { pending, approved, rejected }

// Verification Status Provider (Stream-based)
final verificationProvider = StreamProvider<VerificationStatus>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return Stream.value(VerificationStatus.pending);

  return ref.watch(driverRepositoryProvider).watchDriver(user.user?.id ?? 'demo').map((driver) {
    if (driver == null) return VerificationStatus.pending;
    switch (driver.approvalStatus) {
      case DriverApprovalStatus.approved: return VerificationStatus.approved;
      case DriverApprovalStatus.rejected: return VerificationStatus.rejected;
      default: return VerificationStatus.pending;
    }
  });
});

// Wrapper Notifier for Verification Actions
class VerificationActionNotifier extends StateNotifier<void> {
  final Ref ref;
  VerificationActionNotifier(this.ref) : super(null);

  Future<void> updateStatus(DriverApprovalStatus status) async {
    final user = ref.read(userProvider);
    if (user == null) return;
    await ref.read(driverRepositoryProvider).updateDriver(user.user?.id ?? 'demo', {
      'approval_status': status.toString().split('.').last,
    });
  }
}

final verificationActionProvider = StateNotifierProvider<VerificationActionNotifier, void>((ref) {
  return VerificationActionNotifier(ref);
});

// Mock Earnings Provider (Rewired to real driver stats)
class DriverEarnings {
  final double todayEarnings;
  final double bonusTarget;
  final double bonusAchieved;

  DriverEarnings({required this.todayEarnings, required this.bonusTarget, required this.bonusAchieved});
}

final earningsProvider = StreamProvider<DriverEarnings>((ref) {
  final user = ref.watch(userProvider);
  if (user == null) return Stream.value(DriverEarnings(todayEarnings: 0, bonusTarget: 1000, bonusAchieved: 0));

  return ref.watch(driverRepositoryProvider).watchDriver(user.user?.id ?? 'demo').map((driver) {
    return DriverEarnings(
      todayEarnings: driver?.todayEarnings ?? 0.0,
      bonusTarget: 1050.0,
      bonusAchieved: (driver?.todayEarnings ?? 0.0) % 1050,
    );
  });
});

// Ride Requests Provider (Real-time Firestore stream)
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

final rideRequestsProvider = StreamProvider<List<RideRequest>>((ref) {
  return ref.watch(driverRepositoryProvider).watchPendingRides().map((rides) {
    return rides.map((r) => RideRequest(
      id: r.id,
      riderName: 'Customer ${r.customerId.substring(0, 4)}',
      distance: 'Calculating...', 
      fare: r.fare,
      rating: 4.8,
      pickup: r.pickupAddress,
      dropoff: r.dropAddress,
    )).toList();
  });
});

// Wrapper Notifier to handle Actions (Accept/Reject)
class RideRequestsActionNotifier extends StateNotifier<void> {
  final Ref ref;
  RideRequestsActionNotifier(this.ref) : super(null);

  Future<void> acceptRequest(String id) async {
    final user = ref.read(userProvider);
    if (user == null) return;
    await ref.read(driverRepositoryProvider).acceptRide(id, user.user?.id ?? 'demo');
  }

  Future<void> rejectRequest(String id) async {
    // In a real app, we might mark this ride as "skipped" for this driver in a subcollection
    // For now, we just clear it from local UI if it were a local state, 
    // but Since it's a StreamProvider, it will stay unless filtered.
  }
}

final rideRequestsActionProvider = StateNotifierProvider<RideRequestsActionNotifier, void>((ref) {
  return RideRequestsActionNotifier(ref);
});

// Mock Map State Provider (Rewired to online status)
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
  final Ref ref;
  MapStateNotifier(this.ref) : super(MapState(lat: 12.9716, lng: 77.5946, isOnline: false)) {
    _init();
  }

  void _init() {
    final user = ref.read(userProvider);
    if (user != null) {
      ref.listen(driverRepositoryProvider.select((repo) => repo.watchDriver(user.user?.id ?? 'demo')), (prev, next) {
        next.listen((driver) {
          if (driver != null && mounted) {
            state = state.copyWith(
              isOnline: driver.isOnline,
              lat: driver.currentPosition?.latitude,
              lng: driver.currentPosition?.longitude,
            );
          }
        });
      });
    }
  }

  Future<void> toggleOnline() async {
    final user = ref.read(userProvider);
    if (user == null) return;
    
    final newStatus = !state.isOnline;
    await ref.read(driverRepositoryProvider).updateOnlineStatus(user.user?.id ?? 'demo', newStatus);
    
    if (newStatus) {
      // Sync FCM token when going online
      final token = await NotificationService().getToken();
      if (token != null) {
        await ref.read(driverRepositoryProvider).updateFcmToken(user.user?.id ?? 'demo', token);
      }
    }

    if (mounted) state = state.copyWith(isOnline: newStatus);
  }
}

final mapStateProvider = StateNotifierProvider<MapStateNotifier, MapState>((ref) {
  return MapStateNotifier(ref);
});

