import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'local_database.g.dart';

// 1. Cached Profiles
class CachedProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text()();
  TextColumn get role => text()();
  TextColumn get profilePic => text().nullable()();
  IntColumn get points => integer().withDefault(const Constant(0))();
  
  @override
  Set<Column> get primaryKey => {id};
}

// 2. Sync Queue for offline actions
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get action => text()(); // e.g. 'update_profile', 'book_ride'
  TextColumn get payload => text()(); // JSON payload
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
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

@DriftDatabase(tables: [CachedProfiles, SyncQueue, CachedRides, CachedCategories, CachedBanners])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(
    name: 'roadrobos_local',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  ));

  @override
  int get schemaVersion => 1;
}

final localDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
