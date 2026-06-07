// lib/features/delivery/delivery_providers.dart
// Riverpod providers for the delivery module.

// IMPORTANT: All StreamSubscription fields must be cancelled in dispose/onDispose.

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  final String pickupAddress;
  final String dropoffAddress;
  final String packageDescription;
  final double weightKg;
  final double estimatedDistanceKm;
  final bool isSubmitting;
  final String? error;
  final DeliveryOrder? createdOrder;

  const DeliveryFormState({
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

  void setPickup(String address) =>
      state = state.copyWith(pickupAddress: address, clearError: true);
  void setDropoff(String address) =>
      state = state.copyWith(dropoffAddress: address, clearError: true);
  void setDescription(String desc) =>
      state = state.copyWith(packageDescription: desc, clearError: true);
  void setWeight(double kg) => state = state.copyWith(weightKg: kg);
  void setDistance(double km) => state = state.copyWith(estimatedDistanceKm: km);

  Future<DeliveryOrder?> submitOrder() async {
    final s = state;
    if (s.pickupAddress.isEmpty || s.dropoffAddress.isEmpty) {
      state = state.copyWith(error: 'Please fill pickup and dropoff addresses.');
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
      final created = await ref.read(deliveryRepositoryProvider).createOrder(order);
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

// ── Customer: real-time order tracking ───────────────────────────────────────
final deliveryTrackingProvider =
    StreamProvider.family<DeliveryOrder?, String>((ref, orderId) {
  return ref.watch(deliveryRepositoryProvider).streamOrderUpdates(orderId);
});

final deliveryDriverLocationProvider =
    StreamProvider.family<Map<String, double>?, String>((ref, driverId) {
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
  StreamSubscription<DeliveryOrder?>? _sub;

  ActiveDeliveryNotifier(this.ref) : super(null) {
    _init();
  }

  void _init() {
    final user = ref.read(userProvider).user;
    final driverId = user?.id ?? 'demo';
    _sub?.cancel();
    _sub = ref
        .read(deliveryRepositoryProvider)
        .streamDriverActiveOrder(driverId)
        .listen((order) {
      if (mounted) state = order;
    });
  }

  /// Accept a pending delivery request
  Future<void> acceptDelivery(DeliveryOrder order) async {
    final user = ref.read(userProvider).user;
    final driverId = user?.id ?? 'demo';
    await ref.read(deliveryRepositoryProvider).acceptOrder(order.id, driverId);
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
    StateNotifierProvider<ActiveDeliveryNotifier, DeliveryOrder?>(
        (ref) => ActiveDeliveryNotifier(ref));
