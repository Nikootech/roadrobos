// IMPORTANT: All StreamSubscription fields must be cancelled in dispose/onDispose.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/repositories/driver_repository.dart';
import '../../../features/profile/user_provider.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/models/ride_booking.dart';
import '../../../core/models/user_role.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/services/notification_service.dart';

enum VerificationStatus { pending, approved, rejected }

// Verification Status Provider (Stream-based)
final verificationProvider = StreamProvider<VerificationStatus>((ref) {
  final user = ref.watch(userProvider);

  return ref
      .watch(driverRepositoryProvider)
      .watchDriver(user.user?.id ?? 'demo')
      .map((driver) {
    if (driver == null) return VerificationStatus.pending;
    switch (driver.approvalStatus) {
      case DriverApprovalStatus.approved:
        return VerificationStatus.approved;
      case DriverApprovalStatus.rejected:
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.pending;
    }
  });
});

// Wrapper Notifier for Verification Actions
class VerificationActionNotifier extends StateNotifier<void> {
  final Ref ref;
  VerificationActionNotifier(this.ref) : super(null);

  Future<void> updateStatus(DriverApprovalStatus status) async {
    final user = ref.read(userProvider);
    await ref
        .read(driverRepositoryProvider)
        .updateDriver(user.user?.id ?? 'demo', {
      'approval_status': status.toString().split('.').last,
    });
  }
}

final verificationActionProvider =
    StateNotifierProvider<VerificationActionNotifier, void>((ref) {
  return VerificationActionNotifier(ref);
});

// Mock Earnings Provider (Rewired to real driver stats)
class DriverEarnings {
  final double todayEarnings;
  final double weeklyEarnings;
  final double bonusTarget;
  final double bonusAchieved;
  final int totalRides;
  final int weeklyRides;
  final String onlineTime;
  final String acceptanceRate;

  DriverEarnings({
    required this.todayEarnings,
    required this.weeklyEarnings,
    required this.bonusTarget,
    required this.bonusAchieved,
    required this.totalRides,
    required this.weeklyRides,
    required this.onlineTime,
    required this.acceptanceRate,
  });
}

final earningsProvider = StreamProvider<DriverEarnings>((ref) {
  final user = ref.watch(userProvider);

  return ref
      .watch(driverRepositoryProvider)
      .watchDriver(user.user?.id ?? 'demo')
      .map((driver) {
    return DriverEarnings(
      todayEarnings: driver?.todayEarnings ?? 0.0,
      weeklyEarnings: driver?.weeklyEarnings ?? 0.0,
      bonusTarget: 1050.0,
      bonusAchieved: (driver?.todayEarnings ?? 0.0) % 1050,
      totalRides: driver?.totalRides ?? 0,
      weeklyRides: driver?.weeklyRides ?? 0,
      onlineTime: driver?.onlineTime ?? '0h',
      acceptanceRate: driver?.acceptanceRate ?? '100%',
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
    return rides
        .map((r) => RideRequest(
              id: r.id,
              riderName: 'Customer ${r.customerId.substring(0, 4)}',
              distance: 'Calculating...',
              fare: r.fare,
              rating: 4.8,
              pickup: r.pickupAddress,
              dropoff: r.destinationAddress,
            ))
        .toList();
  });
});

// Stream of the driver's active trip from Supabase
final driverActiveTripProvider = StreamProvider<RideBooking?>((ref) {
  final user = ref.watch(userProvider);
  final driverId = user.user?.id ?? 'demo';

  if (driverId == 'demo') {
    return Stream.value(null);
  }

  return Supabase.instance.client
      .from('ride_bookings')
      .stream(primaryKey: ['id'])
      .eq('driver_id', driverId)
      .map((list) {
        final activeRides = list
            .map((map) => RideBooking.fromMap(map, map['id'].toString()))
            .where((booking) =>
                booking.status != 'completed' &&
                booking.status != 'cancelled');
        return activeRides.isNotEmpty ? activeRides.first : null;
      });
});

// Stream of passenger/customer profile
final passengerProfileProvider = StreamProvider.family<AppUser?, String>((ref, customerId) {
  return ref.watch(userRepositoryProvider).getUserStream(customerId);
});

// Wrapper Notifier to handle Actions (Accept/Reject)
class RideRequestsActionNotifier extends StateNotifier<void> {
  final Ref ref;
  RideRequestsActionNotifier(this.ref) : super(null);

  Future<void> acceptRequest(String id) async {
    final user = ref.read(userProvider);
    await ref
        .read(driverRepositoryProvider)
        .acceptRide(id, user.user?.id ?? 'demo');
  }

  Future<void> rejectRequest(String id) async {
    // In a real app, we might mark this ride as "skipped" for this driver in a subcollection
    // For now, we just clear it from local UI if it were a local state,
    // but Since it's a StreamProvider, it will stay unless filtered.
  }
}

final rideRequestsActionProvider =
    StateNotifierProvider<RideRequestsActionNotifier, void>((ref) {
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
  StreamSubscription? _driverSubscription;

  MapStateNotifier(this.ref)
      : super(MapState(lat: 12.9716, lng: 77.5946, isOnline: false)) {
    _init();
  }

  void _init() {
    final user = ref.read(userProvider);
    final driverId = user.user?.id ?? 'demo';
    _driverSubscription?.cancel();
    _driverSubscription = ref
        .read(driverRepositoryProvider)
        .watchDriver(driverId)
        .listen((driver) {
      if (driver != null && mounted) {
        state = state.copyWith(
          isOnline: driver.isOnline,
          lat: driver.currentPosition?.latitude,
          lng: driver.currentPosition?.longitude,
        );
      }
    });
  }

  @override
  void dispose() {
    _driverSubscription?.cancel();
    super.dispose();
  }

  Future<void> toggleOnline() async {
    final user = ref.read(userProvider);

    final newStatus = !state.isOnline;
    await ref
        .read(driverRepositoryProvider)
        .updateOnlineStatus(user.user?.id ?? 'demo', newStatus);

    if (newStatus) {
      // Sync FCM token when going online
      final token = await ref.read(notificationServiceProvider).getToken();
      if (token != null) {
        await ref
            .read(driverRepositoryProvider)
            .updateFcmToken(user.user?.id ?? 'demo', token);
      }
    }

    if (mounted) state = state.copyWith(isOnline: newStatus);
  }
}

final mapStateProvider =
    StateNotifierProvider<MapStateNotifier, MapState>((ref) {
  ref.watch(userProvider);
  return MapStateNotifier(ref);
});
