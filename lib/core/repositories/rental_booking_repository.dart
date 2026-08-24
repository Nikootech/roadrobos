import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/rental_booking.dart';

final rentalBookingRepositoryProvider =
    Provider((ref) => RentalBookingRepository());

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
          .update({'status': status}).eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update rental status: $e');
    }
  }

  Future<void> updateRentalDetails(
      String bookingId, Map<String, dynamic> details) async {
    try {
      await _supabase
          .from('rental_bookings')
          .update({'details': details}).eq('id', bookingId);
    } catch (e) {
      throw Exception('Failed to update rental details: $e');
    }
  }

  Future<List<RentalBooking>> getPagedCustomerRentals(String customerId,
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await _supabase
          .from('rental_bookings')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map((map) => RentalBooking.fromMap(map, map['id'].toString()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch rental bookings: $e');
    }
  }

  /// Returns all `payment_pending` rental bookings for [customerId] that have
  /// exceeded their allocated duration OR are older than [windowMinutes].
  /// These are candidates for auto-cancellation.
  Future<List<RentalBooking>> getExpiredPendingRentals(
    String customerId, {
    int windowMinutes = 30,
  }) async {
    try {
      final cutoff = DateTime.now()
          .subtract(Duration(minutes: windowMinutes))
          .toUtc()
          .toIso8601String();

      final response = await _supabase
          .from('rental_bookings')
          .select()
          .eq('customer_id', customerId)
          .eq('status', 'payment_pending')
          .lt('created_at', cutoff);

      return response
          .map((map) => RentalBooking.fromMap(map, map['id'].toString()))
          .toList();
    } catch (e) {
      debugPrint('getExpiredPendingRentals error: $e');
      return []; // Non-fatal — don't block bookings screen
    }
  }

  /// Marks each booking in [ids] as `cancelled_expired` and optionally
  /// records the refund amount in the `details` JSON column.
  Future<void> cancelExpiredPendingRentals(
    List<String> ids, {
    Map<String, double> refundAmounts = const {},
  }) async {
    if (ids.isEmpty) return;
    try {
      // Batch update in one round-trip using the `in` filter
      await _supabase
          .from('rental_bookings')
          .update({
            'status': 'cancelled_expired',
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .inFilter('id', ids);

      // For bookings that had a captured payment, stamp refund metadata
      for (final id in ids) {
        final amount = refundAmounts[id];
        if (amount != null && amount > 0) {
          try {
            await _supabase.from('rental_bookings').update({
              'details': {
                'refund_amount': amount,
                'refund_status': 'wallet_credited',
                'refund_at': DateTime.now().toUtc().toIso8601String(),
              }
            }).eq('id', id);
          } catch (e) {
            debugPrint('Could not stamp refund metadata for $id: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('cancelExpiredPendingRentals error: $e');
      // Best-effort; do not rethrow so the UI isn't broken
    }
  }

  Future<void> syncRentalBooking(
      String action, Map<String, dynamic> payload) async {
    switch (action) {
      case 'create_rental_booking':
        await _supabase.from('rental_bookings').upsert(payload);
        break;
      case 'update_rental_status':
        await _supabase
            .from('rental_bookings')
            .update({'status': payload['status']}).eq('id', payload['id']);
        break;
      default:
        throw Exception('Unknown rental_booking action: $action');
    }
  }
}
