import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../security/encrypted_column.dart';

part 'local_database.g.dart';

// 1. Cached Profiles — email & phone encrypted at rest (AES-256-GCM)
class CachedProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  // PII columns — encrypted before SQLite write, decrypted on read
  TextColumn get email =>
      text().nullable().map(
        const NullAwareTypeConverter.wrap(EncryptedStringConverter()),
      )();
  TextColumn get phone =>
      text().map(const EncryptedStringConverter())();
  TextColumn get role => text()();
  TextColumn get profilePic => text().nullable()();
  IntColumn get points => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Sync Queue — with idempotency_key for offline deduplication (N5)
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get idempotencyKey => text().unique()(); // UUID v4 — prevents duplicate mutations
  TextColumn get action => text()(); // e.g. 'update_job_status', 'send_message'
  TextColumn get payload => text()(); // JSON payload
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
}

// 3. Cached Rides
class CachedRides extends Table {
  TextColumn get id => text()();
  TextColumn get pickupAddress => text()();
  TextColumn get destinationAddress => text()();
  RealColumn get fare => real()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 4. Cached Categories
class CachedCategories extends Table {
  TextColumn get id => text()();
  TextColumn get icon => text()();
  TextColumn get label => text()();
  TextColumn get count => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// 5. Cached Banners
class CachedBanners extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get subtitle => text()();
  TextColumn get image => text()();
  TextColumn get cta => text()();

  @override
  Set<Column> get primaryKey => {id};
}

// 6. Cached Technician Jobs
class CachedTechnicianJobs extends Table {
  TextColumn get id => text()();
  TextColumn get vehicleModel => text()();
  TextColumn get vehiclePlate => text()();
  TextColumn get serviceType => text()();
  TextColumn get packageName => text()();
  TextColumn get date => text()();
  TextColumn get time => text()();
  RealColumn get progress => real()();
  TextColumn get checklist => text()(); // JSON string
  TextColumn get parts => text()(); // JSON string
  TextColumn get status => text()();
  TextColumn get price => text()();
  TextColumn get assignedTechId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get serviceBookingId => text().nullable()();
  TextColumn get estimatedCompletion => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 7. HTTP Response Cache — for CacheInterceptor (N3)
class HttpResponseCache extends Table {
  TextColumn get cacheKey => text()(); // SHA-256 of url + sorted params
  TextColumn get responseBody => text()();
  DateTimeColumn get cachedAt => dateTime()();
  IntColumn get ttlSeconds => integer().withDefault(const Constant(300))();

  @override
  Set<Column> get primaryKey => {cacheKey};
}

@DriftDatabase(tables: [
  CachedProfiles,
  SyncQueue,
  CachedRides,
  CachedCategories,
  CachedBanners,
  CachedTechnicianJobs,
  HttpResponseCache,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(driftDatabase(
          name: 'roadrobos_local',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ));

  @override
  int get schemaVersion => 2; // bumped: encrypted columns + idempotency_key + http cache

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // V1→V2: idempotency_key + HttpResponseCache table
        await m.addColumn(syncQueue, syncQueue.idempotencyKey);
        await m.createTable(httpResponseCache);
      }
    },
  );

  // ── SyncQueue helpers ──────────────────────────────────────────────────────

  /// Enqueue a mutation only if the [idempotencyKey] is not already present.
  Future<void> enqueueIfNew({
    required String idempotencyKey,
    required String action,
    required String payload,
  }) async {
    final exists = await (select(syncQueue)
          ..where((t) => t.idempotencyKey.equals(idempotencyKey)))
        .getSingleOrNull();
    if (exists != null) return;
    await into(syncQueue).insert(SyncQueueCompanion.insert(
      idempotencyKey: idempotencyKey,
      action: action,
      payload: payload,
    ));
  }

  // ── HTTP cache helpers ─────────────────────────────────────────────────────

  Future<HttpResponseCacheData?> getCachedResponse(String key) async {
    final row = await (select(httpResponseCache)
          ..where((t) => t.cacheKey.equals(key)))
        .getSingleOrNull();
    if (row == null) return null;
    final age = DateTime.now().difference(row.cachedAt).inSeconds;
    if (age > row.ttlSeconds) {
      await (delete(httpResponseCache)
            ..where((t) => t.cacheKey.equals(key)))
          .go();
      return null;
    }
    return row;
  }

  Future<void> upsertCachedResponse({
    required String key,
    required String body,
    required int ttlSeconds,
  }) async {
    await into(httpResponseCache).insertOnConflictUpdate(
      HttpResponseCacheCompanion.insert(
        cacheKey: key,
        responseBody: body,
        cachedAt: DateTime.now(),
        ttlSeconds: Value(ttlSeconds),
      ),
    );
  }
}

final localDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
