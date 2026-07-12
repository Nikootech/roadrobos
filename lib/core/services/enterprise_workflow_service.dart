import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../extensions/datetime_extensions.dart';

/// A consolidated service for Enterprise workflows:
/// 1. Push Notification Synchronization
/// 2. Instant Document Upload Tracking
///
/// NOTE (MED-04): Password reset was removed from this class.
/// Use [AuthService.resetPassword] and [AuthService.updatePassword] instead.
/// EnterpriseWorkflowService had duplicate implementations that diverged —
/// keeping password reset in one place (AuthService) avoids future inconsistency.
class EnterpriseWorkflowService {
  SupabaseClient get _supabase => Supabase.instance.client;
  FirebaseMessaging? get _fcm =>
      Firebase.apps.isNotEmpty ? FirebaseMessaging.instance : null;

  // ---------------------------------------------------------------------------
  // 1. PUSH NOTIFICATION SYNC
  // ---------------------------------------------------------------------------

  /// Syncs the FCM token with the user's profile to enable push notifications.
  Future<void> syncPushToken() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final fcm = _fcm;
    if (fcm == null) {
      debugPrint('FCM Sync skipped: Firebase not initialized.');
      return;
    }

    try {
      final String? token = await fcm.getToken();
      if (token != null) {
        await _supabase.from('profiles').update({
          'fcm_token': token,
        }).eq('id', user.id);
      }
    } catch (e) {
      debugPrint('FCM Sync Error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 2. DOCUMENT UPLOAD & APPROVAL TRIGGER
  // ---------------------------------------------------------------------------

  /// Submits a document for approval and links it to the storage bucket.
  Future<void> submitForApproval({
    required String type, // 'partner_kyc', 'vehicle_attachment'
    required String entityId,
    required String documentUrl,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _supabase.from('approvals').insert({
        'type': type,
        'entity_type': type == 'partner_kyc' ? 'profiles' : 'vehicles',
        'entity_id': entityId,
        'maker_id': user.id,
        'status': 'pending',
        'payload': {
          'document_url': documentUrl,
          ...?additionalData,
          'submitted_at': DateTime.now().utcIso,
        },
      });
    } catch (e) {
      debugPrint('Approval Submission Error: $e');
      rethrow;
    }
  }
}
