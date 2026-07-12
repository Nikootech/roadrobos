// IMPORTANT: All StreamSubscription fields must be cancelled in dispose/onDispose.

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mutex/mutex.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/local_database.dart';
import '../models/user_role.dart';
import '../models/ride_booking.dart';
import '../models/service_booking.dart';
import '../repositories/user_repository.dart';
import '../repositories/ride_booking_repository.dart';
import '../repositories/service_booking_repository.dart';
import '../repositories/rental_booking_repository.dart';
import '../repositories/wallet_repository.dart';
import '../repositories/delivery_repository.dart';
import '../../navigation/app_router.dart';

final unifiedSyncServiceProvider = Provider<UnifiedSyncService>((ref) {
  // ISSUE-04: On web there is no offline queue — Drift/SQLite is not used.
  // Repositories call Supabase directly on web so the sync service is a no-op.
  if (kIsWeb) return UnifiedSyncService.webStub(ref);
  final db = ref.watch(localDatabaseProvider);
  return UnifiedSyncService(db, ref);
});

class UnifiedSyncService {
  final AppDatabase? _db; // nullable — null on web (ISSUE-04)
  final Ref _ref;
  final SupabaseClient _supabase;
  final Mutex _mutex = Mutex();

  UnifiedSyncService(AppDatabase db, this._ref,
      {SupabaseClient? supabaseClient})
      : _db = db,
        _supabase = supabaseClient ?? Supabase.instance.client {
    _startConnectivityListener();
  }

  /// Web stub — no DB, no queue listener. enqueue() is a no-op on web.
  UnifiedSyncService.webStub(this._ref)
      : _db = null,
        _supabase = Supabase.instance.client;

  void _startConnectivityListener() {
    // Listen to network changes and trigger sync
    final subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        // ignore: unawaited_futures
        processQueue();
      }
    });

    _ref.onDispose(() {
      subscription.cancel();
      debugPrint('UnifiedSyncService disposed');
    });
  }

  /// Adds a task to the local sync queue and triggers processing
  Future<void> enqueue({
    required String entityType,
    required String action,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    // ISSUE-04: No offline queue on web — skip silently.
    if (_db == null) return;

    final key = idempotencyKey ?? const Uuid().v4();

    // Check if duplicate idempotency key exists
    final db = _db;
    final exists = await (db.select(db.syncQueue)
          ..where((t) => t.idempotencyKey.equals(key)))
        .getSingleOrNull();

    if (exists != null) {
      debugPrint('UnifiedSyncService: Action already exists with key $key');
      return;
    }

    await db.into(db.syncQueue).insert(
          SyncQueueCompanion.insert(
            idempotencyKey: key,
            entityType: entityType,
            action: action,
            payload: jsonEncode(payload),
          ),
        );

    // Process queue asynchronously
    // ignore: unawaited_futures
    processQueue();
  }

  /// Serialized queue processing utilizing a Mutex to prevent concurrency issues
  Future<void> processQueue() async {
    // ISSUE-04: No offline queue on web.
    if (_db == null) return;

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final db = _db;
    await _mutex.protect(() async {
      try {
        final pending = await (db.select(db.syncQueue)
              ..where((t) =>
                  t.nextRetryAt.isNull() |
                  t.nextRetryAt.isSmallerOrEqualValue(DateTime.now()))
              ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]))
            .get();

        if (pending.isEmpty) return;

        debugPrint(
            'UnifiedSyncService: Processing ${pending.length} pending actions...');

        for (final task in pending) {
          try {
            final payload = jsonDecode(task.payload);
            await _dispatch(task, payload);

            // Success: delete record
            await (db.delete(db.syncQueue)..where((t) => t.id.equals(task.id)))
                .go();
            debugPrint(
                'UnifiedSyncService: Successfully processed and deleted task ${task.id}');

            // Show global success snackbar if applicable
            _showSuccessSnackbarForTask(task.entityType);
          } catch (e) {
            debugPrint(
                'UnifiedSyncService: Failed to process task ${task.id}: $e');
            final newAttempts = task.attempts + 1;

            if (newAttempts >= 5) {
              // Move to dead letter queue
              await db.into(db.deadLetterQueue).insert(
                    DeadLetterQueueCompanion.insert(
                      idempotencyKey: task.idempotencyKey,
                      entityType: task.entityType,
                      action: task.action,
                      payload: task.payload,
                      createdAt: task.createdAt,
                      attempts: newAttempts,
                      error: Value(e.toString()),
                    ),
                  );
              // Delete from sync queue
              await (db.delete(db.syncQueue)
                    ..where((t) => t.id.equals(task.id)))
                  .go();
              debugPrint(
                  'UnifiedSyncService: Task ${task.id} exceeded max retries. Moved to Dead Letter Queue.');
            } else {
              // Exponential backoff
              int backoffMinutes = math.pow(2, newAttempts).toInt();
              if (backoffMinutes > 32) backoffMinutes = 32;
              final nextRetry =
                  DateTime.now().add(Duration(minutes: backoffMinutes));

              await (db.update(db.syncQueue)
                    ..where((t) => t.id.equals(task.id)))
                  .write(
                SyncQueueCompanion(
                  attempts: Value(newAttempts),
                  nextRetryAt: Value(nextRetry),
                ),
              );
              debugPrint(
                  'UnifiedSyncService: Scheduled retry for task ${task.id} in $backoffMinutes minutes.');
            }
          }
        }
      } catch (e) {
        debugPrint('UnifiedSyncService: Error during queue processing: $e');
      }
    });
  }

  /// Dispatcher pattern mapping actions by entityType
  Future<void> _dispatch(
      SyncQueueData task, Map<String, dynamic> payload) async {
    switch (task.entityType) {
      case 'technician_job':
        await _processTechnicianJob(task.action, payload);
        break;
      case 'profile':
        await _processProfile(task.action, payload);
        break;
      case 'ride_booking':
        await _processRideBooking(task.action, payload);
        break;
      case 'service_booking':
        await _processServiceBooking(task.action, payload);
        break;
      case 'rental_booking':
        await _processRentalBooking(task.action, payload);
        break;
      case 'wallet_transaction':
        await _processWalletTransaction(task.action, payload);
        break;
      case 'delivery_order':
        await _processDeliveryOrder(task.action, payload);
        break;
      default:
        throw Exception(
          'Unknown entityType: ${task.entityType}. '
          'Task: ${jsonEncode(task.toJson())}',
        );
    }
  }

  void _showSuccessSnackbarForTask(String entityType) {
    String? message;
    if (entityType == 'service_booking') {
      message = 'Your booking was submitted successfully.';
    } else if (entityType == 'ride_booking') {
      message = 'Your ride booking was submitted successfully.';
    } else if (entityType == 'profile') {
      message = 'Profile changes synced successfully.';
    }

    if (message != null) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _processTechnicianJob(
      String action, Map<String, dynamic> payload) async {
    switch (action) {
      case 'update_job_status':
        await _supabase
            .from('technician_jobs')
            .update({'status': payload['status']}).eq('id', payload['jobId']);
        break;
      case 'update_vehicle_details':
        await _supabase.from('technician_jobs').update({
          'vehicleModel': payload['model'],
          'vehiclePlate': payload['plate'],
        }).eq('id', payload['jobId']);
        break;
      case 'update_job_progress':
        await _supabase.from('technician_jobs').update(
            {'progress': payload['progress']}).eq('id', payload['jobId']);
        break;
      case 'toggle_checklist':
        await _supabase.from('technician_jobs').update({
          'checklist': payload['checklist'],
          'progress': payload['progress'],
        }).eq('id', payload['jobId']);
        break;
      case 'add_spare_part':
        await _supabase.from('technician_jobs').update({
          'parts': payload['parts'],
        }).eq('id', payload['jobId']);
        break;
      default:
        throw Exception('Unknown technician_job action: $action');
    }
  }

  Future<void> _processProfile(
      String action, Map<String, dynamic> payload) async {
    switch (action) {
      case 'update_profile':
        final userRepo = _ref.read(userRepositoryProvider);
        final user = AppUser.fromMap(payload, payload['id']);
        await userRepo.saveUser(user);
        break;
      default:
        throw Exception('Unknown profile action: $action');
    }
  }

  Future<void> _processRideBooking(
      String action, Map<String, dynamic> payload) async {
    switch (action) {
      case 'book_ride':
        final rideRepo = _ref.read(rideBookingRepositoryProvider);
        final booking = RideBooking.fromMap(payload, payload['id']);
        await rideRepo.createRideBooking(booking);
        break;
      default:
        throw Exception('Unknown ride_booking action: $action');
    }
  }

  Future<void> _processServiceBooking(
      String action, Map<String, dynamic> payload) async {
    switch (action) {
      case 'create_service_booking':
        final serviceRepo = _ref.read(serviceBookingRepositoryProvider);
        final booking = ServiceBooking.fromMap(payload, payload['id']);
        await serviceRepo.createServiceBooking(booking);
        break;
      case 'update_service_status':
        final serviceRepo = _ref.read(serviceBookingRepositoryProvider);
        await serviceRepo.updateServiceStatus(
            payload['bookingId'], payload['status']);
        break;
      default:
        throw Exception('Unknown service_booking action: $action');
    }
  }

  /// Handles offline rental booking sync.
  Future<void> _processRentalBooking(
      String action, Map<String, dynamic> payload) async {
    await _ref
        .read(rentalBookingRepositoryProvider)
        .syncRentalBooking(action, payload);
  }

  /// Handles offline wallet transaction sync.
  Future<void> _processWalletTransaction(
      String action, Map<String, dynamic> payload) async {
    await _ref.read(walletRepositoryProvider).syncTransaction(action, payload);
  }

  /// Handles offline delivery order sync.
  Future<void> _processDeliveryOrder(
      String action, Map<String, dynamic> payload) async {
    await _ref
        .read(deliveryRepositoryProvider)
        .syncDeliveryOrder(action, payload);
  }
}
