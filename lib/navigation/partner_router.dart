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

// Partner app route groups
import 'routes/auth_routes.dart';
import 'routes/driver_routes.dart';
import 'routes/tech_routes.dart';
import '../features/partner/onboarding/partner_welcome_screen.dart';
import '../features/partner/onboarding/partner_bank_details_screen.dart';
import '../features/partner/demand_map/demand_heatmap_screen.dart';


final partnerRootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'partnerRoot');

final partnerFirstLaunchCacheProvider = StateProvider<bool?>((ref) => null);

class PartnerRouterNotifier extends ChangeNotifier {
  final Ref _ref;
  PartnerRouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (_, __) => notifyListeners());
    _ref.listen(userProvider, (_, __) => notifyListeners());
    _ref.listen(passwordRecoveryProvider, (_, __) => notifyListeners());
    _ref.listen(partnerFirstLaunchCacheProvider, (_, __) => notifyListeners());

    _ref.read(localStorageServiceProvider).isFirstLaunch().then((value) {
      _ref.read(partnerFirstLaunchCacheProvider.notifier).state = value;
    });
  }
}

final partnerRouterNotifierProvider =
    Provider((ref) => PartnerRouterNotifier(ref));

final partnerRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(partnerRouterNotifierProvider);

  return GoRouter(
    navigatorKey: partnerRootNavigatorKey,
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

      final isLoggedIn = authState.value != null || userState.user != null;
      final user = userState.user;
      final location = state.matchedLocation;

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
        '/wrong-app',
        '/partner/welcome',
        '/privacy-policy',
        '/terms-of-service',
      ];
      final isPublicPath = publicPaths.contains(location);

      // Unauthenticated redirect
      if (!isLoggedIn && (!isPublicPath || location == '/wrong-app')) {
        final isFirstLaunch = ref.read(partnerFirstLaunchCacheProvider);
        return (isFirstLaunch == true) ? '/partner/welcome' : '/auth/login';
      }

      // Legal screens are freely viewable by both guest and logged-in users
      if (location == '/privacy-policy' || location == '/terms-of-service') {
        return null;
      }

      // Public path redirection when logged in
      if (isLoggedIn && isPublicPath && location != '/wrong-app') {
        if (user == null && userState.error != null && !userState.isLoading) {
          return '/auth/login';
        }
        if (user == null) {
          return null;
        }

        // FLAVOR ISOLATION: If logged-in user is a customer or admin,
        // redirect them to /wrong-app screen in the Partner App.
        if (user.role == UserRole.customer || user.role.isAdmin) {
          return '/wrong-app';
        }

        if (user.role == UserRole.technician) {
          return '/tech-dashboard';
        }
        if (user.role == UserRole.driver) {
          if (user.kycStatus != 'approved' &&
              location != '/driver/kyc-status' &&
              location != '/driver/kyc-upload') {
            return '/driver/kyc-status';
          }
          return '/driver-home';
        }
      }

      // FLAVOR ISOLATION & ROLE GUARDS
      if (isLoggedIn && user != null) {
        // Non-partners (customers or admins) trying to access Partner App screens
        if ((user.role == UserRole.customer || user.role.isAdmin) &&
            location != '/wrong-app') {
          return '/wrong-app';
        }

        // Driver role guard inside Partner App
        if (location.startsWith('/driver-') || location.startsWith('/driver/')) {
          if (user.role != UserRole.driver) {
            return '/tech-dashboard';
          }
          if (user.kycStatus != 'approved' &&
              location != '/driver/kyc-status' &&
              location != '/driver/kyc-upload') {
            return '/driver/kyc-status';
          }
        }

        // Technician role guard inside Partner App
        if (location.startsWith('/tech-')) {
          if (user.role != UserRole.technician) {
            return '/driver-home';
          }
        }
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/wrong-app',
        builder: (context, state) => const WrongAppScreen(
          targetApp: 'RoadRobos',
          message:
              'You are registered as a Customer or Platform Admin. Please use the primary RoadRobos app to book rides and access account services.',
        ),
      ),
      GoRoute(
        path: '/partner/welcome',
        builder: (context, state) => const PartnerWelcomeScreen(),
      ),
      GoRoute(
        path: '/partner/bank-details',
        builder: (context, state) => const PartnerBankDetailsScreen(),
      ),
      GoRoute(
        path: '/partner/demand-heatmap',
        builder: (context, state) => const DemandHeatmapScreen(),
      ),
      ...authRoutes,
      ...driverRoutes,
      ...techRoutes,
    ],
  );
});
