import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_booking.dart';

final serviceBookingRepositoryProvider =
    Provider((ref) => ServiceBookingRepository());

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

  Future<List<ServiceBooking>> getPagedCustomerServiceBookings(
      String customerId,
      {int limit = 20,
      int offset = 0}) async {
    try {
      final response = await _supabase
          .from('service_bookings')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((map) => ServiceBooking.fromMap(map, map['id'].toString()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch service bookings: $e');
    }
  }

  Future<void> updateServiceStatus(String bookingId, String status) async {
    try {
      await _supabase
          .from('service_bookings')
          .update({'status': status}).eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update service status: $e');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _supabase
          .from('service_bookings')
          .update({'status': 'cancelled'}).eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to cancel booking: $e');
    }
  }

  Stream<ServiceBooking> streamBookingStatus(String bookingId) {
    return _supabase
        .from('service_bookings')
        .stream(primaryKey: ['id'])
        .eq('id', bookingId)
        .map((events) {
          if (events.isEmpty) throw Exception('Booking not found');
          final event = events.first;
          return ServiceBooking.fromMap(event, event['id'].toString());
        });
  }

  Future<List<ServiceBooking>> getBookingsForDate(String date) async {
    try {
      final response = await _supabase
          .from('service_bookings')
          .select()
          .eq('booking_date', date)
          .not('status', 'eq', 'cancelled');

      return response
          .map((map) => ServiceBooking.fromMap(map, map['id'].toString()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings for date: $e');
    }
  }

  Future<void> collectCashPayment(String bookingId) async {
    try {
      await _supabase
          .from('service_bookings')
          .update({
            'status': 'paid',
            'details': {
              'method': 'Cash',
              'payment_status': 'collected',
              'collected_at': DateTime.now().toIso8601String(),
            }
          }).eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to collect cash payment: $e');
    }
  }

  Future<void> refundBooking(String bookingId) async {
    try {
      final bookingResponse = await _supabase
          .from('service_bookings')
          .select()
          .eq('id', bookingId)
          .maybeSingle();

      if (bookingResponse == null) throw Exception('Booking not found');

      final customerId = bookingResponse['customer_id'];
      final double totalCost = double.tryParse(bookingResponse['total_cost']?.toString() ?? '0.0') ?? 0.0;
      final status = bookingResponse['status']?.toString();
      final Map<dynamic, dynamic> details = bookingResponse['details'] is Map ? bookingResponse['details'] as Map : {};
      final method = details['method']?.toString() ?? 'Online';

      await _supabase.from('service_bookings').update({
        'status': 'refunded',
        'details': {
          ...details,
          'refund_status': 'refunded',
          'refunded_at': DateTime.now().toIso8601String(),
          'refund_amount': totalCost,
        }
      }).eq('id', bookingId);

      if (status == 'paid' || method == 'Online') {
        final profileResponse = await _supabase
            .from('profiles')
            .select('points')
            .eq('id', customerId)
            .maybeSingle();

        if (profileResponse != null) {
          final int currentPoints = int.tryParse(profileResponse['points']?.toString() ?? '0') ?? 0;
          final refundPoints = totalCost.toInt();
          await _supabase.from('profiles').update({
            'points': currentPoints + refundPoints,
          }).eq('id', customerId);

          await _supabase.from('user_notifications').insert({
            'user_id': customerId,
            'title': '💰 Booking Refund Credited',
            'description': 'Your refund of ₹$totalCost has been credited as $refundPoints Loyalty Points to your account due to No-Show / Service cancellation.',
            'type': 'REFUND',
            'is_read': false,
            'created_at': DateTime.now().toUtc().toIso8601String(),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to refund booking: $e');
    }
  }
}
