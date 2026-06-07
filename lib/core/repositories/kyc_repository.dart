import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../extensions/datetime_extensions.dart';


final kycRepositoryProvider = Provider<KycRepository>((ref) {
  return KycRepository();
});

class KycRepository {
  final _supabase = Supabase.instance.client;

  Future<void> submitKyc({
    required String userId,
    required String documentType,
    String? documentNumber,
    required String documentUrl,
  }) async {
    await _supabase.from('partner_kyc').upsert({
      'user_id': userId,
      'document_type': documentType,
      'document_number': documentNumber,
      'document_url': documentUrl,
      'status': 'pending',
      'updated_at': DateTime.now().utcIso,
    });

    unawaited(Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'KYC submitted',
        category: 'kyc',
        data: {
          'user_id': userId,
          'document_type': documentType,
        },
      ),
    ));
    
    // Also update profile kyc_status if it's not already something else
    await _supabase.from('profiles').update({
      'kyc_status': 'pending',
    }).eq('id', userId);
  }

  Future<List<Map<String, dynamic>>> getKycStatus(String userId) async {
    final response = await _supabase
        .from('partner_kyc')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Stream<List<Map<String, dynamic>>> streamKycUpdates(String userId) {
    return _supabase
        .from('partner_kyc')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}
