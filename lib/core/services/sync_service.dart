import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../data/local_database.dart';

class SyncService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppDatabase _db;
  bool _isSyncing = false;

  SyncService(this._db) {
    // Listen to network changes and trigger sync
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.any((result) => result != ConnectivityResult.none)) {
        syncPendingQueue();
      }
    });
  }

  Future<void> syncPendingQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pendingTasks = await _db.select(_db.syncQueue).get();
      if (pendingTasks.isEmpty) return;

      debugPrint('Starting background sync for ${pendingTasks.length} offline actions...');

      for (final task in pendingTasks) {
        try {
          final payload = jsonDecode(task.payload);
          bool success = false;

          switch (task.action) {
            case 'update_job_status':
              await _supabase.from('technician_jobs').update({'status': payload['status']}).eq('id', payload['jobId']);
              success = true;
              break;
            case 'update_vehicle_details':
              await _supabase.from('technician_jobs').update({
                'vehicleModel': payload['model'],
                'vehiclePlate': payload['plate'],
              }).eq('id', payload['jobId']);
              success = true;
              break;
            case 'update_job_progress':
              await _supabase.from('technician_jobs').update({'progress': payload['progress']}).eq('id', payload['jobId']);
              success = true;
              break;
            case 'toggle_checklist':
              await _supabase.from('technician_jobs').update({
                'checklist': payload['checklist'],
                'progress': payload['progress'],
              }).eq('id', payload['jobId']);
              success = true;
              break;
            case 'add_spare_part':
              await _supabase.from('technician_jobs').update({
                'parts': payload['parts'],
              }).eq('id', payload['jobId']);
              success = true;
              break;
            default:
              debugPrint('Unknown sync action: ${task.action}');
              success = true; // Delete unknown actions to avoid infinite loop
          }

          if (success) {
            await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(task.id))).go();
            debugPrint('Synced task: ${task.action}');
          }
        } catch (e) {
          debugPrint('Failed to sync task ${task.action}: $e');
          // Increment attempts
          await (_db.update(_db.syncQueue)..where((t) => t.id.equals(task.id))).write(
            SyncQueueCompanion(attempts: drift.Value(task.attempts + 1)),
          );
        }
      }
    } finally {
      _isSyncing = false;
    }
  }
}

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.watch(localDatabaseProvider));
});
