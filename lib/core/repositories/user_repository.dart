import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' hide Column;
import '../models/user_role.dart';

import '../data/local_database.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(localDatabaseProvider));
});

class UserRepository {
  SupabaseClient get _supabase => Supabase.instance.client;
  final AppDatabase _db;

  UserRepository(this._db);

  /// Fetch user profile from Supabase profiles table
  Future<AppUser?> getUser(String uid) async {
    // On web, always fetch fresh from Supabase.
    // The local cache doesn't persist currentDeviceId and can return stale
    // data that causes false device-mismatch logouts during the auth flow.
    if (!kIsWeb) {
      // 1. Check local cache first (mobile/desktop only)
      final local = await (_db.select(_db.cachedProfiles)
            ..where((t) => t.id.equals(uid)))
          .getSingleOrNull();
      if (local != null) {
        debugPrint('UserRepository: Returning Cached Profile for $uid');
        // Background refresh
        unawaited(
          _fetchAndCache(uid)
              .catchError((e) => debugPrint('Background Fetch Error: $e')),
        );
        return _fromCached(local);
      }
    }

    try {
      final response =
          await _supabase.from('profiles').select().eq('id', uid).maybeSingle();

      if (response != null) {
        final user = AppUser.fromMap(response, uid);
        if (!kIsWeb) await _cacheUser(user);
        return user;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<void> _fetchAndCache(String uid) async {
    final response =
        await _supabase.from('profiles').select().eq('id', uid).maybeSingle();
    if (response != null) {
      await _cacheUser(AppUser.fromMap(response, uid));
    }
  }

  Future<void> _cacheUser(AppUser user) async {
    await _db
        .into(_db.cachedProfiles)
        .insertOnConflictUpdate(CachedProfilesCompanion.insert(
          id: user.id,
          name: user.name,
          email: Value(user.email),
          phone: user.phone,
          role: user.role.name,
          profilePic: Value(user.profilePic),
          points: Value(user.points),
        ));
  }

  AppUser _fromCached(CachedProfile local) {
    return AppUser(
      id: local.id,
      name: local.name,
      email: local.email,
      phone: local.phone,
      role: UserRole.values.firstWhere((e) => e.name == local.role,
          orElse: () => UserRole.customer),
      profilePic: local.profilePic,
      points: local.points,
    );
  }

  /// Get real-time stream for user profile
  Stream<AppUser?> getUserStream(String uid) {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', uid)
        .map((data) =>
            data.isNotEmpty ? AppUser.fromMap(data.first, uid) : null);
  }

  /// Create or update user profile
  Future<void> saveUser(AppUser user) async {
    // Optimistic local update
    await _cacheUser(user);

    try {
      final userMap = user.toMap();
      debugPrint('UserRepository: Saving Profile [ID: ${user.id}]: $userMap');

      try {
        final exists = await userExists(user.id);
        if (exists) {
          await _supabase.from('profiles').update(userMap).eq('id', user.id);
        } else {
          await _supabase.from('profiles').insert(
                userMap..addEntries([MapEntry('id', user.id)]),
              );
        }
      } catch (e) {
        if (e.toString().contains('400') ||
            e.toString().contains('Bad Request')) {
          debugPrint(
              'UserRepository: 400 Bad Request with full payload. Trying safe payload.');
          // If 400 Bad Request, it usually means a column doesn't exist (e.g. role, email)
          // Try updating/inserting only safe fields
          final safeMap = {
            'name': user.name,
            'phone': user.phone,
          };

          final exists = await userExists(user.id);
          if (exists) {
            await _supabase.from('profiles').update(safeMap).eq('id', user.id);
          } else {
            await _supabase.from('profiles').insert(
                  safeMap..addEntries([MapEntry('id', user.id)]),
                );
          }
        } else {
          rethrow;
        }
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
      await _supabase.from('profiles').update({field: value}).eq('id', uid);
    } catch (e) {
      debugPrint('Supabase Field Update Failure ($field): $e');
      rethrow;
    }
  }

  /// Upload profile picture to Supabase Storage
  Future<String> uploadProfilePicture(
      String uid, Uint8List fileBytes, String extension) async {
    try {
      final fileName = 'avatars/$uid.$extension';

      // Upload to 'profiles' bucket
      // We use upsert: true to overwrite existing avatar for this user
      await _supabase.storage.from('profiles').uploadBinary(
            fileName,
            fileBytes,
            fileOptions:
                const FileOptions(upsert: true, contentType: 'image/*'),
          );

      // Get public URL with cache buster to ensure real-time UI updates
      final publicUrl =
          _supabase.storage.from('profiles').getPublicUrl(fileName);
      return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Supabase Storage Upload Failure: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
}
