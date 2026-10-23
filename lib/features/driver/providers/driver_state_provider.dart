// IMPORTANT: All StreamSubscription fields must be cancelled in dispose/onDispose.

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/repositories/driver_repository.dart';
import '../../../features/profile/user_provider.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/models/ride_booking.dart';
import '../../../core/models/user_role.dart';
import '../../../core/repositories/user_repository.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/osm_maps_service.dart';
import 'package:latlong2/latlong.dart';

enum VerificationStatus { pending, approved, rejected }

// Current Driver Model Provider (Stream-based)
final currentDriverProvider = StreamProvider<DriverModel?>((ref) {
  final user = ref.watch(userProvider);
  final uid = user.user?.id;
  if (uid == null || uid.isEmpty) return Stream.value(null);
  return ref.watch(driverRepositoryProvider).watchDriver(uid);
});

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

// Production Driver Earnings Provider (Dynamic database stats)
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
        .map((r) {
          final prefix = r.customerId.length >= 4
              ? r.customerId.substring(0, 4)
              : (r.customerId.isNotEmpty ? r.customerId : 'User');
          return RideRequest(
            id: r.id,
            riderName: 'Customer $prefix',
            distance: 'Calculating...',
            fare: r.fare,
            rating: 4.8,
            pickup: r.pickupAddress,
            dropoff: r.destinationAddress,
          );
        })
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
                booking.status != 'completed' && booking.status != 'cancelled');
        return activeRides.isNotEmpty ? activeRides.first : null;
      });
});

// Stream of passenger/customer profile
final passengerProfileProvider =
    StreamProvider.family<AppUser?, String>((ref, customerId) {
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

// Map State Provider (Rewired to real-time location and reverse geocoded address)
class MapState {
  final double lat;
  final double lng;
  final bool isOnline;
  final String currentAddress;
  final bool isFetchingAddress;

  MapState({
    required this.lat,
    required this.lng,
    required this.isOnline,
    this.currentAddress = 'Detecting current address...',
    this.isFetchingAddress = false,
  });

  MapState copyWith({
    double? lat,
    double? lng,
    bool? isOnline,
    String? currentAddress,
    bool? isFetchingAddress,
  }) {
    return MapState(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isOnline: isOnline ?? this.isOnline,
      currentAddress: currentAddress ?? this.currentAddress,
      isFetchingAddress: isFetchingAddress ?? this.isFetchingAddress,
    );
  }
}

class MapStateNotifier extends StateNotifier<MapState> {
  final Ref ref;
  StreamSubscription? _driverSubscription;

  MapStateNotifier(this.ref)
      : super(MapState(
          lat: 12.9716,
          lng: 77.5946,
          isOnline: false,
          currentAddress: 'Bangalore, Karnataka',
        )) {
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
        final newLat = driver.currentPosition?.latitude ?? state.lat;
        final newLng = driver.currentPosition?.longitude ?? state.lng;
        final posChanged = (newLat != state.lat || newLng != state.lng);
        state = state.copyWith(
          isOnline: driver.isOnline,
          lat: newLat,
          lng: newLng,
        );
        if (posChanged || state.currentAddress == 'Bangalore, Karnataka') {
          reverseGeocodeAddress(newLat, newLng);
        }
      }
    });

    fetchDeviceLocation();
  }

  Future<void> fetchDeviceLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await reverseGeocodeAddress(state.lat, state.lng);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          await reverseGeocodeAddress(state.lat, state.lng);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      if (mounted) {
        state = state.copyWith(lat: position.latitude, lng: position.longitude);
        await reverseGeocodeAddress(position.latitude, position.longitude);
      }
    } catch (e) {
      debugPrint('Error fetching device position: $e');
      if (mounted) {
        await reverseGeocodeAddress(state.lat, state.lng);
      }
    }
  }

  Future<void> reverseGeocodeAddress(double lat, double lng) async {
    if (!mounted) return;
    state = state.copyWith(isFetchingAddress: true);
    try {
      final address = await OSMMapsService().getAddressFromCoords(LatLng(lat, lng));
      if (mounted) {
        if (address != null && address.trim().isNotEmpty) {
          state = state.copyWith(
            currentAddress: address.trim(),
            isFetchingAddress: false,
          );
        } else {
          state = state.copyWith(
            currentAddress: '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
            isFetchingAddress: false,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        state = state.copyWith(
          currentAddress: '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
          isFetchingAddress: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _driverSubscription?.cancel();
    super.dispose();
  }

  Future<void> toggleOnline() async {
    final user = ref.read(userProvider);
    final driverId = user.user?.id ?? 'demo';

    final newStatus = !state.isOnline;

    if (newStatus) {
      await fetchDeviceLocation();
    }

    await ref.read(driverRepositoryProvider).updateOnlineStatus(
          driverId,
          newStatus,
          position: LatLng(state.lat, state.lng),
        );

    if (newStatus) {
      final token = await ref.read(notificationServiceProvider).getToken();
      if (token != null) {
        await ref
            .read(driverRepositoryProvider)
            .updateFcmToken(driverId, token);
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
