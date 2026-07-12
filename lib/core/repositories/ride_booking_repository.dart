import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/ride_booking.dart';

final rideBookingRepositoryProvider = Provider((ref) => RideBookingRepository());

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

  Future<List<RideBooking>> getPagedCustomerRides(String customerId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('ride_bookings')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return response.map((map) => RideBooking.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch rides: $e');
    }
  }

  Future<void> updateRideStatus(String bookingId, String status) async {
    try {
      await _supabase
          .from('ride_bookings')
          .update({'status': status})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update ride status: $e');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await _supabase
        .from('ride_bookings')
        .update({'status': 'cancelled', 'cancelled_at': DateTime.now().toIso8601String()})
        .eq('id', bookingId);
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
