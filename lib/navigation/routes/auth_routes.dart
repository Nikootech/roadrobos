import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/partner_kyc_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/auth/pending_approval_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../app_transitions.dart';

/// Auth & onboarding routes.
/// Exported as [authRoutes] and composed into the root GoRouter.
final List<RouteBase> authRoutes = [
  GoRoute(
    path: '/auth/pending-approval',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const PendingApprovalScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/auth/role-selection',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const RoleSelectionScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/splash',
    pageBuilder: (context, state) => AppTransitions.none(
      child: const SplashScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/onboarding',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const OnboardingScreen(),
      state: state,
      duration: const Duration(milliseconds: 800),
    ),
  ),
  GoRoute(
    path: '/auth/login',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const LoginScreen(),
      state: state,
      duration: const Duration(milliseconds: 500),
    ),
  ),
  GoRoute(
    path: '/auth/register',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const RegisterScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/auth/partner-kyc',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const PartnerKycScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/login-callback',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const SplashScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/reset-password',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const ResetPasswordScreen(),
      state: state,
    ),
  ),
];
