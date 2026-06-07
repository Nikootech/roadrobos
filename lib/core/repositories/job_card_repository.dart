import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../extensions/datetime_extensions.dart';


final jobCardRepositoryProvider = Provider((ref) => JobCardRepository());

class JobCardRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createJobCard({
    required String techId,
    required String vehicleMake,
    required String vehicleModel,
    required String regNo,
    required String notes,
  }) async {
    try {
      await _supabase.from('job_cards').insert({
        'technician_id': techId,
        'vehicle_make': vehicleMake,
        'vehicle_model': vehicleModel,
        'registration_number': regNo,
        'notes': notes,
        'status': 'draft',
        'created_at': DateTime.now().utcIso,
      });
    } catch (e) {
      debugPrint('Create Job Card Error: $e');
      throw Exception('Failed to create job card');
    }
  }

  Future<void> startJob(String jobCardId) async {
    try {
      await _supabase.from('job_cards').update({'status': 'in_progress'}).eq('id', jobCardId);
    } catch (e) {
      debugPrint('Start Job Error: $e');
      throw Exception('Failed to start job');
    }
  }

  Future<void> completeJob(String jobCardId) async {
    try {
      await _supabase.from('job_cards').update({'status': 'completed'}).eq('id', jobCardId);
    } catch (e) {
      debugPrint('Complete Job Error: $e');
      throw Exception('Failed to complete job');
    }
  }
}
