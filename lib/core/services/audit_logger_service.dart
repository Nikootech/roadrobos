import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_role.dart';
import '../../features/profile/user_provider.dart';

/// Centralized Enterprise Audit Logging Service.
/// Automatically records security, dispatch, financial and role-impersonation events.
class AuditLoggerService {
  final SupabaseClient _supabase;
  final Ref _ref;

  AuditLoggerService(this._supabase, this._ref);

  Future<void> logEvent({
    required String action,
    required String category,
    Map<String, dynamic>? details,
  }) async {
    final user = _ref.read(userProvider).user;
    final actorId = user?.id ?? 'system';
    final actorRole = user?.role.name ?? 'unknown';

    final payload = {
      'actor_id': actorId,
      'actor_role': actorRole,
      'action': action,
      'category': category,
      'details': details ?? {},
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };

    if (kDebugMode) {
      debugPrint('AUDIT LOG: [$category] $action by $actorId ($actorRole) -> $details');
    }

    try {
      await _supabase.from('audit_logs').insert(payload);
    } catch (e) {
      // Graceful fallback in case table is offline or permission error
      if (kDebugMode) {
        debugPrint('AuditLoggerService: silent catch on insert: $e');
      }
    }
  }

  /// Convenience loggers for high-frequency admin actions
  Future<void> logDispatch({required String jobId, required String techId}) =>
      logEvent(
        action: 'TECHNICIAN_DISPATCH',
        category: 'OPERATIONS',
        details: {'job_id': jobId, 'tech_id': techId},
      );

  Future<void> logKycApproval({required String driverId, required bool approved}) =>
      logEvent(
        action: approved ? 'KYC_APPROVED' : 'KYC_REJECTED',
        category: 'COMPLIANCE',
        details: {'driver_id': driverId, 'approved': approved},
      );

  Future<void> logDisputeResolution({
    required String disputeId,
    required double refundAmount,
  }) =>
      logEvent(
        action: 'DISPUTE_RESOLVED',
        category: 'FINANCE',
        details: {'dispute_id': disputeId, 'refund_amount': refundAmount},
      );

  Future<void> logRoleImpersonation({required UserRole targetRole}) =>
      logEvent(
        action: 'ROLE_IMPERSONATION',
        category: 'SECURITY',
        details: {'target_role': targetRole.name},
      );
}

final auditLoggerServiceProvider = Provider<AuditLoggerService>((ref) {
  return AuditLoggerService(Supabase.instance.client, ref);
});
