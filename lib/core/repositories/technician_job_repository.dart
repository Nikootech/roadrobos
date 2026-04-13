import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/technician_job_model.dart';

class TechnicianJobRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Real-time stream of all technician jobs, ordered by creation date
  Stream<List<TechnicianJobModel>> watchAllJobs() {
    return _supabase
        .from('technician_jobs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((list) => list
            .map((map) => TechnicianJobModel.fromMap(map, map['id'].toString()))
            .toList());
  }

  /// Real-time stream of jobs assigned to a specific technician
  Stream<List<TechnicianJobModel>> watchJobsForTech(String techId) {
    return _supabase
        .from('technician_jobs')
        .stream(primaryKey: ['id'])
        .eq('assigned_tech_id', techId)
        .order('created_at', ascending: false)
        .map((list) => list
            .map((map) => TechnicianJobModel.fromMap(map, map['id'].toString()))
            .toList());
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

  /// Update job status (SCHEDULED → ACCEPTED → IN PROGRESS → COMPLETED)
  Future<void> updateJobStatus(String jobId, String status) async {
    await _supabase
        .from('technician_jobs')
        .update({'status': status})
        .eq('id', jobId);
  }

  /// Update job progress value
  Future<void> updateJobProgress(String jobId, double progress) async {
    await _supabase
        .from('technician_jobs')
        .update({'progress': progress})
        .eq('id', jobId);
  }

  /// Toggle a checklist item at a given index
  Future<void> toggleChecklistItem(String jobId, int index) async {
    final response = await _supabase
        .from('technician_jobs')
        .select('checklist')
        .eq('id', jobId)
        .single();
    
    final checklist = List<Map<String, dynamic>>.from(response['checklist']);
    
    if (index >= 0 && index < checklist.length) {
      checklist[index]['isDone'] = !(checklist[index]['isDone'] ?? false);
      
      // Recalculate progress
      final doneCount = checklist.where((item) => item['isDone'] == true).length;
      final progress = doneCount / checklist.length;
      
      await _supabase.from('technician_jobs').update({
        'checklist': checklist,
        'progress': progress,
      }).eq('id', jobId);
    }
  }

  /// Add a spare part to a job
  Future<void> addSparePart(String jobId, FirestoreSparePart part) async {
    final response = await _supabase
        .from('technician_jobs')
        .select('parts')
        .eq('id', jobId)
        .single();
    
    final parts = List<Map<String, dynamic>>.from(response['parts'] ?? []);
    parts.add(part.toMap());

    await _supabase.from('technician_jobs').update({
      'parts': parts,
    }).eq('id', jobId);
  }

  /// Complete a job (set progress to 1.0 and status to COMPLETED)
  Future<void> completeJob(String jobId) async {
    await _supabase.from('technician_jobs').update({
      'status': 'COMPLETED',
      'progress': 1.0,
    }).eq('id', jobId);
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
}

final technicianJobRepositoryProvider = Provider<TechnicianJobRepository>((ref) {
  return TechnicianJobRepository();
});
