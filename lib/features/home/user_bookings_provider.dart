import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
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

    // Map ServiceBookings
    for (final sb in serviceBookings) {
      items.add(UnifiedBookingItem(
        id: sb.id,
        title: sb.packageName.isNotEmpty ? sb.packageName : 'General Service',
        subtitle: '${sb.vehicleName} • ${sb.vehiclePlate}',
        status: sb.status,
        date: sb.date.isNotEmpty
            ? sb.date
            : DateFormat('dd MMM yyyy').format(sb.createdAt),
        price: '₹${sb.totalCost.toStringAsFixed(0)}',
        type: BookingType.service,
        createdAt: sb.createdAt,
        originalObject: sb,
      ));
    }

    // Map RideBookings
    for (final rb in rideBookings) {
      items.add(UnifiedBookingItem(
        id: rb.id,
        title: rb.vehicleType != null
            ? '${rb.vehicleType!.toUpperCase()} Ride'
            : 'Taxi Ride',
        subtitle: '${rb.pickupAddress} ➔ ${rb.destinationAddress}',
        status: rb.status,
        date: DateFormat('dd MMM yyyy').format(rb.createdAt),
        price: '₹${rb.fare.toStringAsFixed(0)}',
        type: BookingType.ride,
        createdAt: rb.createdAt,
        originalObject: rb,
      ));
    }

    // Map RentalBookings
    for (final rnb in rentalBookings) {
      items.add(UnifiedBookingItem(
        id: rnb.id,
        title: rnb.vehicleName,
        subtitle: rnb.rentalType == 'hourly'
            ? 'Hourly Rental (${rnb.duration} hrs)'
            : 'Daily Rental (${rnb.duration} days)',
        status: rnb.status,
        date: DateFormat('dd MMM yyyy').format(rnb.startTime),
        price: '₹${rnb.totalCost.toStringAsFixed(0)}',
        type: BookingType.rental,
        createdAt: rnb.startTime,
        originalObject: rnb,
      ));
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
// Expired Pending Rental Cleanup
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

/// Runs once per Bookings screen open (auto-disposed).
/// 1. Fetches all `payment_pending` rentals older than 30 min
/// 2. Cancels them → status `cancelled_expired`
/// 3. Credits wallet for any captured online payments
/// 4. Returns [ExpiredRentalCleanupResult] for UI notification
final expiredPendingCleanupProvider =
    FutureProvider<ExpiredRentalCleanupResult>((ref) async {
  final userState = ref.read(userProvider);
  final user = userState.user;
  if (user == null || user.id.isEmpty) {
    return const ExpiredRentalCleanupResult();
  }

  final rentalRepo = ref.read(rentalBookingRepositoryProvider);
  final walletRepo = ref.read(walletRepositoryProvider);

  // Fetch stale payment_pending bookings (>30 min old — default window)
  final expired = await rentalRepo.getExpiredPendingRentals(user.id);


  if (expired.isEmpty) return const ExpiredRentalCleanupResult();

  final ids = expired.map((r) => r.id).toList();

  // Determine which ones had a real online payment captured
  // A payment_id in details means money was actually taken
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
      // Non-fatal: log and continue — DB is already marked as refunded
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
