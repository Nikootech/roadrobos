import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/rbac_service.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final rbacServiceProvider = Provider<RbacService>((ref) {
  return RbacService(Supabase.instance.client);
});

/// FutureProvider that returns the current user's cached permissions.
final userPermissionsProvider = FutureProvider<Set<String>>((ref) async {
  final rbac = ref.watch(rbacServiceProvider);
  return rbac.getCachedPermissions();
});

// ── PermissionGate widget ────────────────────────────────────────────────────

/// A widget that conditionally shows [child] based on whether the current user
/// has a specific RBAC [permission].
///
/// When the user lacks the permission, [fallback] is shown (defaults to
/// [SizedBox.shrink] so the widget takes up no space).
///
/// RLS on the database enforces the real security boundary — this widget
/// only controls UI visibility.
///
/// Example:
/// ```dart
/// PermissionGate(
///   permission: 'admin_access',
///   child: AdminPanel(),
///   fallback: Text('You do not have access to this section.'),
/// )
/// ```
class PermissionGate extends ConsumerWidget {
  final String permission;
  final Widget child;
  final Widget? fallback;

  const PermissionGate({
    super.key,
    required this.permission,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(userPermissionsProvider);

    return permissionsAsync.when(
      data: (permissions) {
        if (permissions.contains(permission)) {
          return child;
        }
        return fallback ?? const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => fallback ?? const SizedBox.shrink(),
    );
  }
}

// ── 403 Forbidden screen ─────────────────────────────────────────────────────

/// Shown when a user navigates to a route they don't have permission to access.
class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '403 — Access Denied',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              "You don't have permission to view this page.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
