import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/rentals/rental_providers.dart';
import '../core/services/auth_service.dart';
import '../core/data/mock_data.dart';
import '../features/profile/user_provider.dart';
import '../core/models/user_role.dart';

// Screens — Splash & Onboarding
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';

import '../features/home/main_shell.dart';
import '../features/home/home_screen.dart';
import '../features/home/bike_service_booking_screen.dart';
import '../features/home/car_service_booking_screen.dart';
import '../features/home/ev_bike_service_booking_screen.dart';
import '../features/home/water_service_booking_screen.dart';
import '../features/home/bookings_screen.dart';
import '../features/home/explore_screen.dart';
import '../features/profile/profile_screen.dart';

// Screens — Customer Sub-screens
import '../features/home/detail_screen.dart';
import '../features/home/add_vehicle_screen.dart';
import '../features/home/select_service_type_screen.dart';
import '../features/home/schedule_appointment_screen.dart';
import '../features/home/live_service_status_screen.dart';
import '../features/home/service_feedback_screen.dart';
import '../features/rides/book_ride_screen.dart';
import '../features/rides/ride_options_screen.dart';
import '../features/rides/live_tracking_screen.dart';
import '../features/rides/ride_complete_screen.dart';
import '../features/rides/rate_ride_screen.dart';
import '../features/rides/live_vehicle_tracking_screen.dart';
import '../features/rides/location_search_screen.dart';
import '../features/rides/map_picker_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/wallet/wallet_topup_screen.dart';
import '../features/wallet/fare_breakdown_screen.dart';
import '../features/wallet/billing_invoice_screen.dart';
import '../features/wallet/secure_payment_screen.dart';
import '../features/rentals/rental_explore_screen.dart';
import '../features/rentals/vehicle_selection_screen.dart';
import '../features/taxi/taxi_ride_screen.dart';
import '../features/rentals/vehicle_detail_screen.dart';
import '../features/rentals/rental_checkout_screen.dart';
import '../features/rentals/rental_confirmed_screen.dart';
import '../features/rentals/rental_terms_screen.dart';
import '../features/rentals/delivery_logistics_screen.dart';
import '../features/profile/ride_history_screen.dart';
import '../features/profile/referral_screen.dart';
import '../features/profile/user_loyalty_screen.dart';
import '../features/profile/account_settings_screen.dart';
import '../features/profile/service_history_screen.dart';
import '../features/profile/my_vehicles_screen.dart';
import '../features/profile/saved_locations_screen.dart';
import '../features/profile/notification_center_screen.dart';
import '../features/profile/notification_settings_screen.dart';
import '../features/profile/language_screen.dart';
import '../features/profile/sos_setup_screen.dart';
import '../features/profile/service_reminders_screen.dart';
import '../features/support/help_center_screen.dart';
import '../features/home/emergency_help_screen.dart';

// Screens — Driver & Technician
import '../features/driver/driver_home_screen.dart';
import '../features/driver/driver_rides_screen.dart';
import '../features/driver/driver_assigned_screen.dart';
import '../features/driver/earnings_screen.dart';
import '../features/technician/tech_earnings_screen.dart';
import '../features/driver/documents_upload_screen.dart';
import '../features/driver/verification_pending_screen.dart';
import '../features/driver/driver_verification_success_screen.dart';
import '../features/driver/driver_ride_request_screen.dart';
import '../features/driver/driver_bank_withdrawal_screen.dart';
import '../features/driver/driver_profile_screen.dart';
import '../features/technician/task_list_screen.dart';
import '../features/technician/job_card_screen.dart';
import '../features/technician/job_card_details_screen.dart';
import '../features/technician/tech_profile_screen.dart';
import '../features/technician/technician_dashboard_screen.dart';
import '../features/technician/create_job_card_screen.dart';
import '../features/shared/chat/in_app_chat_screen.dart';
import '../features/technician/spare_parts_screen.dart';

// Screens — Admin
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/revenue_analytics_screen.dart';
import '../features/admin/kyc_approval_screen.dart';
import '../features/admin/revenue_referral_screen.dart';
import '../features/admin/active_rides_screen.dart';
import '../features/admin/admin_management_screen.dart';
import '../features/admin/service_feedback_analytics_screen.dart';
import '../features/admin/manage_offers_screen.dart';
import '../features/admin/customer_database_screen.dart';
import '../features/admin/driver_database_screen.dart';
import '../features/admin/technician_database_screen.dart';
import '../features/admin/export_reports_screen.dart';
import '../features/admin/manage_reminders_screen.dart';
import '../features/admin/manpower_supply_screen.dart';

// Transitions
import 'app_transitions.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(userProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    
    // Fallback for invalid routes
    errorBuilder: (context, state) => const HomeScreen(),

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
      final hasDemoIdUser = userState.user != null && userState.user!.id.startsWith('demo_');
      final isLoggedIn = hasFirebaseUser || hasDemoUser || hasDemoIdUser;
      final user = userState.user;
      final location = state.matchedLocation;
      
      debugPrint('Router: location=$location, hasFirebaseUser=$hasFirebaseUser, hasDemoUser=$hasDemoUser, hasDemoIdUser=$hasDemoIdUser, isLoggedIn=$isLoggedIn, user=${user?.name}, isDemo=${userState.isDemo}');
      
      final publicPaths = ['/splash', '/onboarding', '/auth/login', '/auth/register'];
      final isPublicPath = publicPaths.contains(location);
      
      if (!isLoggedIn && !isPublicPath) {
        debugPrint('Router: Not logged in, redirecting to /auth/login');
        return '/auth/login';
      }
      
      if (isLoggedIn && isPublicPath) {
        // If profile isn't loaded yet, wait on login screen
        if (user == null) return null;

        // Redirect based on role
        switch (user.role) {
          case UserRole.admin:
          case UserRole.superAdmin:
            return '/admin-home';
          case UserRole.driver:
            return '/driver-home';
          case UserRole.technician:
            return '/tech-dashboard';
          case UserRole.customer:
          default:
            return '/main/home';
        }
      }
      
      // -- Simple Role Guards --
      if (isLoggedIn && user != null) {
        if (location.startsWith('/admin-') && 
            user.role != UserRole.admin && 
            user.role != UserRole.superAdmin) {
          return '/main/home'; // Unauthorized
        }
        if (location.startsWith('/tech-') && user.role != UserRole.technician) {
          return '/main/home';
        }
      }
      
      return null;
    },

    routes: [
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
          duration: const Duration(milliseconds: 400),
        ),
      ),

      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/main/home',
            pageBuilder: (context, state) => AppTransitions.fade(
              child: const HomeScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/main/bookings',
            pageBuilder: (context, state) => AppTransitions.fade(
              child: const BookingsScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/main/explore',
            pageBuilder: (context, state) => AppTransitions.fade(
              child: const ExploreScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: '/main/profile',
            pageBuilder: (context, state) => AppTransitions.fade(
              child: const ProfileScreen(),
              state: state,
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/detail',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const DetailScreen(),
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
        path: '/bike-service-booking',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const BikeServiceBookingScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/car-service-booking',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const CarServiceBookingScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/ev-bike-service-booking',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const EVBikeServiceBookingScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/water-service-booking',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const WaterServiceBookingScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/live-service-status',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const LiveServiceStatusScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/select-service',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const SelectServiceTypeScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/schedule-appointment',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const ScheduleAppointmentScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/service-feedback',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const ServiceFeedbackScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/book-ride',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const BookRideScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/rate-ride',
        pageBuilder: (context, state) => AppTransitions.fade(
          child: const RateRideScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/live-vehicle-tracking',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const LiveVehicleTrackingScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/live-tracking',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const LiveTrackingScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/emergency-help',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const EmergencyHelpScreen(),
          state: state,
        ),
      ),

      GoRoute(
        path: '/taxi/home',
        pageBuilder: (context, state) => AppTransitions.fade(
          child: const TaxiRideScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/taxi/search-location',
        pageBuilder: (context, state) {
           final extra = state.extra as Map<String, dynamic>?;
           final focusPickup = extra?['focusPickup'] ?? false;
           return AppTransitions.slideUp(
             child: LocationSearchScreen(focusPickup: focusPickup),
             state: state,
           );
        },
      ),
      GoRoute(
        path: '/taxi/map-picker',
        builder: (context, state) => const MapPickerScreen(),
      ),
      GoRoute(
        path: '/taxi/ride-options',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const RideOptionsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/taxi/tracking',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const LiveTrackingScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/taxi/complete',
        pageBuilder: (context, state) => AppTransitions.scaleIn(
          child: const RideCompleteScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/taxi/feedback',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const RateRideScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/wallet/secure-payment',
        pageBuilder: (context, state) => AppTransitions.fade(
          child: const SecurePaymentScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/wallet/billing-invoice',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const BillingInvoiceScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/wallet/topup',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const WalletTopupScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/wallet/fare-breakdown',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const FareBreakdownScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/wallet',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const WalletScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/rentals',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const RentalExploreScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/rentals-selection',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const VehicleSelectionScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/rental-detail/:slug',
        pageBuilder: (context, state) {
          final slug = state.pathParameters['slug']?.toLowerCase();
          final vehicle = MockData.rentalVehicles.firstWhere(
            (v) => v['name'].toString().toLowerCase().replaceAll(' ', '-') == slug,
            orElse: () => MockData.rentalVehicles.first,
          );
          
          return AppTransitions.slideRight(
            child: ProviderScope(
              overrides: [
                selectedVehicleProvider.overrideWith((ref) => vehicle),
              ],
              child: const RentalVehicleDetailScreen(),
            ),
            state: state,
          );
        },
      ),
      GoRoute(
        path: '/rental-detail',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const RentalVehicleDetailScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/product/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']?.toLowerCase();
          final vehicle = MockData.rentalVehicles.firstWhere(
            (v) => v['name'].toString().toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').replaceAll(RegExp(r'\s+'), '-') == slug,
            orElse: () => {},
          );

          if (vehicle.isNotEmpty) {
            return ProviderScope(
              overrides: [
                selectedVehicleProvider.overrideWith((ref) => vehicle),
              ],
              child: const RentalVehicleDetailScreen(),
            );
          }
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/rental-checkout',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const RentalCheckoutScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/rental-confirmed',
        pageBuilder: (context, state) => AppTransitions.scaleIn(
          child: const RentalConfirmedScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/rental-terms',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const RentalTermsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/delivery-logistics',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const DeliveryLogisticsScreen(),
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
        path: '/my-vehicles',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const MyVehiclesScreen(),
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
        path: '/account-settings',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const AccountSettingsScreen(),
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
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const NotificationCenterScreen(),
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
        path: '/language',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const LanguageScreen(),
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
        path: '/sos-setup',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const SosSetupScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/service-reminders',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const ServiceRemindersScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/referral',
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const ReferralScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/chat',
        pageBuilder: (context, state) => AppTransitions.slideUp(
          child: const InAppChatScreen(),
          state: state,
        ),
      ),

      // ═══════════════════════════════════════════
      // GROUP E — Driver & Technician
      // ═══════════════════════════════════════════
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

      // ═══════════════════════════════════════════
      // GROUP F — Admin Console
      // ═══════════════════════════════════════════
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
        pageBuilder: (context, state) => AppTransitions.slideRight(
          child: const KycApprovalScreen(),
          state: state,
        ),
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
    ],
  );
});
