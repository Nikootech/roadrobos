import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/main_shell.dart';
import '../../features/home/home_screen.dart';
import '../../features/home/bike_service_booking_screen.dart';
import '../../features/home/car_service_booking_screen.dart';
import '../../features/home/ev_bike_service_booking_screen.dart';
import '../../features/home/water_service_booking_screen.dart';
import '../../features/home/bookings_screen.dart';
import '../../features/home/explore_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/home/detail_screen.dart';
import '../../features/home/add_vehicle_screen.dart';
import '../../features/home/select_service_type_screen.dart';
import '../../features/home/schedule_appointment_screen.dart';
import '../../features/home/live_service_status_screen.dart';
import '../../features/home/service_feedback_screen.dart';
import '../../features/rides/book_ride_screen.dart';
import '../../features/rides/ride_options_screen.dart';
import '../../features/rides/live_tracking_screen.dart';
import '../../features/rides/ride_complete_screen.dart';
import '../../features/rides/rate_ride_screen.dart';
import '../../features/rides/live_vehicle_tracking_screen.dart';
import '../../features/rides/location_search_screen.dart';
import '../../features/rides/map_picker_screen.dart';
import '../../features/wallet/wallet_screen.dart';
import '../../features/wallet/wallet_topup_screen.dart';
import '../../features/wallet/wallet_transfer_screen.dart';
import '../../features/wallet/wallet_withdraw_screen.dart';
import '../../features/wallet/fare_breakdown_screen.dart';
import '../../features/wallet/billing_invoice_screen.dart';
import '../../features/wallet/secure_payment_screen.dart';
import '../../features/rentals/rental_explore_screen.dart';
import '../../features/rentals/vehicle_selection_screen.dart';
import '../../features/taxi/taxi_ride_screen.dart';
import '../../features/rentals/vehicle_detail_screen.dart';
import '../../features/rentals/rental_checkout_screen.dart';
import '../../features/rentals/rental_confirmed_screen.dart';
import '../../features/rentals/rental_terms_screen.dart';
import '../../features/rentals/delivery_logistics_screen.dart';
import '../../features/rentals/rental_providers.dart';
import '../../features/profile/ride_history_screen.dart';
import '../../features/profile/referral_screen.dart';
import '../../features/profile/user_loyalty_screen.dart';
import '../../features/profile/account_settings_screen.dart';
import '../../features/profile/service_history_screen.dart';
import '../../features/profile/my_vehicles_screen.dart';
import '../../features/profile/saved_locations_screen.dart';
import '../../features/vehicles/vehicle_list_screen.dart';
import '../../features/vehicles/add_vehicle_screen.dart' as new_vehicles;
import '../../core/repositories/user_vehicle_repository.dart';
import '../../features/profile/notification_center_screen.dart';
import '../../features/profile/notification_settings_screen.dart';
import '../../features/profile/language_screen.dart';
import '../../features/profile/sos_setup_screen.dart';
import '../../features/profile/service_reminders_screen.dart';
import '../../features/support/help_center_screen.dart';
import '../../features/home/emergency_help_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../core/repositories/rental_catalog_repository.dart';
import '../../features/delivery/create_delivery_screen.dart';
import '../../features/delivery/delivery_tracking_screen.dart';
import '../../features/services/service_type_selector.dart';
import '../../features/services/book_service_screen.dart';
import '../../features/home/service_booking_detail_screen.dart';
import '../../core/models/service_booking.dart';
import '../../features/insurance/insurance_selection_screen.dart';
import '../app_transitions.dart';

// Navigator key for shell route — shared with app_router.dart
final shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

/// Customer-facing routes: home shell, service booking, rides, taxi, wallet, rentals, profile.
/// Rental detail now uses Supabase vehicle ID — MockData is not referenced here.
final List<RouteBase> customerRoutes = [
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

  // ── Service screens ──
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
    path: '/select-service-type',
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
    path: '/service-booking-detail',
    pageBuilder: (context, state) {
      final booking = state.extra as ServiceBooking;
      return AppTransitions.slideRight(
        child: ServiceBookingDetailScreen(booking: booking),
        state: state,
      );
    },
  ),
  GoRoute(
    path: '/services',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const ServiceTypeSelectorScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/book_service/:serviceId',
    pageBuilder: (context, state) {
      final serviceId = state.pathParameters['serviceId'] ?? '';
      final extra = state.extra as Map<String, dynamic>?;
      final title = extra?['title'] ?? 'Service';
      final basePrice = extra?['basePrice'] ?? 0.0;
      return AppTransitions.slideUp(
        child: BookServiceScreen(
          serviceId: serviceId,
          title: title,
          basePrice: basePrice,
        ),
        state: state,
      );
    },
  ),

  // ── Ride / Taxi screens ──
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
    path: '/taxi',
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

  // ── Wallet screens ──
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
    pageBuilder: (context, state) {
      final amountStr = state.uri.queryParameters['amount'];
      final amount = amountStr != null ? double.tryParse(amountStr) : null;
      return AppTransitions.slideUp(
        child: WalletTopupScreen(initialAmount: amount),
        state: state,
      );
    },
  ),
  GoRoute(
    path: '/wallet/transfer',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const WalletTransferScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/wallet/withdraw',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const WalletWithdrawScreen(),
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

  // ── Rental screens ──
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
    path: '/insurance',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const InsuranceSelectionScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/insurance-selection',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const InsuranceSelectionScreen(),
      state: state,
    ),
  ),

  /// Primary detail route: uses vehicle ID from Supabase.
  /// Navigation: context.push('/rental-detail/${vehicle.id}')
  /// No MockData lookup — fetches directly from rentalCatalogRepositoryProvider.
  GoRoute(
    path: '/rental-detail/:id',
    pageBuilder: (context, state) {
      final vehicleId = state.pathParameters['id'] ?? '';
      return AppTransitions.slideRight(
        child: Consumer(
          builder: (context, ref, _) {
            // If selectedVehicleProvider is already populated (e.g. user tapped a
            // card that called selectedVehicleProvider.notifier.state = vehicle),
            // use it directly. Otherwise fetch from Supabase by ID.
            final cached = ref.watch(selectedVehicleProvider);
            if (cached != null && cached['id']?.toString() == vehicleId) {
              return const RentalVehicleDetailScreen();
            }
            // Fallback: fetch from repository and populate provider
            return FutureBuilder(
              future: ref
                  .read(rentalCatalogRepositoryProvider)
                  .fetchVehicleById(vehicleId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasData && snapshot.data != null) {
                  // Populate the selectedVehicleProvider so the detail screen works
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(selectedVehicleProvider.notifier).state =
                        snapshot.data!.toMap()..['id'] = vehicleId;
                  });
                  return const RentalVehicleDetailScreen();
                }
                return const Scaffold(
                  body: Center(child: Text('Vehicle not found')),
                );
              },
            );
          },
        ),
        state: state,
      );
    },
  ),

  /// Legacy slug-based route kept for backwards compatibility with any existing
  /// deep-links or push calls that still use the name-slug pattern.
  /// Redirects to the standard /rental-detail screen via selectedVehicleProvider.
  GoRoute(
    path: '/rental-detail',
    pageBuilder: (context, state) => AppTransitions.slideRight(
      child: const RentalVehicleDetailScreen(),
      state: state,
    ),
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

  // ── Delivery module ──
  GoRoute(
    path: '/delivery/create',
    pageBuilder: (context, state) => AppTransitions.slideUp(
      child: const CreateDeliveryScreen(),
      state: state,
    ),
  ),
  GoRoute(
    path: '/delivery/tracking/:orderId',
    pageBuilder: (context, state) {
      final orderId = state.pathParameters['orderId'] ?? '';
      return AppTransitions.slideUp(
        child: DeliveryTrackingScreen(orderId: orderId),
        state: state,
      );
    },
  ),

  // ── Profile screens ──
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
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      final bookingId = extra['bookingId'] as String? ?? '';
      final receiverId = extra['receiverId'] as String? ?? '';
      final receiverName = extra['receiverName'] as String? ?? 'User';

      return AppTransitions.slideUp(
        child: ChatScreen(
          bookingId: bookingId,
          receiverId: receiverId,
          receiverName: receiverName,
        ),
        state: state,
      );
    },
  ),

  // ── ISSUE-11 FIX: Parametric chat route for notification deep-links ──
  // notification_service.dart calls context.push('/chat/$roomId').
  // Without this route that resolves to a 404.  bookingId == roomId here.
  GoRoute(
    path: '/chat/:roomId',
    pageBuilder: (context, state) {
      final roomId = state.pathParameters['roomId'] ?? '';
      final extra = state.extra as Map<String, dynamic>? ?? {};
      final receiverId = extra['receiverId'] as String? ?? '';
      final receiverName = extra['receiverName'] as String? ?? 'Support';

      return AppTransitions.slideUp(
        child: ChatScreen(
          bookingId: roomId,
          receiverId: receiverId,
          receiverName: receiverName,
        ),
        state: state,
      );
    },
  ),
];
