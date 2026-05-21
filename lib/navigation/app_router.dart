import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/auth_service.dart';
import '../features/profile/user_provider.dart';
import '../core/models/user_role.dart';
import '../shared/widgets/not_found_screen.dart';

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
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
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
      final authState = ref.read(authStateProvider);
      final userState = ref.read(userProvider);

      // A user is "logged in" if:
      // 1. Firebase Auth has a real user, OR
      // 2. Demo mode is active with a loaded profile, OR
      // 3. UserProvider has a user with a demo_ ID (handles race conditions)
      final hasFirebaseUser = authState.value != null;
      final hasDemoUser = userState.isDemo && userState.user != null;
      final hasDemoIdUser =
          userState.user != null && userState.user!.id.startsWith('demo_');
      final isLoggedIn = hasFirebaseUser || hasDemoUser || hasDemoIdUser;
      final user = userState.user;
      final location = state.matchedLocation;

      if (kDebugMode) {
        debugPrint(
          'Router: location=$location, hasFirebaseUser=$hasFirebaseUser, '
          'hasDemoUser=$hasDemoUser, hasDemoIdUser=$hasDemoIdUser, '
          'isLoggedIn=$isLoggedIn, user=${user?.name}, isDemo=${userState.isDemo}',
        );
      }

      final publicPaths = [
        '/splash',
        '/onboarding',
        '/auth/login',
        '/auth/register',
      ];
      final isPublicPath = publicPaths.contains(location);

      if (!isLoggedIn && !isPublicPath) {
        debugPrint('Router: Not logged in, redirecting to /auth/login');
        return '/auth/login';
      }

      if (isLoggedIn && isPublicPath) {
        // If profile isn't loaded yet, wait on login screen
        if (user == null) return null;

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
        if (location.startsWith('/driver-') &&
            user.role != UserRole.driver) {
          return '/main/home';
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
