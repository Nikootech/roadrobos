// lib/features/delivery/delivery_providers.dart
// Riverpod providers for the delivery module.

// IMPORTANT: All StreamSubscription fields must be cancelled in dispose/onDispose.

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../core/models/delivery_order.dart';
import '../../core/repositories/delivery_repository.dart';
import '../profile/user_provider.dart';

// ── Pricing helper ────────────────────────────────────────────────────────────
/// Base ₹50 + ₹5/kg + distance factor (estimated 0.5–10 km → ₹10–₹80 range).
double calculateDeliveryPrice(double weightKg, {double distanceKm = 5.0}) {
  const base = 50.0;
  const perKg = 5.0;
  const perKm = 8.0;
  return base + (perKg * weightKg) + (perKm * distanceKm);
}

// ── Customer order form state ─────────────────────────────────────────────────
class DeliveryFormState {
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;
  final String pickupAddress;
  final String dropoffAddress;
  final String packageDescription;
  final double weightKg;
  final double estimatedDistanceKm;
  final bool isSubmitting;
  final String? error;
  final DeliveryOrder? createdOrder;

  const DeliveryFormState({
    this.pickupLocation,
    this.dropoffLocation,
    this.pickupAddress = '',
    this.dropoffAddress = '',
    this.packageDescription = '',
    this.weightKg = 1.0,
    this.estimatedDistanceKm = 5.0,
    this.isSubmitting = false,
    this.error,
    this.createdOrder,
  });

  double get estimatedPrice =>
      calculateDeliveryPrice(weightKg, distanceKm: estimatedDistanceKm);

  DeliveryFormState copyWith({
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
    String? pickupAddress,
    String? dropoffAddress,
    String? packageDescription,
    double? weightKg,
    double? estimatedDistanceKm,
    bool? isSubmitting,
    String? error,
    DeliveryOrder? createdOrder,
    bool clearError = false,
    bool clearOrder = false,
  }) {
    return DeliveryFormState(
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      packageDescription: packageDescription ?? this.packageDescription,
      weightKg: weightKg ?? this.weightKg,
      estimatedDistanceKm: estimatedDistanceKm ?? this.estimatedDistanceKm,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      createdOrder: clearOrder ? null : (createdOrder ?? this.createdOrder),
    );
  }
}

class DeliveryOrderNotifier extends StateNotifier<DeliveryFormState> {
  final Ref ref;
  DeliveryOrderNotifier(this.ref) : super(const DeliveryFormState());

  void setPickup(LatLng? location, String address) {
    state = state.copyWith(
        pickupLocation: location, pickupAddress: address, clearError: true);
    _calculateDistance();
  }

  void setDropoff(LatLng? location, String address) {
    state = state.copyWith(
        dropoffLocation: location, dropoffAddress: address, clearError: true);
    _calculateDistance();
  }

  void _calculateDistance() {
    if (state.pickupLocation != null && state.dropoffLocation != null) {
      const distanceCalc = Distance();
      final double meters = distanceCalc.as(
          LengthUnit.Meter, state.pickupLocation!, state.dropoffLocation!);
      final distanceKm = meters / 1000.0;
      state = state.copyWith(estimatedDistanceKm: distanceKm);
    }
  }

  void setDescription(String desc) =>
      state = state.copyWith(packageDescription: desc, clearError: true);
  void setWeight(double kg) => state = state.copyWith(weightKg: kg);
  void setDistance(double km) =>
      state = state.copyWith(estimatedDistanceKm: km);

  Future<DeliveryOrder?> submitOrder() async {
    final s = state;
    if (s.pickupAddress.isEmpty || s.dropoffAddress.isEmpty) {
      state =
          state.copyWith(error: 'Please fill pickup and dropoff addresses.');
      return null;
    }
    if (s.packageDescription.isEmpty) {
      state = state.copyWith(error: 'Please describe your package.');
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    final user = ref.read(userProvider).user;
    try {
      final order = DeliveryOrder(
        id: '',
        customerId: user?.id ?? 'demo',
        pickupAddress: s.pickupAddress,
        dropoffAddress: s.dropoffAddress,
        packageDescription: s.packageDescription,
        weightKg: s.weightKg,
        status: DeliveryStatus.pending,
        estimatedPrice: s.estimatedPrice,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final created =
          await ref.read(deliveryRepositoryProvider).createOrder(order);
      state = state.copyWith(isSubmitting: false, createdOrder: created);
      return created;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  void reset() => state = const DeliveryFormState();
}

/// Customer: drive form + create order
final deliveryOrderProvider =
    StateNotifierProvider<DeliveryOrderNotifier, DeliveryFormState>(
        (ref) => DeliveryOrderNotifier(ref));

// Helper to validate UUID format before calling Supabase streams
bool _isValidUuid(String? id) {
  if (id == null) return false;
  final regExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  return regExp.hasMatch(id);
}

// ── Customer: real-time order tracking ───────────────────────────────────────
final deliveryTrackingProvider =
    StreamProvider.family<DeliveryOrder?, String>((ref, orderId) {
  if (!_isValidUuid(orderId)) {
    return const Stream.empty();
  }
  return ref.watch(deliveryRepositoryProvider).streamOrderUpdates(orderId);
});

final deliveryDriverLocationProvider =
    StreamProvider.family<Map<String, double>?, String>((ref, driverId) {
  if (!_isValidUuid(driverId)) {
    return const Stream.empty();
  }
  return ref.watch(deliveryRepositoryProvider).streamDriverLocation(driverId);
});

// ── Driver: incoming pending requests ────────────────────────────────────────
final pendingDeliveryRequestsProvider =
    StreamProvider<List<DeliveryOrder>>((ref) {
  return ref.watch(deliveryRepositoryProvider).streamPendingOrders();
});

// ── Driver: active delivery (currently accepted / in progress) ───────────────
class ActiveDeliveryNotifier extends StateNotifier<DeliveryOrder?> {
  final Ref ref;
  final String? driverId;
  StreamSubscription<DeliveryOrder?>? _sub;

  ActiveDeliveryNotifier(this.ref, this.driverId) : super(null) {
    _init();
  }

  void _init() {
    if (driverId == null || !_isValidUuid(driverId)) {
      state = null;
      return;
    }
    _sub?.cancel();
    _sub = ref
        .read(deliveryRepositoryProvider)
        .streamDriverActiveOrder(driverId!)
        .listen((order) {
      if (mounted) state = order;
    });
  }

  /// Accept a pending delivery request
  Future<void> acceptDelivery(DeliveryOrder order) async {
    if (driverId == null || !_isValidUuid(driverId)) {
      throw Exception('Cannot accept delivery: Driver ID is invalid or missing.');
    }
    await ref.read(deliveryRepositoryProvider).acceptOrder(order.id, driverId!);
  }

  /// Mark as picked up
  Future<void> markPickedUp() async {
    if (state == null) return;
    await ref
        .read(deliveryRepositoryProvider)
        .updateStatus(state!.id, DeliveryStatus.pickedUp);
  }

  /// Mark in transit
  Future<void> markInTransit() async {
    if (state == null) return;
    await ref
        .read(deliveryRepositoryProvider)
        .updateStatus(state!.id, DeliveryStatus.inTransit);
  }

  /// Open camera → upload proof → mark delivered
  Future<String?> markDeliveredWithProof() async {
    if (state == null) return null;
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1280,
    );
    if (picked == null) return null;

    final url = await ref
        .read(deliveryRepositoryProvider)
        .uploadProof(state!.id, File(picked.path));
    return url;
  }

  /// Cancel current delivery
  Future<void> cancelDelivery() async {
    if (state == null) return;
    await ref
        .read(deliveryRepositoryProvider)
        .updateStatus(state!.id, DeliveryStatus.cancelled);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final activeDeliveryProvider =
    StateNotifierProvider<ActiveDeliveryNotifier, DeliveryOrder?>((ref) {
  final user = ref.watch(userProvider).user;
  return ActiveDeliveryNotifier(ref, user?.id);
});

/// Set of delivery order IDs that this driver has locally declined/ignored
final declinedOrderIdsProvider = StateProvider<Set<String>>((ref) => {});
