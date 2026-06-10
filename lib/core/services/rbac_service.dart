import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RBAC Service — loads user permissions via a single Supabase RPC.
///
/// The `get_user_permissions` PostgreSQL function (see migration
/// 20260610_004_get_user_permissions_rpc.sql) performs a single JOIN across
/// user_roles, role_permissions, and permissions — replacing the previous
/// N+1 sequential query pattern.
///
/// Permissions are cached in-memory (keyed by userId) and in SharedPreferences
/// for persistence across cold starts. Cache is invalidated on logout.
class RbacService {
  final SupabaseClient _supabase;
  static const String _prefsKey = 'user_permissions';

  // In-memory cache: userId → Set<permission_name>
  final Map<String, Set<String>> _cache = {};

  RbacService(this._supabase);

  /// Fetches user permissions via a single `get_user_permissions` RPC.
  /// Results are stored in SharedPreferences and the in-memory cache.
  Future<Set<String>> fetchUserPermissions(String userId) async {
    try {
      // Single RPC — replaces 3 sequential queries (N+1 fix).
      // The RPC performs JOIN: user_roles → role_permissions → permissions.
      final response = await _supabase.rpc(
        'get_user_permissions',
        params: {'p_user_id': userId},
      ) as List<dynamic>;

      final Set<String> permissions = {};
      for (final row in response) {
        final permName = row['permission_name'] as String?;
        if (permName != null && permName.isNotEmpty) {
          permissions.add(permName);
        }
      }

      // Inject role-based shorthand permissions for frontend gate checks
      final rolesResponse = await _supabase
          .from('user_roles')
          .select('roles(name)')
          .eq('user_id', userId);

      for (final row in rolesResponse) {
        final role = row['roles'];
        if (role != null) {
          final roleName = role['name'] as String;
          if (['super_admin', 'founder_admin', 'ops_head', 'city_manager',
               'area_manager', 'finance_manager', 'support_manager',
               'marketing_admin', 'admin'].contains(roleName)) {
            permissions.add('admin_access');
          }
          if (['driver', 'technician'].contains(roleName)) {
            permissions.add('field_staff_access');
          }
        }
      }

      // Update in-memory cache
      _cache[userId] = permissions;

      // Persist to SharedPreferences for cold-start restore
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, permissions.toList());

      if (kDebugMode) {
        debugPrint('RbacService: Loaded ${permissions.length} permissions for user $userId');
      }
      return permissions;
    } catch (e) {
      debugPrint('RbacService: Error fetching permissions: $e');
      // Fallback to in-memory cache first, then SharedPreferences
      if (_cache.containsKey(userId)) {
        return _cache[userId]!;
      }
      final prefs = await SharedPreferences.getInstance();
      final cachedList = prefs.getStringList(_prefsKey);
      return cachedList?.toSet() ?? {};
    }
  }

  /// Returns cached permissions without a network call.
  Future<Set<String>> getCachedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedList = prefs.getStringList(_prefsKey);
    return cachedList?.toSet() ?? {};
  }

  /// Checks if the current user has a specific permission.
  /// Uses in-memory cache when available, falls back to SharedPreferences.
  Future<bool> hasPermission(String permission) async {
    final cached = await getCachedPermissions();
    return cached.contains(permission);
  }

  /// Clears all cached permissions. Call this on logout.
  Future<void> clearCache() async {
    _cache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    if (kDebugMode) {
      debugPrint('RbacService: Permission cache cleared.');
    }
  }
}
