import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/auth_service.dart';
import '../features/profile/user_provider.dart';
import '../core/models/user_role.dart';
import '../shared/widgets/not_found_screen.dart';
import '../core/security/deeplink_validator.dart';

// Modular route groups
import 'routes/auth_routes.dart';
import 'routes/customer_routes.dart';
import 'routes/driver_routes.dart';
import 'routes/tech_routes.dart';
import 'routes/admin_routes.dart';

export 'routes/customer_routes.dart' show shellNavigatorKey;

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
    _ref.listen(userProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/splash',
    debugLogDiagnostics: true,

    // Fallback for invalid routes — shows proper 404 page
    errorBuilder: (context, state) =>
        NotFoundScreen(path: state.uri.toString()),

    // Auth guard and navigation redirect logic
    redirect: (context, state) {
      // ── S6: Deeplink validation ──────────────────────────────────────────
      // Reject forged OAuth callbacks and path-traversal deeplinks.
      if (state.uri.path == '/login-callback') {
        if (!DeeplinkValidator.isValid(state.uri)) {
          if (kDebugMode) {
            debugPrint('Router: rejected invalid deeplink: ${state.uri}');
          }
          return '/auth/login'; // safe fallback
        }
      }

      final authState = ref.read(authNotifierProvider);
      final userState = ref.read(userProvider);

      final hasFirebaseUser = authState.value != null;
      final hasDemoUser = userState.isDemo && userState.user != null;
      final hasDemoIdUser =
          userState.user != null && userState.user!.id.startsWith('demo_');
      final isLoggedIn = hasFirebaseUser || hasDemoUser || hasDemoIdUser;
      final user = userState.user;
      final location = state.matchedLocation;

      if (kDebugMode) {
        debugPrint(
          'Router: location=$location isLoggedIn=$isLoggedIn '
          'role=${user?.role} profileError=${userState.error}',
        );
      }

      final publicPaths = [
        '/',
        '/splash',
        '/onboarding',
        '/auth/role-selection',
        '/auth/pending-approval',
        '/auth/login',
        '/auth/register',
        '/login-callback',
      ];
      final isPublicPath = publicPaths.contains(location);

      if (!isLoggedIn && !isPublicPath) {
        if (kDebugMode) debugPrint('Router: unauthenticated → /auth/role-selection');
        return '/auth/role-selection';
      }

      // Enforce Employee approval checks
      if (isLoggedIn && user != null) {
        if (!user.isApproved && user.role.isEmployee) {
          if (location != '/auth/pending-approval') {
            if (kDebugMode) debugPrint('Router: Employee pending approval → /auth/pending-approval');
            return '/auth/pending-approval';
          }
          return null;
        }
      }

      if (isLoggedIn && isPublicPath) {
        // If profile failed to load (error + not loading + no user), break deadlock
        if (user == null && userState.error != null && !userState.isLoading) {
          if (kDebugMode) debugPrint('Router: Profile load error → /auth/login');
          return '/auth/login';
        }

        // If profile isn't loaded yet, go to splash screen to show a loading state
        if (user == null) {
          if (location == '/splash') return null;
          return '/splash';
        }

        // Redirect based on role
        if (user.role.isAdmin) {
          return '/admin-home';
        }
        switch (user.role) {
          case UserRole.driver:
            return '/driver-home';
          case UserRole.technician:
            return '/tech-dashboard';
          case UserRole.customer:
            return '/main/home';
          default:
            return '/main/home';
        }
      }

      // -- Simple Role Guards --
      if (isLoggedIn && user != null) {
        if (location.startsWith('/admin-') && !user.role.isAdmin) {
          return '/main/home'; // Unauthorised
        }
        if (location.startsWith('/tech-') &&
            user.role != UserRole.technician) {
          return '/main/home';
        }
        if (location.startsWith('/driver-') || location.startsWith('/driver/')) {
          if (user.role != UserRole.driver) {
            return '/main/home';
          }
          // Driver KYC guard
          if (user.kycStatus != 'approved' &&
              location != '/driver/kyc-status' &&
              location != '/driver/kyc-upload') {
            return '/driver/kyc-status';
          }
        }
      }

      return null;
    },

    routes: [
      ...authRoutes,
      ...customerRoutes,
      ...driverRoutes,
      ...techRoutes,
      ...adminRoutes,
    ],
  );
});
