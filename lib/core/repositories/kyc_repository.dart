import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      'updated_at': DateTime.now().toIso8601String(),
    });
    
    // Also update profile kyc_status
    await _supabase.from('profiles').update({
      'kyc_status': 'pending',
    }).eq('id', userId);
  }
}
