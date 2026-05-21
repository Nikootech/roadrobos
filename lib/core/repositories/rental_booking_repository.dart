import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rental_booking.dart';

final rentalBookingRepositoryProvider = Provider((ref) => RentalBookingRepository());

class RentalBookingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> createRentalBooking(RentalBooking booking) async {
    try {
      final response = await _supabase
          .from('rental_bookings')
          .insert(booking.toMap())
          .select()
          .single();
      
      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create rental booking: $e');
    }
  }

  Future<void> updateRentalStatus(String bookingId, String status) async {
    try {
      await _supabase
          .from('rental_bookings')
          .update({'status': status})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update rental status: $e');
    }
  }

  Future<List<RentalBooking>> getPagedCustomerRentals(String customerId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('rental_bookings')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return response.map((map) => RentalBooking.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch rental bookings: $e');
    }
  }
}
