import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/approval.dart';
import '../models/user_role.dart';
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
        .map(
            (data) => data.map((map) => ApprovalRequest.fromMap(map)).toList());
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
      'status': status.dbValue,
      'checker_id': user.id,
      'rejection_reason': reason,
      'updated_at': DateTime.now().utcIso,
    }).eq('id', id);
  }

  /// Admin correction method: updates user profile, target role, approval request payload,
  /// and dispatches a role_changed notification to the user.
  Future<void> updateApprovalUserCorrection({
    required String approvalId,
    required String targetUserId,
    required String name,
    required String phone,
    String? email,
    required UserRole role,
    required bool isApproved,
    required Map<String, dynamic> currentPayload,
    String? correctionNotes,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) throw Exception('Admin not authenticated');

    final dbRole = AppUser.roleToDb(role);
    final nowIso = DateTime.now().utcIso;

    // 1. Update target user's profiles record in Supabase
    try {
      final profileUpdates = <String, dynamic>{
        'name': name,
        'phone': phone,
        'role': dbRole,
        'is_approved': isApproved,
        'updated_at': nowIso,
      };
      if (email != null && email.isNotEmpty) {
        profileUpdates['email'] = email;
      }
      await _supabase.from('profiles').update(profileUpdates).eq('id', targetUserId);
    } catch (e) {
      // If table update fails due to schema or offline, continue with payload update
    }

    // 2. If changing to driver, register/update driver record
    if (role == UserRole.driver) {
      try {
        final existing = await _supabase.from('drivers').select('id').eq('id', targetUserId).maybeSingle();
        if (existing == null) {
          await _supabase.from('drivers').insert({
            'id': targetUserId,
            'name': name,
            'phone': phone,
            'is_online': false,
            'approval_status': isApproved ? 'approved' : 'pending',
            'created_at': nowIso,
            'updated_at': nowIso,
          });
        } else {
          await _supabase.from('drivers').update({
            'name': name,
            'phone': phone,
            if (isApproved) 'approval_status': 'approved',
            'updated_at': nowIso,
          }).eq('id', targetUserId);
        }
      } catch (_) {}
    }

    // 3. Update the approval request's payload so Maker-Checker reflects corrected data
    final updatedPayload = Map<String, dynamic>.from(currentPayload);
    updatedPayload['applicant_name'] = name;
    updatedPayload['user_name'] = name;
    updatedPayload['name'] = name;
    updatedPayload['requester_name'] = name;
    updatedPayload['applicant_role'] = role.roleLabel;
    updatedPayload['role'] = dbRole;
    updatedPayload['phone'] = phone;
    if (email != null && email.isNotEmpty) {
      updatedPayload['email'] = email;
    }
    if (correctionNotes != null && correctionNotes.trim().isNotEmpty) {
      updatedPayload['admin_correction_notes'] = correctionNotes.trim();
    }
    updatedPayload['corrected_by_admin_id'] = currentUser.id;
    updatedPayload['last_corrected_at'] = nowIso;

    try {
      await _supabase.from('approvals').update({
        'payload': updatedPayload,
        'updated_at': nowIso,
      }).eq('id', approvalId);
    } catch (_) {}

    // 4. Send real-time notification to the target user
    try {
      await _supabase.from('user_notifications').insert({
        'user_id': targetUserId,
        'title': 'Account Role & Profile Updated',
        'description':
            'Your account role has been updated to "${role.roleLabel}" by an Administrator. Please re-login to access your new permissions and workspace.',
        'type': 'role_changed',
        'is_read': false,
        'created_at': nowIso,
      });
    } catch (_) {}
  }
}
