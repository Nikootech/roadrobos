import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class RbacService {
  final SupabaseClient _supabase;
  static const String _prefsKey = 'user_permissions';

  RbacService(this._supabase);

  Future<Set<String>> fetchUserPermissions(String userId) async {
    try {
      final Set<String> permissions = {};

      // First fetch user roles
      final rolesResponse = await _supabase
          .from('user_roles')
          .select('role_id')
          .eq('user_id', userId);

      if (rolesResponse.isEmpty) return permissions;

      final roleIds = rolesResponse.map((r) => r['role_id']).toList();

      // Then fetch permissions for those roles
      final permsResponse = await _supabase
          .from('role_permissions')
          .select('permissions(name)')
          .inFilter('role_id', roleIds);

      for (var row in permsResponse) {
        final perm = row['permissions'];
        if (perm != null && perm['name'] != null) {
          permissions.add(perm['name'] as String);
        }
      }

      // If user has 'super_admin' or 'admin' role in user_roles, we inject a fallback generic permission for frontend
      // In case the DB hasn't seeded the specific granular permissions yet.
      final userRolesNames = await _supabase
          .from('user_roles')
          .select('roles(name)')
          .eq('user_id', userId);
      
      for (var row in userRolesNames) {
         final role = row['roles'];
         if (role != null) {
            final roleName = role['name'] as String;
            if (['super_admin', 'founder_admin', 'ops_head', 'city_manager', 'area_manager', 'finance_manager', 'support_manager', 'marketing_admin', 'admin'].contains(roleName)) {
               permissions.add('admin_access');
            }
            if (['driver', 'technician'].contains(roleName)) {
               permissions.add('field_staff_access');
            }
         }
      }

      // Cache result in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, permissions.toList());

      return permissions;
    } catch (e) {
      debugPrint('Error fetching user permissions: $e');
      // On error, fallback to cached permissions
      final prefs = await SharedPreferences.getInstance();
      final cachedList = prefs.getStringList(_prefsKey);
      return cachedList?.toSet() ?? {};
    }
  }

  Future<Set<String>> getCachedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedList = prefs.getStringList(_prefsKey);
    return cachedList?.toSet() ?? {};
  }

  Future<void> clearCachedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
