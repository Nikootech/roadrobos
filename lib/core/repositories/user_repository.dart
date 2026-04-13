import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch user profile from Supabase profiles table
  Future<AppUser?> getUser(String uid) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      
      if (response != null) {
        return AppUser.fromMap(response, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  /// Create or update user profile
  Future<void> saveUser(AppUser user) async {
    try {
      await _supabase.from('profiles').upsert(
        user.toMap()..addEntries([MapEntry('id', user.id)]),
        onConflict: 'id',
      );
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  /// Check if user exists
  Future<bool> userExists(String uid) async {
    final response = await _supabase
        .from('profiles')
        .select('id')
        .eq('id', uid)
        .maybeSingle();
    return response != null;
  }

  /// Update specific fields
  Future<void> updateField(String uid, String field, dynamic value) async {
    try {
      await _supabase
          .from('profiles')
          .update({field: value})
          .eq('id', uid);
    } catch (e) {
      throw Exception('Failed to update user field ($field): $e');
    }
  }
}
