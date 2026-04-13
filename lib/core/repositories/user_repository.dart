import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
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
      final userMap = user.toMap();
      debugPrint('UserRepository: Updating Profile [ID: ${user.id}]: $userMap');
      
      // Explicit update is often safer for RLS 'update' policies than 'upsert'
      final response = await _supabase.from('profiles')
          .update(userMap)
          .eq('id', user.id)
          .select()
          .maybeSingle();

      if (response == null) {
        debugPrint('UserRepository Warning: No rows affected by update. Profile might not exist yet.');
        // Fallback to upsert if update didn't find the row (unlikely for logged-in user)
        await _supabase.from('profiles').upsert(
          userMap..addEntries([MapEntry('id', user.id)]),
          onConflict: 'id',
        );
      }
    } catch (e) {
      debugPrint('Supabase Persistence Failure: $e');
      rethrow; // Rethrow to let the notifier catch it
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
      debugPrint('Supabase Field Update Failure ($field): $e');
      rethrow;
    }
  }

  /// Upload profile picture to Supabase Storage
  Future<String> uploadProfilePicture(String uid, Uint8List fileBytes, String extension) async {
    try {
      final fileName = 'avatars/$uid.$extension';
      
      // Upload to 'profiles' bucket
      // We use upsert: true to overwrite existing avatar for this user
      await _supabase.storage.from('profiles').upload(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(upsert: true, contentType: 'image/*'),
      );

      // Get public URL
      final publicUrl = _supabase.storage.from('profiles').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Supabase Storage Upload Failure: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
}
