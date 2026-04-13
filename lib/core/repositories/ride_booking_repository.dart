import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      
      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create ride booking: $e');
    }
  }

  Stream<List<RideBooking>> getCustomerRides(String customerId) {
    return _supabase
        .from('ride_bookings')
        .stream(primaryKey: ['id'])
        .eq('customer_id', customerId)
        .order('created_at')
        .map((list) {
      return list.map((map) => RideBooking.fromMap(map, map['id'].toString())).toList();
    });
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
