import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval.dart';
import '../extensions/datetime_extensions.dart';


final approvalRepositoryProvider = Provider<ApprovalRepository>((ref) {
  return ApprovalRepository();
});

class ApprovalRepository {
  final _supabase = Supabase.instance.client;

  Stream<List<ApprovalRequest>> watchPendingApprovals() {
    return _supabase
        .from('approvals')
        .stream(primaryKey: ['id'])
        .eq('status', 'pending')
        .order('created_at')
        .map((data) => data.map((map) => ApprovalRequest.fromMap(map)).toList());
  }

  Future<void> createApprovalRequest({
    required ApprovalType type,
    required String entityType,
    String? entityId,
    required Map<String, dynamic> payload,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('approvals').insert({
      'type': type.dbValue,
      'entity_type': entityType,
      'entity_id': entityId,
      'payload': payload,
      'maker_id': user.id,
    });
  }

  Future<void> updateApprovalStatus({
    required String id,
    required ApprovalStatus status,
    String? reason,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _supabase.from('approvals').update({
      'status': status.name,
      'checker_id': user.id,
      'rejection_reason': reason,
      'updated_at': DateTime.now().utcIso,
    }).eq('id', id);
  }
}
