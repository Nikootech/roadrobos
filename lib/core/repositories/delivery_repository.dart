// lib/core/repositories/delivery_repository.dart
// Repository for all delivery_orders Supabase operations.

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

import '../models/delivery_order.dart';
import '../extensions/datetime_extensions.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository();
});

class DeliveryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ── Customer: create a new order ──────────────────────────────────────────
  Future<DeliveryOrder> createOrder(DeliveryOrder order) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .insert(order.toInsertMap())
          .select()
          .single();

      unawaited(Sentry.addBreadcrumb(Breadcrumb(
        message: 'Delivery order created',
        category: 'delivery',
        data: {'order_id': response['id'], 'status': 'pending'},
      )));

      return DeliveryOrder.fromMap(response);
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      throw Exception('Failed to create delivery order: $e');
    }
  }

  // ── Driver: accept a pending order ────────────────────────────────────────
  Future<void> acceptOrder(String orderId, String driverId) async {
    try {
      await _supabase.from('delivery_orders').update({
        'driver_id': driverId,
        'status': 'accepted',
        'updated_at': DateTime.now().utcIso,
      }).eq('id', orderId).eq('status', 'pending');
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      throw Exception('Failed to accept order: $e');
    }
  }

  // ── Driver: update order status ───────────────────────────────────────────
  Future<void> updateStatus(String orderId, DeliveryStatus status) async {
    try {
      final data = <String, dynamic>{
        'status': status.toDbString(),
        'updated_at': DateTime.now().utcIso,
      };
      if (status == DeliveryStatus.delivered) {
        data['final_price'] = null; // Will be set after proof upload
      }
      await _supabase.from('delivery_orders').update(data).eq('id', orderId);
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      throw Exception('Failed to update delivery status: $e');
    }
  }

  // ── Driver: upload proof photo and save URL ───────────────────────────────
  Future<String> uploadProof(String orderId, File imageFile) async {
    try {
      final ext = p.extension(imageFile.path).isNotEmpty
          ? p.extension(imageFile.path)
          : '.jpg';
      final storagePath = '$orderId/${DateTime.now().millisecondsSinceEpoch}$ext';

      await _supabase.storage
          .from('delivery-proofs')
          .upload(storagePath, imageFile);

      final publicUrl = _supabase.storage
          .from('delivery-proofs')
          .getPublicUrl(storagePath);

      await _supabase.from('delivery_orders').update({
        'proof_image_url': publicUrl,
        'status': DeliveryStatus.delivered.toDbString(),
        'updated_at': DateTime.now().utcIso,
      }).eq('id', orderId);

      return publicUrl;
    } catch (e, st) {
      unawaited(Sentry.captureException(e, stackTrace: st));
      throw Exception('Failed to upload delivery proof: $e');
    }
  }

  // ── Customer: live-stream a single order (realtime) ───────────────────────
  Stream<DeliveryOrder?> streamOrderUpdates(String orderId) {
    return _supabase
        .from('delivery_orders')
        .stream(primaryKey: ['id'])
        .eq('id', orderId)
        .map((rows) => rows.isNotEmpty ? DeliveryOrder.fromMap(rows.first) : null);
  }

  // ── Customer: fetch all own orders (paginated) ────────────────────────────
  Future<List<DeliveryOrder>> getCustomerOrders(String customerId) async {
    try {
      final response = await _supabase
          .from('delivery_orders')
          .select()
          .eq('customer_id', customerId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false)
          .limit(50);
      return response.map((m) => DeliveryOrder.fromMap(m)).toList();
    } catch (e) {
      throw Exception('Failed to fetch delivery orders: $e');
    }
  }

  // ── Driver: stream pending orders (to show incoming requests) ─────────────
  Stream<List<DeliveryOrder>> streamPendingOrders() {
    return _supabase
        .from('delivery_orders')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .map((rows) => rows.map(DeliveryOrder.fromMap).toList());
  }

  // ── Driver: stream active order assigned to driver ────────────────────────
  Stream<DeliveryOrder?> streamDriverActiveOrder(String driverId) {
    return _supabase
        .from('delivery_orders')
        .stream(primaryKey: ['id'])
        .eq('driver_id', driverId)
        .map((rows) {
          final active = rows.where((r) {
            final s = r['status'] as String? ?? '';
            return s == 'accepted' || s == 'picked_up' || s == 'in_transit';
          }).toList();
          return active.isNotEmpty ? DeliveryOrder.fromMap(active.first) : null;
        });
  }

  // ── Driver: get driver location from driver_locations table ──────────────
  Stream<Map<String, double>?> streamDriverLocation(String driverId) {
    return _supabase
        .from('driver_locations')
        .stream(primaryKey: ['driver_id'])
        .eq('driver_id', driverId)
        .map((rows) {
          if (rows.isEmpty) return null;
          final row = rows.first;
          return {
            'lat': (row['lat'] as num?)?.toDouble() ?? 0.0,
            'lng': (row['lng'] as num?)?.toDouble() ?? 0.0,
          };
        });
  }
}
