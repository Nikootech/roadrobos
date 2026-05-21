import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_booking.dart';

final serviceBookingRepositoryProvider = Provider((ref) => ServiceBookingRepository());

class ServiceBookingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> createServiceBooking(ServiceBooking booking) async {
    try {
      final response = await _supabase
          .from('service_bookings')
          .insert(booking.toMap())
          .select()
          .single();
      
      return response['id'].toString();
    } catch (e) {
      throw Exception('Failed to create service booking: $e');
    }
  }

  Future<List<ServiceBooking>> getPagedCustomerServiceBookings(String customerId, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('service_bookings')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);
      
      return response.map((map) => ServiceBooking.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch service bookings: $e');
    }
  }

  Future<void> updateServiceStatus(String bookingId, String status) async {
    try {
      await _supabase
          .from('service_bookings')
          .update({'status': status})
          .eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update service status: $e');
    }
  }
}
