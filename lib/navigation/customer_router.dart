import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/auth_service.dart';
import '../core/services/local_storage_service.dart';
import '../features/profile/user_provider.dart';
import '../core/models/user_role.dart';
import '../shared/widgets/not_found_screen.dart';
import '../shared/widgets/wrong_app_screen.dart';
import '../core/security/deeplink_validator.dart';

// Customer app route groups
import 'routes/auth_routes.dart';
import 'routes/customer_routes.dart';
import 'routes/admin_routes.dart';

export 'routes/customer_routes.dart' show shellNavigatorKey;


final customerRootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'customerRoot');

final customerFirstLaunchCacheProvider = StateProvider<bool?>((ref) => null);

class CustomerRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  CustomerRouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
    _ref.listen(userProvider, (_, __) => notifyListeners());
    _ref.listen(passwordRecoveryProvider, (_, __) => notifyListeners());
    _ref.listen(customerFirstLaunchCacheProvider, (_, __) => notifyListeners());

    _ref.read(localStorageServiceProvider).isFirstLaunch().then((value) {
      _ref.read(customerFirstLaunchCacheProvider.notifier).state = value;
    });
  }
}

final customerRouterNotifierProvider =
    Provider((ref) => CustomerRouterNotifier(ref));

final customerRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(customerRouterNotifierProvider);

  return GoRouter(
    navigatorKey: customerRootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,

    errorBuilder: (context, state) =>
        NotFoundScreen(path: state.uri.toString()),

    redirect: (context, state) {
      // 1. Password recovery detection
      final uri = Uri.base;
      if (uri.fragment.contains('type=recovery') ||
          uri.fragment.contains('recovery_token') ||
          uri.queryParameters['type'] == 'recovery') {
        ref.read(passwordRecoveryProvider.notifier).state = true;
      }

      final isRecovering = ref.read(passwordRecoveryProvider);
      if (isRecovering) {
        if (state.matchedLocation != '/reset-password') {
          return '/reset-password';
        }
        return null;
      }

      // 2. Deeplink validation
      if (state.uri.path == '/login-callback') {
        if (!DeeplinkValidator.isValid(state.uri)) {
          return '/auth/login';
        }
      }

      final authState = ref.read(authNotifierProvider);
      final userState = ref.read(userProvider);

      if (authState.isLoading) {
        return null;
      }

      final isLoggedIn = authState.value != null;
      final user = userState.user;
      final location = state.matchedLocation;

      // In Customer App, role selection is eliminated; redirect any role-selection request to /auth/login
      if (location == '/auth/role-selection') {
        return '/auth/login';
      }

      final publicPaths = [
        '/',
        '/splash',
        '/onboarding',
        '/auth/pending-approval',
        '/auth/login',
        '/auth/register',
        '/login-callback',
        '/reset-password',
        '/wrong-app',
        '/privacy-policy',
        '/terms-of-service',
      ];
      final isPublicPath = publicPaths.contains(location);

      // Unauthenticated redirect
      if (!isLoggedIn && !isPublicPath) {
        return '/auth/login';
      }

      // Employee approval check
      if (isLoggedIn && user != null) {
        if (!user.isApproved && user.role.isEmployee) {
          if (location != '/auth/pending-approval') {
            return '/auth/pending-approval';
          }
          return null;
        }
      }

      // Legal screens are freely viewable by both guest and logged-in users
      if (location == '/privacy-policy' || location == '/terms-of-service') {
        return null;
      }

      // Public auth landing path redirection when logged in
      if (isLoggedIn && isPublicPath && location != '/wrong-app') {
        if (user == null && userState.error != null && !userState.isLoading) {
          return '/auth/login';
        }
        if (user == null) {
          return null;
        }

        // FLAVOR ISOLATION: If logged-in user is a partner (driver or technician),
        // redirect them to /wrong-app screen in the Customer App.
        if (user.role == UserRole.driver || user.role == UserRole.technician) {
          return '/wrong-app';
        }

        if (user.role.isAdmin) {
          return '/admin-home';
        }
        return '/main/home';
      }

      // FLAVOR ISOLATION & ROLE GUARDS
      if (isLoggedIn && user != null) {
        // Partners trying to navigate inside Customer App
        if ((user.role == UserRole.driver || user.role == UserRole.technician) &&
            location != '/wrong-app') {
          return '/wrong-app';
        }

        // Admin guard
        if ((location.startsWith('/admin-') || location.startsWith('/admin/'))) {
          if (!user.role.isAdmin) {
            return '/main/home';
          }
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/wrong-app',
        builder: (context, state) => const WrongAppScreen(
          targetApp: 'RoadRobos Partner',
          message:
              'You are registered as a Partner (Driver / Pilot or Service Technician). Please use the RoadRobos Partner app to manage your trips and service jobs.',
        ),
      ),
      ...authRoutes,
      ...customerRoutes,
      ...adminRoutes,
    ],
  );
});
