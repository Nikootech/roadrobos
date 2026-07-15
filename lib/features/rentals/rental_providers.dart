import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/repositories/rental_booking_repository.dart';
import '../../core/repositories/rental_catalog_repository.dart';
import '../../core/models/rental_booking.dart';
import '../../core/models/rental_vehicle.dart';
import '../profile/user_provider.dart';
import '../../core/services/payment_service.dart';

enum RentalType { hourly, daily }

enum RentalStatus { active, completed, paid }

class ActiveRental {
  final Map<String, dynamic> vehicle;
  final DateTime startTime;
  final Duration duration;
  final RentalStatus status;

  ActiveRental({
    required this.vehicle,
    required this.startTime,
    required this.duration,
    this.status = RentalStatus.active,
  });

  ActiveRental copyWith({RentalStatus? status}) {
    return ActiveRental(
      vehicle: vehicle,
      startTime: startTime,
      duration: duration,
      status: status ?? this.status,
    );
  }

  bool get isExpired => DateTime.now().isAfter(startTime.add(duration));
  Duration get remainingTime =>
      startTime.add(duration).difference(DateTime.now());
}

class ActiveRentalNotifier extends StateNotifier<ActiveRental?> {
  final Ref ref;
  ActiveRentalNotifier(this.ref) : super(null);
  Timer? _timer;

  void startRental(Map<String, dynamic> vehicle, Duration duration) {
    state = ActiveRental(
      vehicle: vehicle,
      startTime: DateTime.now(),
      duration: duration,
    );

    // Simulation: Check for expiration every minute
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (state != null &&
          state!.isExpired &&
          state!.status == RentalStatus.active) {
        state = state!.copyWith(status: RentalStatus.completed);
        timer.cancel();
      }
    });
  }

  Future<void> completePayment({
    required double totalCost,
    required PaymentService paymentService,
    String method = 'Online',
  }) async {
    if (state == null) return;

    final user = ref.read(userProvider).user;
    final custId = user?.id ?? 'demo';
    final isRealUser = custId != 'demo' && !custId.startsWith('demo');

    // Step 1: Create booking in DB with 'payment_pending' status BEFORE opening payment
    // This ensures we have a record to update/cancel if payment fails.
    String? bookingId;
    if (isRealUser) {
      try {
        bookingId = await ref.read(rentalBookingRepositoryProvider).createRentalBooking(
            RentalBooking(
                id: '',
                customerId: custId,
                vehicleName: state!.vehicle['name'] ?? 'Unknown',
                rentalType: 'hourly',
                startTime: state!.startTime,
                duration: state!.duration.inHours,
                totalCost: totalCost,
                details: {'method': method},
                status: 'payment_pending'));
      } catch (e) {
        throw Exception('Failed to create booking record: $e');
      }
    }

    // Step 2: Attempt payment
    String paymentId = 'CASH_PAYMENT';
    if (method == 'Online') {
      try {
        paymentId = await paymentService.startPayment(PaymentDetails(
          bookingId: bookingId ?? '00000000-0000-0000-0000-000000000000',
          bookingType: BookingType.rental,
          totalCost: totalCost,
          userId: custId,
          contact: user?.phone ?? '9876543210',
          email: user?.email ?? 'customer@example.com',
          description: 'Vehicle Rental Payment',
        ));
      } catch (e) {
        // Payment cancelled or failed — update booking status to 'cancelled' in DB
        if (isRealUser && bookingId != null) {
          try {
            await ref
                .read(rentalBookingRepositoryProvider)
                .updateRentalStatus(bookingId, 'cancelled');
          } catch (_) {
            // Best-effort cancel; don't mask the original payment error
          }
        }
        throw Exception('Payment flow failed: $e');
      }
    }

    // Step 3: Payment succeeded — update booking status to confirmed/paid
    if (isRealUser && bookingId != null) {
      final confirmedStatus = method == 'Online' ? 'paid' : 'confirmed';
      try {
        await ref
            .read(rentalBookingRepositoryProvider)
            .updateRentalStatus(bookingId, confirmedStatus);
        // Also update the payment_id in details
        await ref
            .read(rentalBookingRepositoryProvider)
            .updateRentalDetails(bookingId, {'method': method, 'payment_id': paymentId});
      } catch (e) {
        // Log but don't fail — payment already succeeded
        debugPrint('Warning: Could not update rental status after payment: $e');
      }
    }

    _timer?.cancel();
    _timer = null;
    state = state!.copyWith(status: method == 'Online' ? RentalStatus.paid : RentalStatus.active);
  }

  void clearRental() {
    _timer?.cancel();
    _timer = null;
    state = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

final selectedRentalTypeProvider =
    StateProvider<RentalType>((ref) => RentalType.hourly);
final selectedVehicleProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

final activeRentalProvider =
    StateNotifierProvider<ActiveRentalNotifier, ActiveRental?>(
        (ref) => ActiveRentalNotifier(ref));

class RecentlyViewedNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  RecentlyViewedNotifier() : super([]);

  void addView(Map<String, dynamic> vehicle) {
    final existingIndex = state.indexWhere((v) => v['name'] == vehicle['name']);

    List<Map<String, dynamic>> newState = List.from(state);
    if (existingIndex != -1) {
      newState.removeAt(existingIndex);
    }

    newState.insert(0, vehicle);

    // Cap at 10 items
    if (newState.length > 10) {
      newState = newState.sublist(0, 10);
    }

    state = newState;
  }

  void clearHistory() => state = [];
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<Map<String, dynamic>>>(
        (ref) {
  return RecentlyViewedNotifier();
});

final rentalPriceProvider = Provider<String>((ref) {
  final vehicle = ref.watch(selectedVehicleProvider);
  final type = ref.watch(selectedRentalTypeProvider);

  if (vehicle == null) return '₹0';

  if (type == RentalType.hourly) {
    return (vehicle['price'] ?? '₹150').toString();
  } else {
    final hourly = int.tryParse(
            (vehicle['price'] as String).replaceAll(RegExp(r'[^0-9]'), '')) ??
        150;
    return '₹${hourly * 6}';
  }
});

/// Selected pickup location for rental booking
/// Stores {'name': 'Location Name', 'address': 'Full Address', 'lat': 0.0, 'lng': 0.0}
final rentalPickupLocationProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

/// Selected drop-off location for rental booking
final rentalDropoffLocationProvider =
    StateProvider<Map<String, dynamic>?>((ref) => null);

final rentalCatalogProvider = FutureProvider<List<RentalVehicle>>((ref) async {
  return ref.watch(rentalCatalogRepositoryProvider).getRentalFleet();
});

/// Fetch a single vehicle by its Supabase UUID.
/// Used by the /rental-detail/:id route to load the detail screen
/// without relying on MockData or name-slug lookups.
final rentalVehicleByIdProvider =
    FutureProvider.family<RentalVehicle?, String>((ref, id) async {
  if (id.isEmpty) return null;
  return ref.read(rentalCatalogRepositoryProvider).fetchVehicleById(id);
});
