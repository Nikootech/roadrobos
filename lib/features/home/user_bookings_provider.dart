import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/repositories/service_booking_repository.dart';
import '../../core/repositories/ride_booking_repository.dart';
import '../../core/repositories/rental_booking_repository.dart';
import '../../core/repositories/wallet_repository.dart';
import '../../core/models/service_booking.dart';
import '../../core/models/ride_booking.dart';
import '../../core/models/rental_booking.dart';
import '../profile/user_provider.dart';
import 'package:intl/intl.dart';

enum BookingType { service, ride, rental }

class UnifiedBookingItem {
  final String id;
  final String title;
  final String subtitle;
  final String status;
  final String date;
  final String price;
  final BookingType type;
  final DateTime createdAt;
  final dynamic originalObject;
  final String? pickupAddress;
  final String? destinationAddress;
  final String? vehicleType;
  final String? paymentMethod;

  UnifiedBookingItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.date,
    required this.price,
    required this.type,
    required this.createdAt,
    required this.originalObject,
    this.pickupAddress,
    this.destinationAddress,
    this.vehicleType,
    this.paymentMethod,
  });
}

final userBookingsProvider =
    FutureProvider<List<UnifiedBookingItem>>((ref) async {
  final userState = ref.watch(userProvider);
  final user = userState.user;
  if (user == null || user.id.isEmpty) return [];

  final userId = user.id;

  try {
    final serviceBookingsFuture = ref
        .read(serviceBookingRepositoryProvider)
        .getPagedCustomerServiceBookings(userId, limit: 50);

    final rideBookingsFuture = ref
        .read(rideBookingRepositoryProvider)
        .getPagedCustomerRides(userId, limit: 50);

    final rentalBookingsFuture = ref
        .read(rentalBookingRepositoryProvider)
        .getPagedCustomerRentals(userId, limit: 50);

    final results = await Future.wait([
      serviceBookingsFuture,
      rideBookingsFuture,
      rentalBookingsFuture,
    ]);

    final serviceBookings = results[0] as List<ServiceBooking>;
    final rideBookings = results[1] as List<RideBooking>;
    final rentalBookings = results[2] as List<RentalBooking>;

    final List<UnifiedBookingItem> items = [];

    // Map ServiceBookings (excluding pre-production demo testing records)
    for (final sb in serviceBookings) {
      if (sb.createdAt.isBefore(DateTime(2026, 8)) ||
          sb.id.toLowerCase().contains('demo') ||
          sb.id.toLowerCase().contains('test') ||
          sb.packageName.toLowerCase().contains('demo')) {
        continue;
      }
      items.add(UnifiedBookingItem(
        id: sb.id,
        title: sb.packageName.isNotEmpty ? sb.packageName : 'General Service',
        subtitle: '${sb.vehicleName} • ${sb.vehiclePlate}',
        status: sb.status,
        date: sb.date.isNotEmpty
            ? sb.date
            : DateFormat('dd MMM yyyy, hh:mm a').format(sb.createdAt),
        price: '₹${sb.totalCost.round()}',
        type: BookingType.service,
        createdAt: sb.createdAt,
        originalObject: sb,
        pickupAddress: sb.address ?? 'Customer Location',
        destinationAddress: 'RoadRobos Service Center',
        vehicleType: sb.vehicleName,
        paymentMethod: sb.details['method']?.toString() ?? 'Online',
      ));
    }

    // Map RideBookings (excluding pre-production demo testing records)
    final now = DateTime.now().toUtc();
    for (final rb in rideBookings) {
      if (rb.createdAt.isBefore(DateTime(2026, 8)) ||
          rb.id.toLowerCase().contains('demo') ||
          rb.id.toLowerCase().contains('test') ||
          rb.pickupAddress.toLowerCase().contains('demo') ||
          rb.destinationAddress.toLowerCase().contains('demo')) {
        continue;
      }
      final isUnassigned = rb.driverId == null || rb.driverId!.isEmpty;
      final isSearchingOrPaid = rb.status == 'searching' ||
          rb.status == 'paid' ||
          rb.status == 'pending';
      final ageSeconds = now.difference(rb.createdAt.toUtc()).inSeconds;

      String displayStatus = rb.status;
      // If user booked a ride and driver was never assigned within 90s,
      // auto-cancel it and show as CANCELLED to the customer.
      if (isUnassigned && isSearchingOrPaid && ageSeconds > 90) {
        displayStatus = 'cancelled';
        unawaited(ref.read(rideBookingRepositoryProvider).cancelBooking(rb.id));
      }

      items.add(UnifiedBookingItem(
        id: rb.id,
        title: rb.vehicleType != null
            ? '${rb.vehicleType!.toUpperCase()} Ride'
            : 'Taxi Ride',
        subtitle: '${rb.pickupAddress} ➔ ${rb.destinationAddress}',
        status: displayStatus,
        date: DateFormat('dd MMM yyyy, hh:mm a').format(rb.createdAt),
        price: '₹${rb.fare.round()}',
        type: BookingType.ride,
        createdAt: rb.createdAt,
        originalObject: rb,
        pickupAddress: rb.pickupAddress,
        destinationAddress: rb.destinationAddress,
        vehicleType: rb.vehicleType,
        paymentMethod: rb.paymentMethod,
      ));
    }

    // Map RentalBookings (excluding pre-production demo testing records)
    for (final rnb in rentalBookings) {
      if (rnb.startTime.isBefore(DateTime(2026, 8)) ||
          rnb.id.toLowerCase().contains('demo') ||
          rnb.id.toLowerCase().contains('test') ||
          rnb.vehicleName.toLowerCase().contains('demo') ||
          rnb.vehicleName.toLowerCase().contains('test')) {
        continue;
      }
      items.add(UnifiedBookingItem(
        id: rnb.id,
        title: rnb.vehicleName,
        subtitle: rnb.rentalType == 'hourly'
            ? 'Hourly Rental (${rnb.duration} hrs)'
            : 'Daily Rental (${rnb.duration} days)',
        status: rnb.status,
        date: DateFormat('dd MMM yyyy, hh:mm a').format(rnb.startTime),
        price: '₹${rnb.totalCost.round()}',
        type: BookingType.rental,
        createdAt: rnb.startTime,
        originalObject: rnb,
        pickupAddress:
            rnb.details['pickup_location']?.toString() ?? 'RoadRobos Rental Hub',
        destinationAddress:
            rnb.details['drop_location']?.toString() ?? 'Self Return Hub',
        vehicleType: rnb.vehicleName,
        paymentMethod: rnb.details['method']?.toString() ?? 'Online',
      ));
    }

    // Filter out locally dismissed/deleted bookings
    final dismissedIds = await _getDismissedIds();
    if (dismissedIds.isNotEmpty) {
      items.removeWhere((item) => dismissedIds.contains(item.id));
    }

    // Sort by createdAt descending
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return items;
  } catch (e) {
    // Return empty list or propagate error
    rethrow;
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// Expired Pending Rental & Unassigned Ride Cleanup
// ─────────────────────────────────────────────────────────────────────────────

/// Result returned by [expiredPendingCleanupProvider] so the UI can show
/// appropriate feedback without coupling the provider to BuildContext.
class ExpiredRentalCleanupResult {
  /// Number of bookings that were auto-cancelled.
  final int cancelledCount;

  /// Total amount credited back to the user's wallet (0 if no online payments).
  final double refundedAmount;

  /// IDs of bookings that had their wallet refunded.
  final List<String> refundedBookingIds;

  const ExpiredRentalCleanupResult({
    this.cancelledCount = 0,
    this.refundedAmount = 0,
    this.refundedBookingIds = const [],
  });

  bool get hasActivity => cancelledCount > 0;
  bool get hasRefund => refundedAmount > 0;
}

/// Runs once per Bookings screen open.
/// 1. Auto-cancels unassigned rides older than 90 seconds
/// 2. Fetches all `payment_pending` or `pending` rentals older than 30 min
/// 3. Cancels them → status `cancelled_expired`
/// 4. Credits wallet for any captured online payments
final expiredPendingCleanupProvider =
    FutureProvider<ExpiredRentalCleanupResult>((ref) async {
  final userState = ref.read(userProvider);
  final user = userState.user;
  if (user == null || user.id.isEmpty) {
    return const ExpiredRentalCleanupResult();
  }

  final rentalRepo = ref.read(rentalBookingRepositoryProvider);
  final rideRepo = ref.read(rideBookingRepositoryProvider);
  final walletRepo = ref.read(walletRepositoryProvider);

  // Proactively cancel any unassigned searching/paid rides older than 90s
  try {
    await rideRepo.autoCancelExpiredSearchingRides(customerId: user.id);
  } catch (_) {}

  // Fetch stale payment_pending and pending bookings (>30 min old)
  final expired = await rentalRepo.getExpiredPendingRentals(user.id);

  if (expired.isEmpty) return const ExpiredRentalCleanupResult();

  final ids = expired.map((r) => r.id).toList();

  // Determine which ones had a real online payment captured
  final Map<String, double> refundAmounts = {};
  double totalRefund = 0.0;
  final List<String> refundedIds = [];

  for (final booking in expired) {
    final paymentId = booking.details['payment_id']?.toString();
    final method = booking.details['method']?.toString() ?? '';
    final isOnlinePaid =
        paymentId != null && paymentId.isNotEmpty && method == 'Online';

    if (isOnlinePaid && booking.totalCost > 0) {
      refundAmounts[booking.id] = booking.totalCost;
      totalRefund += booking.totalCost;
      refundedIds.add(booking.id);
    }
  }

  // Step 1: Cancel all expired pending bookings in DB
  await rentalRepo.cancelExpiredPendingRentals(
    ids,
    refundAmounts: refundAmounts,
  );

  // Step 2: Credit wallet for captured payments
  for (final id in refundedIds) {
    final amount = refundAmounts[id]!;
    try {
      await walletRepo.topUpWallet(user.id, amount, 'refund_$id');
    } catch (e) {
      debugPrint('Wallet credit failed for booking $id: $e');
    }
  }

  // Invalidate bookings list so UI re-fetches with updated statuses
  ref.invalidate(userBookingsProvider);

  return ExpiredRentalCleanupResult(
    cancelledCount: ids.length,
    refundedAmount: totalRefund,
    refundedBookingIds: refundedIds,
  );
});

const _kDismissedBookingsKey = 'dismissed_booking_ids';

Future<Set<String>> _getDismissedIds() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kDismissedBookingsKey) ?? []).toSet();
  } catch (_) {
    return <String>{};
  }
}

Future<void> _addDismissedIds(Iterable<String> ids) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_kDismissedBookingsKey) ?? []).toSet();
    current.addAll(ids);
    await prefs.setStringList(_kDismissedBookingsKey, current.toList());
  } catch (_) {}
}

/// Deletes a single booking from history
Future<void> deleteBookingItem(WidgetRef ref, UnifiedBookingItem item) async {
  await _addDismissedIds([item.id]);
  if (item.type == BookingType.ride) {
    unawaited(ref.read(rideBookingRepositoryProvider).deleteBooking(item.id));
  } else if (item.type == BookingType.rental) {
    unawaited(ref.read(rentalBookingRepositoryProvider).deleteRentalBooking(item.id));
  } else if (item.type == BookingType.service) {
    unawaited(ref.read(serviceBookingRepositoryProvider).deleteServiceBooking(item.id));
  }
  ref.invalidate(userBookingsProvider);
}

/// Clears all cancelled, expired, and demo/test bookings for the user
Future<void> clearAllCancelledBookings(WidgetRef ref, String userId) async {
  final currentItems = ref.read(userBookingsProvider).value ?? [];
  final toDismiss = currentItems
      .where((b) =>
          b.status == 'cancelled' ||
          b.status == 'cancelled_expired' ||
          b.createdAt.isBefore(DateTime(2026, 8)) ||
          b.id.toLowerCase().contains('demo') ||
          b.id.toLowerCase().contains('test'))
      .map((b) => b.id)
      .toList();

  if (toDismiss.isNotEmpty) {
    await _addDismissedIds(toDismiss);
  }

  unawaited(ref.read(rideBookingRepositoryProvider).clearCustomerCancelledRides(userId));
  unawaited(ref.read(rentalBookingRepositoryProvider).clearCustomerCancelledRentals(userId));
  unawaited(ref.read(serviceBookingRepositoryProvider).clearCustomerCancelledServices(userId));

  ref.invalidate(userBookingsProvider);
}
