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
      // If we are recovering password, force /reset-password
      final isRecovering = ref.read(passwordRecoveryProvider);
      if (isRecovering) {
        if (state.matchedLocation != '/reset-password') {
          return '/reset-password';
        }
        return null;
      }

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

      // ── Auth loading guard ─────────────────────────────────────────────────
      // If AuthNotifier.build() hasn't resolved yet (AsyncLoading), we must
      // NOT redirect — authState.value is null even for logged-in users.
      // Stay on the current route (return null) until the state settles.
      if (authState.isLoading) {
        if (kDebugMode) debugPrint('Router: authState still loading — holding route.');
        return null;
      }

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
          'profileLoading=${userState.isLoading} role=${user?.role} profileError=${userState.error}',
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
        '/reset-password',
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
        // Profile load error — break deadlock
        if (user == null && userState.error != null && !userState.isLoading) {
          if (kDebugMode) debugPrint('Router: Profile load error → /auth/login');
          return '/auth/login';
        }

        // Profile still loading — stay on current public route and wait.
        // ── KEY FIX ──────────────────────────────────────────────────────────
        // Previously this returned '/splash' for any non-splash public path
        // (e.g. /auth/login after sign-in), causing a visible splash bounce.
        // Now we return null (stay put) for ALL public paths while loading.
        // GoRouter will re-run this redirect automatically when userProvider
        // emits the loaded profile, and then redirect to the correct home.
        // SplashScreen's own polling loop handles the /splash timeout case.
        if (user == null) {
          if (kDebugMode) {
            debugPrint('Router: Profile loading on $location — holding redirect.');
          }
          return null; // Stay on current public page, no splash bounce
        }

        // Profile loaded — redirect based on role
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
        if ((location.startsWith('/admin-') || location.startsWith('/admin/')) && !user.role.isAdmin) {
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
