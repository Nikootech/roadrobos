import 'package:go_router/go_router.dart';

import '../../features/driver/driver_home_screen.dart';
import '../../features/driver/driver_rides_screen.dart';
import '../../features/driver/driver_assigned_screen.dart';
import '../../features/driver/earnings_screen.dart';
import '../../features/driver/documents_upload_screen.dart';
import '../../features/driver/verification_pending_screen.dart';
import '../../features/driver/driver_verification_success_screen.dart';
import '../../features/driver/driver_ride_request_screen.dart';
import '../../features/driver/driver_bank_withdrawal_screen.dart';
import '../../features/driver/driver_profile_screen.dart';
import '../app_transitions.dart';

/// Driver portal routes.
/// Exported as [driverRoutes] and composed into the root GoRouter.
final List<RouteBase> driverRoutes = [
  GoRoute(
    path: '/driver-home',
    pageBuilder: (context, state) => AppTransitions.scaleIn(
      child: const DriverHomeScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver-rides',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const DriverRidesScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver-assigned',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const DriverAssignedScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver-license-upload',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const DocumentsUploadScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver-verification-pending',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const VerificationPendingScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver-verification-success',
    pageBuilder: (context, state) => AppTransitions.scaleIn(
      child: const DriverVerificationSuccessScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver-ride-request',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const DriverRideRequestScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver-bank-withdrawal',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const DriverBankWithdrawalScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver-earnings',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const EarningsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver/documents',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const DocumentsUploadScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver-profile',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const DriverProfileScreen(),
      state: state,
    ),
  ),
];
