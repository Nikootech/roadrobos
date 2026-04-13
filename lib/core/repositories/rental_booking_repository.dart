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
}
