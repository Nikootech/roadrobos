import 'package:go_router/go_router.dart';

import '../../features/admin/audit_log_screen.dart';

import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/revenue_analytics_screen.dart';
import '../../features/admin/kyc_approval_screen.dart';
import '../../features/admin/revenue_referral_screen.dart';
import '../../features/admin/active_rides_screen.dart';
import '../../features/admin/admin_management_screen.dart';
import '../../features/admin/service_feedback_analytics_screen.dart';
import '../../features/admin/manage_offers_screen.dart';
import '../../features/admin/customer_database_screen.dart';
import '../../features/admin/driver_database_screen.dart';
import '../../features/admin/technician_database_screen.dart';
import '../../features/admin/export_reports_screen.dart';
import '../../features/admin/manage_reminders_screen.dart';
import '../../features/admin/approval_center_screen.dart';
import '../../features/admin/manpower_supply_screen.dart';
import '../../features/admin/approvals/approvals_list_screen.dart';
import '../../features/admin/approvals/approval_detail_screen.dart';
import '../../core/models/approval.dart';
import '../app_transitions.dart';

/// Admin console routes.
/// Exported as [adminRoutes] and composed into the root GoRouter.
final List<RouteBase> adminRoutes = [
  GoRoute(
    path: '/admin-home',
    pageBuilder: (context, state) => AppTransitions.scaleIn(
      child: const AdminDashboardScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-revenue',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const RevenueAnalyticsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-kyc',
    pageBuilder: (context, state) {
      final request = state.extra as ApprovalRequest?;
      if (request == null) {
        return AppTransitions.slideRight(
          child: const ApprovalCenterScreen(),
          state: state,
        );
      }
      return AppTransitions.slideRight(
        child: KycApprovalScreen(request: request),
        state: state,
      );
    },
  ),
  GoRoute(
    path: '/admin-approvals',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ApprovalsListScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-approval-detail',
    pageBuilder: (context, state) {
      final request = state.extra as ApprovalRequest;
      return AppTransitions.slideRight(
        child: ApprovalDetailScreen(request: request),
        state: state,
      );
    },
  ),
  GoRoute(
    path: '/admin-revenue-referral',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const RevenueReferralScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-active-rides',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ActiveRidesScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-management',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const AdminManagementScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-feedback-analytics',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ServiceFeedbackAnalyticsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-manage-offers',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ManageOffersScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-customer-database',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const CustomerDatabaseScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-driver-database',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const DriverDatabaseScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-technician-database',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const TechnicianDatabaseScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-export-reports',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ExportReportsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-manage-reminders',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ManageRemindersScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin-manpower',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ManpowerSupplyScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/admin/audit-logs',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const AuditLogScreen(),
      state: state,
    ),
  ),
];
