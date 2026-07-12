import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/service_booking_repository.dart';
import '../../core/repositories/ride_booking_repository.dart';
import '../../core/repositories/rental_booking_repository.dart';
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
