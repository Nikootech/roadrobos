import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:latlong2/latlong.dart';
import '../models/technician_job_model.dart';
import '../data/local_database.dart';

class TechnicianJobRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppDatabase _db;

  TechnicianJobRepository(this._db);

  // Helper: Cache a list of jobs to Drift
  Future<void> _cacheJobs(List<TechnicianJobModel> jobs) async {
    await _db.batch((batch) {
      for (final job in jobs) {
        batch.insert(
          _db.cachedTechnicianJobs,
          CachedTechnicianJobsCompanion.insert(
            id: job.id,
            vehicleModel: job.vehicleModel,
            vehiclePlate: job.vehiclePlate,
            serviceType: job.serviceType,
            packageName: job.packageName,
            date: job.date,
            time: job.time,
            progress: job.progress,
            checklist: jsonEncode(job.checklist.map((c) => c.toMap()).toList()),
            parts: jsonEncode(job.parts.map((p) => p.toMap()).toList()),
            status: job.status,
            price: job.price,
            assignedTechId: drift.Value(job.assignedTechId),
            customerId: drift.Value(job.customerId),
            serviceBookingId: drift.Value(job.serviceBookingId),
            estimatedCompletion: job.estimatedCompletion,
            createdAt: job.createdAt,
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Real-time stream of all technician jobs, ordered by creation date
  Stream<List<TechnicianJobModel>> watchAllJobs() {
    return _supabase
        .from('technician_jobs')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((list) => list
            .map((map) => TechnicianJobModel.fromMap(map, map['id'].toString()))
            .toList());
  }

  /// Offline-first stream of jobs assigned to a specific technician
  Stream<List<TechnicianJobModel>> watchJobsForTech(String techId) {
    // 1. Trigger background refresh from Supabase
    _supabase
        .from('technician_jobs')
        .select()
        .eq('assigned_tech_id', techId)
        .order('created_at', ascending: false)
        .then((data) {
      final jobs = data.map((map) => TechnicianJobModel.fromMap(map, map['id'].toString())).toList();
      _cacheJobs(jobs);
    }).catchError((e) {
      debugPrint('Supabase watchJobsForTech offline fallback: $e');
    });

    // 2. Return local Drift stream
    final query = _db.select(_db.cachedTechnicianJobs)
      ..where((t) => t.assignedTechId.equals(techId))
      ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)]);
      
    return query.watch().map((rows) {
      return rows.map((row) {
        return TechnicianJobModel(
          id: row.id,
          vehicleModel: row.vehicleModel,
          vehiclePlate: row.vehiclePlate,
          serviceType: row.serviceType,
          packageName: row.packageName,
          date: row.date,
          time: row.time,
          progress: row.progress,
          checklist: (jsonDecode(row.checklist) as List).map((c) => FirestoreChecklistItem.fromMap(c)).toList(),
          parts: (jsonDecode(row.parts) as List).map((p) => FirestoreSparePart.fromMap(p)).toList(),
          status: row.status,
          price: row.price,
          assignedTechId: row.assignedTechId,
          customerId: row.customerId,
          serviceBookingId: row.serviceBookingId,
          estimatedCompletion: row.estimatedCompletion,
          createdAt: row.createdAt,
        );
      }).toList();
    });
  }

  /// Create a new job card
  Future<String> createJob(TechnicianJobModel job) async {
    final response = await _supabase
        .from('technician_jobs')
        .insert(job.toMap())
        .select()
        .single();
    return response['id'].toString();
  }

  /// Update job status (Offline First)
  Future<void> updateJobStatus(String jobId, String status) async {
    // 1. Optimistic Local Update
    await (_db.update(_db.cachedTechnicianJobs)..where((t) => t.id.equals(jobId))).write(
      CachedTechnicianJobsCompanion(status: drift.Value(status)),
    );

    // 2. Try Supabase
    try {
      await _supabase
          .from('technician_jobs')
          .update({'status': status})
          .eq('id', jobId);
    } catch (e) {
      // 3. Queue for sync if offline
      await _db.into(_db.syncQueue).insert(
        SyncQueueCompanion.insert(
          idempotencyKey: const Uuid().v4(),
          action: 'update_job_status',
          payload: jsonEncode({'jobId': jobId, 'status': status}),
        ),
      );
      debugPrint('updateJobStatus queued for sync offline: $e');
    }
  }

  /// Update vehicle details
  Future<void> updateVehicleDetails(String jobId, String model, String plate) async {
    // Optimistic Local
    await (_db.update(_db.cachedTechnicianJobs)..where((t) => t.id.equals(jobId))).write(
      CachedTechnicianJobsCompanion(
        vehicleModel: drift.Value(model),
        vehiclePlate: drift.Value(plate),
      ),
    );

    try {
      await _supabase.from('technician_jobs').update({
        'vehicleModel': model,
        'vehiclePlate': plate,
      }).eq('id', jobId);
    } catch (e) {
      await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
        idempotencyKey: const Uuid().v4(),
        action: 'update_vehicle_details',
        payload: jsonEncode({'jobId': jobId, 'model': model, 'plate': plate}),
      ));
    }
  }

  /// Update job progress value
  Future<void> updateJobProgress(String jobId, double progress) async {
    await (_db.update(_db.cachedTechnicianJobs)..where((t) => t.id.equals(jobId))).write(
      CachedTechnicianJobsCompanion(progress: drift.Value(progress)),
    );

    try {
      await _supabase
          .from('technician_jobs')
          .update({'progress': progress})
          .eq('id', jobId);
    } catch (e) {
      await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
        idempotencyKey: const Uuid().v4(),
        action: 'update_job_progress',
        payload: jsonEncode({'jobId': jobId, 'progress': progress}),
      ));
    }
  }

  /// Toggle a checklist item at a given index
  Future<void> toggleChecklistItem(String jobId, int index) async {
    // Fetch from local db first for optimistic update
    final localJob = await (_db.select(_db.cachedTechnicianJobs)..where((t) => t.id.equals(jobId))).getSingleOrNull();
    if (localJob != null) {
      final checklist = (jsonDecode(localJob.checklist) as List).map((c) => Map<String, dynamic>.from(c)).toList();
      if (index >= 0 && index < checklist.length) {
        checklist[index]['isDone'] = !(checklist[index]['isDone'] ?? false);
        final doneCount = checklist.where((item) => item['isDone'] == true).length;
        final progress = doneCount / checklist.length;

        await (_db.update(_db.cachedTechnicianJobs)..where((t) => t.id.equals(jobId))).write(
          CachedTechnicianJobsCompanion(
            checklist: drift.Value(jsonEncode(checklist)),
            progress: drift.Value(progress),
          ),
        );

        try {
          await _supabase.from('technician_jobs').update({
            'checklist': checklist,
            'progress': progress,
          }).eq('id', jobId);
        } catch (e) {
          await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
            idempotencyKey: const Uuid().v4(),
            action: 'toggle_checklist',
            payload: jsonEncode({'jobId': jobId, 'index': index, 'checklist': checklist, 'progress': progress}),
          ));
        }
      }
    }
  }

  /// Add a spare part to a job
  Future<void> addSparePart(String jobId, FirestoreSparePart part) async {
    final localJob = await (_db.select(_db.cachedTechnicianJobs)..where((t) => t.id.equals(jobId))).getSingleOrNull();
    if (localJob != null) {
      final parts = (jsonDecode(localJob.parts) as List).map((p) => Map<String, dynamic>.from(p)).toList();
      parts.add(part.toMap());

      await (_db.update(_db.cachedTechnicianJobs)..where((t) => t.id.equals(jobId))).write(
        CachedTechnicianJobsCompanion(
          parts: drift.Value(jsonEncode(parts)),
        ),
      );

      try {
        await _supabase.from('technician_jobs').update({
          'parts': parts,
        }).eq('id', jobId);
      } catch (e) {
        await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
          idempotencyKey: const Uuid().v4(),
          action: 'add_spare_part',
          payload: jsonEncode({'jobId': jobId, 'parts': parts}),
        ));
      }
    }
  }

  /// Complete a job
  Future<void> completeJob(String jobId) async {
    await updateJobProgress(jobId, 1.0);
    await updateJobStatus(jobId, 'COMPLETED');
  }

  /// Active job metrics
  Stream<Map<String, int>> watchJobMetrics() {
    return _supabase
        .from('technician_jobs')
        .stream(primaryKey: ['id'])
        .map((list) {
      return {
        'scheduled': list.where((j) => j['status'] == 'SCHEDULED').length,
        'inProgress': list.where((j) => j['status'] == 'IN PROGRESS' || j['status'] == 'ACCEPTED').length,
        'completed': list.where((j) => j['status'] == 'COMPLETED').length,
        'total': list.length,
      };
    });
  }

  /// Update technician's real-time location
  Future<void> updateTechnicianPosition(String uid, LatLng position) async {
    try {
      await _supabase.from('technicians').update({
        'lat': position.latitude,
        'lng': position.longitude,
        'last_active': DateTime.now().toIso8601String(),
      }).eq('id', uid);
    } catch (e) {
      // Silent fail for background updates
    }
  }
}

final technicianJobRepositoryProvider = Provider<TechnicianJobRepository>((ref) {
  return TechnicianJobRepository(ref.watch(localDatabaseProvider));
});
