import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/technician_job_model.dart';

class TechnicianJobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('technician_jobs');

  /// Real-time stream of all technician jobs, ordered by creation date
  Stream<List<TechnicianJobModel>> watchAllJobs() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TechnicianJobModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Real-time stream of jobs assigned to a specific technician
  Stream<List<TechnicianJobModel>> watchJobsForTech(String techId) {
    return _collection
        .where('assignedTechId', isEqualTo: techId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TechnicianJobModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Create a new job card
  Future<String> createJob(TechnicianJobModel job) async {
    final docRef = await _collection.add(job.toMap());
    return docRef.id;
  }

  /// Update job status (SCHEDULED → ACCEPTED → IN PROGRESS → COMPLETED)
  Future<void> updateJobStatus(String jobId, String status) async {
    await _collection.doc(jobId).update({'status': status});
  }

  /// Update job progress value
  Future<void> updateJobProgress(String jobId, double progress) async {
    await _collection.doc(jobId).update({'progress': progress});
  }

  /// Toggle a checklist item at a given index
  Future<void> toggleChecklistItem(String jobId, int index) async {
    final doc = await _collection.doc(jobId).get();
    if (!doc.exists) return;
    
    final data = doc.data()!;
    final checklist = List<Map<String, dynamic>>.from(
      (data['checklist'] as List<dynamic>).map((e) => Map<String, dynamic>.from(e)),
    );
    
    if (index >= 0 && index < checklist.length) {
      checklist[index]['isDone'] = !(checklist[index]['isDone'] ?? false);
      
      // Recalculate progress
      final doneCount = checklist.where((item) => item['isDone'] == true).length;
      final progress = doneCount / checklist.length;
      
      await _collection.doc(jobId).update({
        'checklist': checklist,
        'progress': progress,
      });
    }
  }

  /// Add a spare part to a job
  Future<void> addSparePart(String jobId, FirestoreSparePart part) async {
    await _collection.doc(jobId).update({
      'parts': FieldValue.arrayUnion([part.toMap()]),
    });
  }

  /// Complete a job (set progress to 1.0 and status to COMPLETED)
  Future<void> completeJob(String jobId) async {
    await _collection.doc(jobId).update({
      'status': 'COMPLETED',
      'progress': 1.0,
    });
  }

  /// Get count of jobs by status (for admin metrics)
  Future<int> getJobCountByStatus(String status) async {
    final snapshot = await _collection.where('status', isEqualTo: status).get();
    return snapshot.docs.length;
  }

  /// Stream of active job counts for dashboard metrics
  Stream<Map<String, int>> watchJobMetrics() {
    return _collection.snapshots().map((snapshot) {
      final jobs = snapshot.docs.map((d) => d.data()).toList();
      return {
        'scheduled': jobs.where((j) => j['status'] == 'SCHEDULED').length,
        'inProgress': jobs.where((j) => j['status'] == 'IN PROGRESS' || j['status'] == 'ACCEPTED').length,
        'completed': jobs.where((j) => j['status'] == 'COMPLETED').length,
        'total': jobs.length,
      };
    });
  }
}

final technicianJobRepositoryProvider = Provider<TechnicianJobRepository>((ref) {
  return TechnicianJobRepository();
});
