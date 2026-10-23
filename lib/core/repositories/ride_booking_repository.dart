import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/ride_booking.dart';
import '../extensions/datetime_extensions.dart';

final rideBookingRepositoryProvider =
    Provider((ref) => RideBookingRepository());

class RideBookingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> createRideBooking(RideBooking booking) async {
    try {
      final response = await _supabase
          .from('ride_bookings')
          .insert(booking.toMap())
          .select()
          .single();

      final bookingId = response['id'].toString();
      unawaited(Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Booking created',
          category: 'booking',
          data: {
            'booking_id': bookingId,
            'customer_id': booking.customerId,
            'status': booking.status,
          },
        ),
      ));
      return bookingId;
    } catch (e) {
      throw Exception('Failed to create ride booking: $e');
    }
  }

  Future<List<RideBooking>> getPagedCustomerRides(String customerId,
      {int limit = 20, int offset = 0}) async {
    try {
      if (customerId == 'demo' || customerId.isEmpty) {
        return [];
      }
      final response = await _supabase
          .from('ride_bookings')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((map) => RideBooking.fromMap(map, map['id'].toString()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rides: $e');
    }
  }

  Future<List<RideBooking>> getPagedDriverRides(String driverId,
      {int limit = 20, int offset = 0}) async {
    try {
      if (driverId == 'demo' || driverId.isEmpty) {
        return [];
      }
      final response = await _supabase
          .from('ride_bookings')
          .select()
          .eq('driver_id', driverId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((map) => RideBooking.fromMap(map, map['id'].toString()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch driver rides: $e');
    }
  }

  Future<void> updateRideStatus(String bookingId, String status) async {
    try {
      await _supabase
          .from('ride_bookings')
          .update({'status': status}).eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update ride status: $e');
    }
  }

  Future<void> updateScheduledTime(
      String bookingId, DateTime scheduledTime) async {
    try {
      await _supabase.from('ride_bookings').update({
        'scheduled_for': scheduledTime.toUtc().toIso8601String(),
        'status': 'scheduled',
      }).eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update scheduled time: $e');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await _supabase.from('ride_bookings').update({
      'status': 'cancelled',
      'cancelled_at': DateTime.now().toUtc().toIso8601String()
    }).eq('id', bookingId);
  }

  /// Delete a single ride booking from customer history
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _supabase.from('ride_bookings').delete().eq('id', bookingId);
    } catch (e) {
      // If RLS prevents hard delete, soft cancel
      await cancelBooking(bookingId);
    }
  }

  /// Clear all cancelled/stale ride bookings for a customer
  Future<void> clearCustomerCancelledRides(String customerId) async {
    try {
      await _supabase
          .from('ride_bookings')
          .delete()
          .eq('customer_id', customerId)
          .eq('status', 'cancelled');
    } catch (_) {}
  }

  /// Auto-cancels any unassigned ride that was requested more than [timeoutSeconds] ago
  /// and was never accepted by a driver (driver_id is null).
  Future<int> autoCancelExpiredSearchingRides(
      {String? customerId, int timeoutSeconds = 90}) async {
    try {
      final DateTime now = DateTime.now().toUtc();
      final cutoff = now.subtract(Duration(seconds: timeoutSeconds)).utcIso;

      var query = _supabase
          .from('ride_bookings')
          .select('id')
          .isFilter('driver_id', null)
          .inFilter('status', ['searching', 'paid', 'pending'])
          .lt('created_at', cutoff);

      if (customerId != null && customerId.isNotEmpty) {
        query = query.eq('customer_id', customerId);
      }

      final staleRides = await query;
      if (staleRides.isEmpty) return 0;

      final ids = staleRides.map((r) => r['id'].toString()).toList();
      await _supabase
          .from('ride_bookings')
          .update({
            'status': 'cancelled',
            'cancelled_at': DateTime.now().toUtc().toIso8601String(),
          })
          .inFilter('id', ids);

      return ids.length;
    } catch (_) {
      return 0;
    }
  }

  /// Watch a specific booking for updates
  Stream<RideBooking?> watchBooking(String bookingId) {
    return _supabase
        .from('ride_bookings')
        .stream(primaryKey: ['id'])
        .eq('id', bookingId)
        .map((list) => list.isNotEmpty
            ? RideBooking.fromMap(list.first, list.first['id'].toString())
            : null);
  }
}
