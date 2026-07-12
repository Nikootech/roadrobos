import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/profile/user_provider.dart';
import '../services/rbac_service.dart';

final rbacServiceProvider = Provider<RbacService>((ref) {
  return RbacService(Supabase.instance.client);
});

final permissionsProvider = FutureProvider<Set<String>>((ref) async {
  final userState = ref.watch(userProvider);
  final user = userState.user;

  final rbacService = ref.read(rbacServiceProvider);

  if (user == null) {
    return await rbacService.getCachedPermissions();
  }

  // Use the demo mock logic if user is a demo user
  if (userState.isDemo || user.id.startsWith('demo_')) {
    final Set<String> permissions = {};
    if ([
      'super_admin',
      'founder_admin',
      'ops_head',
      'city_manager',
      'area_manager',
      'finance_manager',
      'support_manager',
      'marketing_admin',
      'admin'
    ].contains(user.role.name)) {
      permissions.add('admin_access');
    }
    if (['driver', 'technician'].contains(user.role.name)) {
      permissions.add('field_staff_access');
    }
    return permissions;
  }

  return await rbacService.fetchUserPermissions(user.id);
});

final hasPermissionProvider =
    Provider.family<bool, String>((ref, permissionName) {
  final permissionsAsync = ref.watch(permissionsProvider);

  return permissionsAsync.when(
    data: (permissions) => permissions.contains(permissionName),
    loading: () =>
        false, // Consider defaulting to cached if needed, but false is safer
    error: (_, __) => false,
  );
});
