import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'booking_providers.g.dart';

// Assuming a BookingRepository exists, this is a pattern for migrating the provider
// Replace with actual implementation

@Riverpod(keepAlive: true)
dynamic bookings(BookingsRef ref) {
  // Pattern implementation
  // return ref.watch(bookingRepositoryProvider).getBookings();
  return [];
}
