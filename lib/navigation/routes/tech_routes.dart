import 'package:go_router/go_router.dart';

import '../../features/technician/task_list_screen.dart';
import '../../features/technician/job_card_screen.dart';
import '../../features/technician/job_card_details_screen.dart';
import '../../features/technician/tech_profile_screen.dart';
import '../../features/technician/technician_dashboard_screen.dart';
import '../../features/technician/create_job_card_screen.dart';
import '../../features/technician/tech_earnings_screen.dart';
import '../../features/technician/spare_parts_screen.dart';
import '../../features/technician/tech_qr_scanner_screen.dart';
import '../../features/technician/job_detail_screen.dart';
import '../app_transitions.dart';

/// Technician portal routes.
/// Exported as [techRoutes] and composed into the root GoRouter.
final List<RouteBase> techRoutes = [
  GoRoute(
    path: '/tech-dashboard',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const TechnicianDashboardScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/tech-earnings',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const TechEarningsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/tech-tasks',
    pageBuilder: (context, state) => AppTransitions.scaleIn(
      child: const TaskListScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/tech-create-job',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const CreateJobCardScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/tech-job-card',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const TechnicianJobCardScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/tech-job-card-details',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const JobCardDetailsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/tech-spare-parts',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const SparePartsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/tech-profile',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const TechProfileScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/tech-job-detail',
    pageBuilder: (context, state) {
      final bookingId = state.extra as String? ?? '';
      return AppTransitions.slideUp(
        child: JobDetailScreen(bookingId: bookingId),
        state: state,
      );
    },
  ),
  GoRoute(
    path: '/tech-qr-scanner',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const TechQRScannerScreen(),
      state: state,
    ),
  ),
];
