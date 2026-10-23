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
import '../../features/auth/kyc/kyc_upload_screen.dart';
import '../../features/auth/kyc/kyc_status_screen.dart';
import '../app_transitions.dart';
import '../../features/settings/unified_settings_screen.dart';
import '../../features/profile/notification_settings_screen.dart';
import '../../features/profile/account_settings_screen.dart';
import '../../features/support/help_center_screen.dart';
import '../../features/legal/privacy_policy_screen.dart';
import '../../features/legal/terms_of_service_screen.dart';
import '../../features/profile/language_screen.dart';
import '../../features/profile/sos_setup_screen.dart';
import '../../features/profile/notification_center_screen.dart';
import '../../features/profile/saved_locations_screen.dart';
import '../../features/profile/my_vehicles_screen.dart';
import '../../features/home/add_vehicle_screen.dart';
import '../../features/vehicles/vehicle_list_screen.dart';
import '../../features/vehicles/add_vehicle_screen.dart' as new_vehicles;
import '../../core/repositories/user_vehicle_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../shared/widgets/chat/chat_screen.dart' as support_chat;
import '../../features/partner/demand_map/demand_heatmap_screen.dart';
import '../../features/profile/referral_screen.dart';
import '../../features/profile/ride_history_screen.dart';
import '../../features/profile/service_history_screen.dart';
import '../../features/profile/service_reminders_screen.dart';
import '../../features/profile/user_loyalty_screen.dart';

import '../../features/driver/driver_main_shell.dart';

/// Driver portal routes.
/// Exported as [driverRoutes] and composed into the root GoRouter.
final List<RouteBase> driverRoutes = [
  ShellRoute(
    builder: (context, state, child) => DriverMainShell(child: child),
    routes: [
      GoRoute(
        path: '/driver-home',
        pageBuilder: (context, state) => AppTransitions.fade(
          child: const DriverHomeScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/driver-earnings',
        pageBuilder: (context, state) => AppTransitions.fade(
          child: const EarningsScreen(),
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
        path: '/driver-profile',
        pageBuilder: (context, state) => AppTransitions.fade(
          child: const DriverProfileScreen(),
          state: state,
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/driver-assigned',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const DriverAssignedScreen(),
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
    path: '/driver/documents',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const DocumentsUploadScreen(),
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
    path: '/driver/kyc-upload',
    pageBuilder: (context, state) {
      final extra = state.extra as String?;
      return AppTransitions.slideUp(
        child: KycUploadScreen(initialStep: extra),
        state: state,
      );
    },
  ),
  GoRoute(
    path: '/driver/kyc-status',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const KycStatusScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/settings',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const UnifiedSettingsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/notification-settings',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const NotificationSettingsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/account-settings',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const AccountSettingsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/help-center',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const HelpCenterScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/privacy-policy',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const PrivacyPolicyScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/terms-of-service',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const TermsOfServiceScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/language',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const LanguageScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/sos-setup',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const SosSetupScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/notifications',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const NotificationCenterScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/saved-locations',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const SavedLocationsScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/my-vehicles',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const MyVehiclesScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/add-vehicle',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const AddVehicleScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/vehicles',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const VehicleListScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/vehicles/add',
    pageBuilder: (context, state) {
      final vehicle = state.extra as UserVehicle?;
      return AppTransitions.slideUp(
        child: new_vehicles.AddVehicleScreen(vehicle: vehicle),
        state: state,
      );
    },
  ),
  GoRoute(
    path: '/chat',
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      final bookingId = extra['bookingId'] as String? ?? '';
      final receiverId = extra['receiverId'] as String? ?? '';
      final receiverName = extra['receiverName'] as String? ?? '';

      final isUuid = RegExp(
              r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')
          .hasMatch(bookingId);

      if (bookingId.isEmpty || !isUuid) {
        final currentUserId =
            Supabase.instance.client.auth.currentUser?.id ?? 'demo';
        final roomId =
            bookingId.isNotEmpty ? bookingId : '${currentUserId}_support';
        return AppTransitions.slideUp(
          child: support_chat.ChatScreen(
            roomId: roomId,
            otherPartyName:
                receiverName.isNotEmpty ? receiverName : 'Support Agent',
          ),
          state: state,
        );
      }

      return AppTransitions.slideUp(
        child: ChatScreen(
          bookingId: bookingId,
          receiverId: receiverId,
          receiverName: receiverName.isNotEmpty ? receiverName : 'User',
        ),
        state: state,
      );
    },
  ),
  GoRoute(
    path: '/demand-map',
    pageBuilder: (context, state) => AppTransitions.fade(
      child: const DemandHeatmapScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/driver/rides',
    redirect: (context, state) => '/driver-rides',
  ),
  GoRoute(
    path: '/driver/earnings',
    redirect: (context, state) => '/driver-earnings',
  ),
  GoRoute(
    path: '/driver/profile',
    redirect: (context, state) => '/driver-profile',
  ),
  GoRoute(
    path: '/referral',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ReferralScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/ride-history',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const RideHistoryScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/service-history',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ServiceHistoryScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/service-reminders',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ServiceRemindersScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/loyalty',
    pageBuilder: (context, state) => AppTransitions.scaleIn(
      child: const UserLoyaltyScreen(),
      state: state,
    ),
  ),
];
