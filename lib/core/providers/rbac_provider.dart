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
