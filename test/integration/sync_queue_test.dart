// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:roadrobos/core/data/local_database.dart';
import 'package:roadrobos/core/models/ride_booking.dart';
import 'package:roadrobos/core/models/service_booking.dart';
import 'package:roadrobos/core/models/user_role.dart';
import 'package:roadrobos/core/repositories/ride_booking_repository.dart';
import 'package:roadrobos/core/repositories/service_booking_repository.dart';
import 'package:roadrobos/core/repositories/user_repository.dart';
import 'package:roadrobos/core/services/unified_sync_service.dart';

// ── Mock classes ──────────────────────────────────────────────────────────────

class MockSupabaseClient extends Mock implements SupabaseClient {}

/// SupabaseQueryBuilder is the concrete type returned by `SupabaseClient.from()`.
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// A delegating mock that correctly resolves the Future contract expected by
/// `await supabase.from(...).update(...).eq(...)`.
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {
  final FutureOr<dynamic> Function() handler;
  MockPostgrestFilterBuilder(this.handler);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic value) onValue, {
    Function? onError,
  }) {
    final completer = Completer<R>();
    Future.sync(() => handler()).then((result) {
      Future.sync(() => onValue(result)).then(
        (val) => completer.complete(val),
        onError: (e, st) => completer.completeError(e, st),
      );
    }, onError: (e, st) {
      if (onError != null) {
        Future.sync(() => onError(e, st)).then(
          (val) => completer.complete(val as R),
          onError: (err, stack) => completer.completeError(err, stack),
        );
      } else {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }
}

/// Mocktail Mock for Ref — all abstract members handled by noSuchMethod.
/// We stub only the methods UnifiedSyncService actually calls: read and onDispose.
class MockRef extends Mock implements Ref<void> {}

class MockUserRepository extends Mock implements UserRepository {}

class MockRideBookingRepository extends Mock implements RideBookingRepository {}

class MockServiceBookingRepository extends Mock
    implements ServiceBookingRepository {}

// A simple mock stream handler for the connectivity EventChannel
class TestConnectivityStreamHandler extends MockStreamHandler {
  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    events.success(['wifi']);
  }

  @override
  void onCancel(Object? arguments) {}
}

// ── Test suite ─────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late MockSupabaseClient mockSupabase;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockPostgrestFilterBuilder mockFilterBuilder;

  late MockUserRepository mockUserRepo;
  late MockRideBookingRepository mockRideRepo;
  late MockServiceBookingRepository mockServiceRepo;

  late MockRef mockRef;
  late ProviderContainer container;

  setUpAll(() {
    // Register Mocktail fallback values with correct constructor signatures
    registerFallbackValue(const AppUser(
      id: '',
      name: '',
      phone: '',
      role: UserRole.customer,
    ));
    registerFallbackValue(RideBooking(
      id: '',
      customerId: '',
      pickupAddress: '',
      destinationAddress: '',
      pickupLat: 0.0,
      pickupLng: 0.0,
      destLat: 0.0,
      destLng: 0.0,
      fare: 0,
      status: 'pending',
      createdAt: DateTime.now(),
    ));
    registerFallbackValue(ServiceBooking(
      id: '',
      customerId: '',
      vehicleName: '',
      vehiclePlate: '',
      packageName: '',
      date: '',
      time: '',
      totalCost: 0.0,
      details: {},
      createdAt: DateTime.now(),
    ));
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    mockSupabase = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockPostgrestFilterBuilder(() => null);

    mockUserRepo = MockUserRepository();
    mockRideRepo = MockRideBookingRepository();
    mockServiceRepo = MockServiceBookingRepository();

    // Mock Connectivity Platform Channels to prevent MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkConnectivity') {
          return ['wifi'];
        }
        return null;
      },
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      const EventChannel('dev.fluttercommunity.plus/connectivity_status'),
      TestConnectivityStreamHandler(),
    );

    // ProviderContainer with repository overrides (used for verification only).
    container = ProviderContainer(
      overrides: [
        localDatabaseProvider.overrideWithValue(db),
        userRepositoryProvider.overrideWithValue(mockUserRepo),
        rideBookingRepositoryProvider.overrideWithValue(mockRideRepo),
        serviceBookingRepositoryProvider.overrideWithValue(mockServiceRepo),
      ],
    );

    // MockRef delegates provider reads to the ProviderContainer.
    mockRef = MockRef();
    when(() => mockRef.read(userRepositoryProvider))
        .thenAnswer((_) => mockUserRepo);
    when(() => mockRef.read(rideBookingRepositoryProvider))
        .thenAnswer((_) => mockRideRepo);
    when(() => mockRef.read(serviceBookingRepositoryProvider))
        .thenAnswer((_) => mockServiceRepo);
    when(() => mockRef.onDispose(any())).thenAnswer((_) {});
  });

  tearDown(() async {
    await db.close();
    container.dispose();
  });

  // ── Helper ────────────────────────────────────────────────────────────────

  UnifiedSyncService makeSyncService() =>
      UnifiedSyncService(db, mockRef, supabaseClient: mockSupabase);

  // ── Tests ─────────────────────────────────────────────────────────────────

  group('UnifiedSyncService Queue Processing Tests', () {
    // ── Test 1: All entity types are dispatched and deleted ──────────────────
    test(
        'successfully processes all 4 entity types and deletes tasks from queue',
        () async {
      // technician_job → direct Supabase call chain
      when(() => mockSupabase.from('technician_jobs'))
          .thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.update(any()))
          .thenAnswer((_) => mockFilterBuilder);
      when(() => mockFilterBuilder.eq(any(), any()))
          .thenAnswer((_) => mockFilterBuilder);

      // profile → UserRepository.saveUser
      when(() => mockUserRepo.saveUser(any())).thenAnswer((_) async {});

      // ride_booking → RideBookingRepository.createRideBooking (Future<String>)
      when(() => mockRideRepo.createRideBooking(any()))
          .thenAnswer((_) async => 'ride-123');

      // service_booking → ServiceBookingRepository.createServiceBooking (Future<String>)
      when(() => mockServiceRepo.createServiceBooking(any()))
          .thenAnswer((_) async => 'service-123');

      final syncService = makeSyncService();

      // Enqueue one task per entity type
      await syncService.enqueue(
        entityType: 'technician_job',
        action: 'update_job_status',
        payload: {'jobId': 'job-123', 'status': 'completed'},
      );
      await syncService.enqueue(
        entityType: 'profile',
        action: 'update_profile',
        payload: {
          'id': 'user-123',
          'name': 'Sudhan Test',
          'email': 'sudhan@test.com',
          'phone': '+919876543210',
          'role': 'customer',
          'points': 100,
        },
      );
      await syncService.enqueue(
        entityType: 'ride_booking',
        action: 'book_ride',
        payload: {
          'id': 'ride-123',
          'customer_id': 'user-123',
          'pickup_address': '123 St',
          'destination_address': '456 Rd',
          'pickup_lat': 12.9716,
          'pickup_lng': 77.5946,
          'dest_lat': 13.0827,
          'dest_lng': 80.2707,
          'fare': 250.0,
          'status': 'confirmed',
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
      );
      await syncService.enqueue(
        entityType: 'service_booking',
        action: 'create_service_booking',
        payload: {
          'id': 'service-123',
          'customer_id': 'user-123',
          'vehicle_name': 'Tesla Model 3',
          'vehicle_plate': 'TS09AB1234',
          'package_name': 'Premium Wash',
          'booking_date': '2026-06-08',
          'booking_time': '10:00 AM',
          'status': 'confirmed',
          'total_cost': 500.0,
          'details': {},
          'created_at': DateTime.now().toUtc().toIso8601String(),
        },
      );

      // Process queue deterministically
      await syncService.processQueue();

      // Queue must be completely empty
      final remaining = await db.select(db.syncQueue).get();
      expect(remaining.isEmpty, isTrue,
          reason: 'All 4 tasks should be deleted after successful dispatch');

      // Verify dispatcher paths
      verify(() => mockSupabase.from('technician_jobs')).called(1);
      verify(() => mockUserRepo.saveUser(any())).called(1);
      verify(() => mockRideRepo.createRideBooking(any())).called(1);
      verify(() => mockServiceRepo.createServiceBooking(any())).called(1);
    });

    // ── Test 2: Exponential backoff on failure ───────────────────────────────
    test('failed records are retried with exponential backoff', () async {
      when(() => mockUserRepo.saveUser(any()))
          .thenThrow(Exception('Supabase connection down'));

      final syncService = makeSyncService();

      await syncService.enqueue(
        entityType: 'profile',
        action: 'update_profile',
        payload: {
          'id': 'user-123',
          'name': 'Sudhan Test',
          'email': 'sudhan@test.com',
          'phone': '+919876543210',
          'role': 'customer',
          'points': 100,
        },
      );

      await syncService.processQueue();

      // Task must still exist with incremented attempt count
      final remaining = await db.select(db.syncQueue).get();
      expect(remaining.length, equals(1));

      final task = remaining.first;
      expect(task.attempts, equals(1),
          reason:
              'Attempt counter must be incremented to 1 after first failure');
      expect(task.nextRetryAt, isNotNull,
          reason: 'nextRetryAt must be scheduled after a failure');

      // Attempt 1 backoff: 2^1 = 2 minutes → ~120 s from now (±15 s leeway)
      final diffSeconds =
          task.nextRetryAt!.difference(DateTime.now()).inSeconds;
      expect(diffSeconds, closeTo(120, 15),
          reason: 'Backoff must be ~2 minutes (120 s)');
    });

    // ── Test 3: Dead-letter queue after ≥5 failed attempts ──────────────────
    test(
        'records exceeding 5 attempts are permanently moved to dead_letter_queue',
        () async {
      when(() => mockUserRepo.saveUser(any()))
          .thenThrow(Exception('Validation failed permanently'));

      final syncService = makeSyncService();

      const idempotencyKey = 'idempotent-dlq-test-001';

      // Insert directly into the DB with attempts=4 pre-set.
      // This avoids using enqueue() which fires an unawaited processQueue() that
      // races with our own db.update() and can overwrite the attempts column.
      await db.into(db.syncQueue).insert(
            SyncQueueCompanion.insert(
              idempotencyKey: idempotencyKey,
              entityType: 'profile',
              action: 'update_profile',
              payload: jsonEncode({
                'id': 'user-123',
                'name': 'Sudhan Test',
                'email': 'sudhan@test.com',
                'phone': '+919876543210',
                'role': 'customer',
                'points': 100,
              }),
              attempts: const Value(4),
            ),
          );

      // Process queue — this is attempt 5, which must trigger DLQ promotion
      await syncService.processQueue();

      // Sync queue must be empty
      final remainingQueue = await db.select(db.syncQueue).get();
      expect(remainingQueue.isEmpty, isTrue,
          reason: 'Task must be removed from sync_queue after DLQ promotion');

      // Dead-letter queue must have exactly one record
      final dlq = await db.select(db.deadLetterQueue).get();
      expect(dlq.length, equals(1),
          reason: 'Exactly one record must appear in dead_letter_queue');

      final dlqTask = dlq.first;
      expect(dlqTask.idempotencyKey, equals(idempotencyKey));
      expect(dlqTask.entityType, equals('profile'));
      expect(dlqTask.attempts, equals(5),
          reason: 'DLQ record must capture the final attempt count of 5');
      expect(dlqTask.error, contains('Validation failed permanently'));
    });
  });
}
