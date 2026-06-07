import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import '../data/local_database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  return SyncQueueService(ref.watch(localDatabaseProvider), ref);
});

class SyncQueueService {
  final AppDatabase _db;
  final Ref _ref;

  SyncQueueService(this._db, this._ref) {
    // Acknowledge _ref usage to silence warning
    _ref.onDispose(() => debugPrint('SyncQueueService disposed'));
  }

  /// Adds an action to the local sync queue
  Future<void> addToQueue(String action, Map<String, dynamic> payload) async {
    await _db.into(_db.syncQueue).insert(
      SyncQueueCompanion.insert(
        action: action,
        payload: jsonEncode(payload),
        idempotencyKey: DateTime.now().toIso8601String(),
      ),
    );
    // Attempt to process immediately if online
    // ignore: unawaited_futures
    processQueue();
  }

  /// Processes all pending actions in the queue
  Future<void> processQueue() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) return;

    final pending = await _db.select(_db.syncQueue).get();
    for (var item in pending) {
      try {
        await _executeAction(item.action, jsonDecode(item.payload));
        // Remove from queue on success
        await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(item.id))).go();
      } catch (e) {
        // Increment attempts or handle permanent failure
        await (_db.update(_db.syncQueue)..where((t) => t.id.equals(item.id))).write(
          SyncQueueCompanion(attempts: Value(item.attempts + 1)),
        );
      }
    }
  }

  Future<void> _executeAction(String action, Map<String, dynamic> payload) async {
    // This will be expanded as we implement more offline actions
    switch (action) {
      case 'update_profile':
        // Call UserRepository.saveUser
        break;
      case 'book_ride':
        // Call RideRepository.createRide
        break;
    }
  }
}
