import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/profile/user_provider.dart';
import '../core/models/ride_booking.dart';
import '../core/repositories/ride_booking_repository.dart';
import '../core/repositories/driver_repository.dart';
import '../core/services/user_tracking_service.dart';
import '../core/services/osm_maps_service.dart';
import '../core/services/payment_service.dart';

// Sentinel object used by TaxiState.copyWith() to distinguish "clear this
// nullable field" from "leave it unchanged". Pass _kClear for any nullable
// parameter you want to set to null.
const Object _kClear = Object();

enum RideStatus {
  idle,
  selectingPickup,
  selectingDrop,
  vehicleSelection,
  booked,
  tracking,
  atPickup,
  headingToDropoff,
  completed,
  noDriversFound, // All drivers offline — user can schedule or cancel
}

class NearbyVehicle {
  final LatLng position;
  final String type; // 'bike', 'auto', 'car'

  NearbyVehicle({required this.position, required this.type});
}

class RideOption {
  final String id;
  final String title;
  final String subtitle;
  final double price;
  final String? tag;
  final IconData icon;
  final String? assetPath;

  RideOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    this.tag,
    required this.icon,
    this.assetPath,
  });
}

class TaxiState {
  final RideStatus status;
  final LatLng? pickupLocation;
  final LatLng? dropoffLocation;
  final LatLng? roadroboLocation;
  final String? pickupAddress;
  final String? dropoffAddress;
  final String? roadroboName;
  final String? driverId;
  final String? rideId;
  final String? eta;
  final double distance;
  final String? otp;
  final bool isOtpVerified;
  final List<NearbyVehicle> nearbyVehicles;
  final List<RideOption> rideOptions;
  final RideOption? selectedOption;
  final List<Map<String, dynamic>> mockLocations;
  final String paymentMethod;
  final double discountAmount;
  final String? appliedPromoCode;
  final double tipAmount;
  final DateTime? scheduledFor;
  final String? razorpayPaymentId; // stored after online payment
  final bool refundInitiated;       // true after auto-refund triggered
  final bool isLoadingLocation;     // true while GPS is being fetched
  final bool isLoadingOptions;      // true while ride options are loading

  TaxiState({
    this.status = RideStatus.idle,
    this.pickupLocation,
    this.dropoffLocation,
    this.roadroboLocation,
    this.pickupAddress,
    this.dropoffAddress,
    this.roadroboName,
    this.driverId,
    this.eta,
    this.distance = 0.0,
    this.otp,
    this.isOtpVerified = false,
    this.nearbyVehicles = const [],
    this.rideOptions = const [],
    this.selectedOption,
    this.mockLocations = const [],
    this.rideId,
    this.paymentMethod = 'Cash',
    this.discountAmount = 0.0,
    this.appliedPromoCode,
    this.tipAmount = 0.0,
    this.scheduledFor,
    this.razorpayPaymentId,
    this.refundInitiated = false,
    this.isLoadingLocation = false,
    this.isLoadingOptions = false,
  });

  // Use [_kClear] as the value for a nullable parameter to explicitly null it.
  // Example: state.copyWith(dropoffAddress: _kClear)
  TaxiState copyWith({
    RideStatus? status,
    Object? pickupLocation = _kClear,
    Object? dropoffLocation = _kClear,
    Object? roadroboLocation = _kClear,
    Object? pickupAddress = _kClear,
    Object? dropoffAddress = _kClear,
    Object? roadroboName = _kClear,
    Object? driverId = _kClear,
    Object? eta = _kClear,
    double? distance,
    Object? otp = _kClear,
    bool? isOtpVerified,
    List<NearbyVehicle>? nearbyVehicles,
    List<RideOption>? rideOptions,
    Object? selectedOption = _kClear,
    List<Map<String, dynamic>>? mockLocations,
    Object? rideId = _kClear,
    String? paymentMethod,
    double? discountAmount,
    Object? appliedPromoCode = _kClear,
    double? tipAmount,
    Object? scheduledFor = _kClear,
    Object? razorpayPaymentId = _kClear,
    bool? refundInitiated,
    bool? isLoadingLocation,
    bool? isLoadingOptions,
  }) {
    return TaxiState(
      status: status ?? this.status,
      pickupLocation: identical(pickupLocation, _kClear)
          ? this.pickupLocation
          : pickupLocation as LatLng?,
      dropoffLocation: identical(dropoffLocation, _kClear)
          ? this.dropoffLocation
          : dropoffLocation as LatLng?,
      roadroboLocation: identical(roadroboLocation, _kClear)
          ? this.roadroboLocation
          : roadroboLocation as LatLng?,
      pickupAddress: identical(pickupAddress, _kClear)
          ? this.pickupAddress
          : pickupAddress as String?,
      dropoffAddress: identical(dropoffAddress, _kClear)
          ? this.dropoffAddress
          : dropoffAddress as String?,
      roadroboName: identical(roadroboName, _kClear)
          ? this.roadroboName
          : roadroboName as String?,
      driverId: identical(driverId, _kClear) ? this.driverId : driverId as String?,
      eta: identical(eta, _kClear) ? this.eta : eta as String?,
      distance: distance ?? this.distance,
      otp: identical(otp, _kClear) ? this.otp : otp as String?,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      nearbyVehicles: nearbyVehicles ?? this.nearbyVehicles,
      rideOptions: rideOptions ?? this.rideOptions,
      selectedOption: identical(selectedOption, _kClear)
          ? this.selectedOption
          : selectedOption as RideOption?,
      mockLocations: mockLocations ?? this.mockLocations,
      rideId: identical(rideId, _kClear) ? this.rideId : rideId as String?,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      discountAmount: discountAmount ?? this.discountAmount,
      appliedPromoCode: identical(appliedPromoCode, _kClear)
          ? this.appliedPromoCode
          : appliedPromoCode as String?,
      tipAmount: tipAmount ?? this.tipAmount,
      scheduledFor: identical(scheduledFor, _kClear)
          ? this.scheduledFor
          : scheduledFor as DateTime?,
      razorpayPaymentId: identical(razorpayPaymentId, _kClear)
          ? this.razorpayPaymentId
          : razorpayPaymentId as String?,
      refundInitiated: refundInitiated ?? this.refundInitiated,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isLoadingOptions: isLoadingOptions ?? this.isLoadingOptions,
    );
  }

  /// Clears all trip-specific fields while keeping identity fields.
  TaxiState clearTrip() {
    return copyWith(
      dropoffLocation: null,
      dropoffAddress: null,
      roadroboLocation: null,
      roadroboName: null,
      driverId: null,
      rideId: null,
      eta: null,
      otp: null,
      isOtpVerified: false,
      distance: 0.0,
      selectedOption: null,
      razorpayPaymentId: null,
      refundInitiated: false,
      scheduledFor: null,
      appliedPromoCode: null,
      discountAmount: 0.0,
      tipAmount: 0.0,
      status: RideStatus.idle,
    );
  }
}

class TaxiNotifier extends StateNotifier<TaxiState> {
  final Ref ref;
  TaxiNotifier(this.ref) : super(TaxiState());

  StreamSubscription? _driverLocationSubscription;
  StreamSubscription? _rideSubscription;
  Timer? _searchTimeoutTimer;
  Timer? _mockMovementTimer; // tracks Timer.periodic for simulated driver movement
  Timer? _distanceDebounce;  // debounce for _calculateDistance()
  final _trackingService = UserTrackingService();
  // Single OSMMapsService instance — avoid creating per-call
  final _osmService = OSMMapsService();

  Future<void> initializeLocation() async {
    // Show spinner while fetching GPS
    state = state.copyWith(isLoadingLocation: true);
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setFallbackLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setFallbackLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setFallbackLocation();
        return;
      }

      final location = await _trackingService.getCurrentLocation() ??
          const LatLng(12.9716, 77.5946);

      // Use the singleton _osmService — no new instance per call
      final address = await _osmService.getAddressFromCoords(location);

      if (!mounted) return;
      state = state.copyWith(
        isLoadingLocation: false,
        pickupLocation: location,
        pickupAddress: address ?? 'Current Location',
        mockLocations: _defaultSuggestions,
      );
      _generateRideOptions();
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing location: $e');
      _setFallbackLocation();
    }
  }

  // Default location suggestions shown before real history is loaded
  static const List<Map<String, dynamic>> _defaultSuggestions = [
    {
      'name': 'MG Road',
      'address': 'MG Road, Bengaluru',
      'distance': '2.4 km',
      'lat': 12.9716,
      'lng': 77.5946,
    },
    {
      'name': 'Indiranagar',
      'address': 'Indiranagar, Bengaluru',
      'distance': '4.1 km',
      'lat': 12.9719,
      'lng': 77.6412,
    },
    {
      'name': 'Koramangala',
      'address': 'Koramangala, Bengaluru',
      'distance': '5.8 km',
      'lat': 12.9352,
      'lng': 77.6245,
    },
  ];

  void _setFallbackLocation() {
    // Default to Bengaluru center if location fails
    const location = LatLng(12.9716, 77.5946);
    state = state.copyWith(
      isLoadingLocation: false,
      pickupLocation: location,
      pickupAddress: 'Bengaluru, Karnataka',
      mockLocations: _defaultSuggestions,
    );
    _generateRideOptions();
  }

  void setPickup(LatLng location, String address) {
    state = state.copyWith(
      pickupLocation: location,
      pickupAddress: address,
      status: state.dropoffLocation == null
          ? RideStatus.selectingDrop
          : RideStatus.vehicleSelection,
    );
    _calculateDistance();
    // _generateNearbyVehicles(location); // Removed as requested
  }

  void setDropoff(LatLng location, String address) {
    state = state.copyWith(
      dropoffLocation: location,
      dropoffAddress: address,
      status: RideStatus.vehicleSelection,
    );
    _calculateDistance();
  }

  void _calculateDistance() {
    // Debounce: cancel any pending calculation before scheduling a new one.
    // This prevents rapid-fire API calls if pickup/dropoff are set quickly.
    _distanceDebounce?.cancel();
    _distanceDebounce = Timer(const Duration(milliseconds: 400), () async {
      if (state.pickupLocation == null || state.dropoffLocation == null) return;
      if (!mounted) return;
      state = state.copyWith(isLoadingOptions: true);
      try {
        final route = await _osmService.getRoute(
            state.pickupLocation!, state.dropoffLocation!);
        final distanceKm = _osmService.calculateDistanceInKm(route);
        if (!mounted) return;
        state = state.copyWith(distance: distanceKm, isLoadingOptions: false);
        _generateRideOptions(distanceKm);
      } catch (e) {
        if (kDebugMode) debugPrint('Distance calc error: $e');
        if (mounted) state = state.copyWith(isLoadingOptions: false);
      }
    });
  }

  void updateStatus(RideStatus status) {
    state = state.copyWith(status: status);
  }

  void acceptRideRequest(LatLng pickup, LatLng dropoff) {
    // For driver use - rely on live location updates
    state = state.copyWith(
      status: RideStatus.tracking, // Heading to pickup
      pickupLocation: pickup,
      dropoffLocation: dropoff,
      roadroboLocation:
          const LatLng(12.9716, 77.5946), // Driver starting position
      otp: (1000 + Random().nextInt(9000)).toString(),
      isOtpVerified: false,
    );
  }

  void arriveAtPickup() {
    state = state.copyWith(status: RideStatus.atPickup, eta: 'Arrived');
  }

  bool verifyOtp(String enteredOtp) {
    if (enteredOtp == state.otp) {
      state = state.copyWith(isOtpVerified: true);
      if (state.driverId != null && state.driverId!.startsWith('mock_')) {
        startTrip();
      }
      return true;
    }
    return false;
  }

  void startTrip() {
    if (state.isOtpVerified) {
      state = state.copyWith(status: RideStatus.headingToDropoff);

      if (state.driverId != null && state.driverId!.startsWith('mock_')) {
        // Simulate movement to destination — tracked so it can be cancelled
        final startPos = state.pickupLocation!;
        int steps = 0;
        const totalSteps = 10;
        _mockMovementTimer?.cancel();
        _mockMovementTimer =
            Timer.periodic(const Duration(seconds: 2), (timer) {
          if (!mounted || state.status != RideStatus.headingToDropoff) {
            timer.cancel();
            return;
          }

          steps++;
          final double fraction = steps / totalSteps;
          final lat = startPos.latitude +
              (state.dropoffLocation!.latitude - startPos.latitude) * fraction;
          final lng = startPos.longitude +
              (state.dropoffLocation!.longitude - startPos.longitude) * fraction;

          final currentPos = LatLng(lat, lng);
          const distanceCalc = Distance();
          final double meters = distanceCalc.as(
              LengthUnit.Meter, currentPos, state.dropoffLocation!);
          final double distanceKm = meters / 1000.0;
          final int etaMins = (meters / 333).ceil().clamp(1, 120);

          state = state.copyWith(
            roadroboLocation: currentPos,
            eta: '${distanceKm.toStringAsFixed(1)} km • $etaMins mins',
          );

          if (steps >= totalSteps) {
            timer.cancel();
            completeRide();
          }
        });
      }
    }
  }

  Future<bool> bookRide() async {
    state = state.copyWith(status: RideStatus.booked);

    try {
      final user = ref.read(userProvider);

      // Check for available drivers based on selected option
      final selectedVehicle = state.selectedOption?.id ?? 'auto';
      final onlineDrivers = await ref
          .read(driverRepositoryProvider)
          .getOnlineDrivers(selectedVehicle);

      // Filter by radius (5 km = 5000 meters) and sort closest first
      const double maxRadiusMeters = 5000;
      const distanceCalc = Distance();

      final nearbyDrivers = onlineDrivers.where((driver) {
        if (driver.currentPosition == null) return false;
        final double distance = distanceCalc.as(
          LengthUnit.Meter,
          state.pickupLocation!,
          driver.currentPosition!,
        );
        return distance <= maxRadiusMeters;
      }).toList();

      final random = Random();
      final generatedOtp =
          (1000 + random.nextInt(9000)).toString(); // 4 digit OTP

      final isDemoUser = user.user?.id == null || user.user!.id == 'demo';
      final custId = isDemoUser ? '00000000-0000-0000-0000-000000000000' : user.user!.id;

      final booking = RideBooking(
        id: '',
        customerId: custId,
        pickupAddress: state.pickupAddress ?? 'Origin',
        destinationAddress: state.dropoffAddress ?? 'Destination',
        pickupLat: state.pickupLocation!.latitude,
        pickupLng: state.pickupLocation!.longitude,
        destLat: state.dropoffLocation!.latitude,
        destLng: state.dropoffLocation!.longitude,
        fare: state.selectedOption?.price ?? 0.0,
        otp: generatedOtp,
        createdAt: DateTime.now(),
        scheduledFor: state.scheduledFor,
        paymentMethod: state.paymentMethod, // pass selected method
      );

      // 1. Complete payment (will trigger Razorpay if Online, or complete directly if Cash)
      String paymentId = 'CASH_PAYMENT';
      if (state.paymentMethod == 'Online') {
        try {
          final paymentService = ref.read(paymentServiceProvider.notifier);
          paymentId = await paymentService.startPayment(PaymentDetails(
            bookingId: '00000000-0000-0000-0000-000000000000', // Typically generated before payment
            bookingType: BookingType.ride,
            totalCost: booking.fare,
            userId: custId,
            description: 'Taxi Ride - ${state.selectedOption?.title ?? 'Standard'}',
            contact: user.user?.phone ?? '9999999999',
            email: user.user?.email ?? 'test@example.com',
          ));
        } catch (e) {
          debugPrint('Razorpay payment failed or was cancelled: $e');
          state = state.copyWith(status: RideStatus.vehicleSelection);
          throw Exception('Payment failed or was cancelled');
        }
      }

      // 2. Safeguard: Only save to Supabase if we have a real UUID
      String bookingId = '00000000-0000-0000-0000-000000000000';
      if (!isDemoUser) {
        final bookingWithPayment = RideBooking(
          id: '',
          customerId: custId,
          pickupAddress: booking.pickupAddress,
          destinationAddress: booking.destinationAddress,
          pickupLat: booking.pickupLat,
          pickupLng: booking.pickupLng,
          destLat: booking.destLat,
          destLng: booking.destLng,
          fare: booking.fare,
          otp: booking.otp,
          createdAt: booking.createdAt,
          scheduledFor: booking.scheduledFor,
          paymentMethod: booking.paymentMethod,
          razorpayPaymentId: state.paymentMethod == 'Online' ? paymentId : null,
          status: state.paymentMethod == 'Online' ? 'paid' : 'searching',
        );
        bookingId = await ref
            .read(rideBookingRepositoryProvider)
            .createRideBooking(bookingWithPayment);
      }

      state = state.copyWith(
          rideId: bookingId,
          otp: generatedOtp,
          isOtpVerified: false,
          razorpayPaymentId: state.paymentMethod == 'Online' ? paymentId : null);


      if (nearbyDrivers.isEmpty) {
        // In production (or when _simulateMockDriver is false): signal UI to
        // show the schedule-or-cancel dialog. No driver auto-assignment.
        if (kDebugMode && _simulateMockDriver) {
          if (kDebugMode) {
            debugPrint(
                'TaxiProvider [DEBUG]: No real drivers — simulating mock driver. '
                'Set _simulateMockDriver=false to test production path.');
          }
          // After 2 seconds, simulate driver acceptance
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted || state.status != RideStatus.booked) return;
            final mockRide = RideBooking(
              id: bookingId,
              customerId: booking.customerId,
              driverId: 'mock_driver_${selectedVehicle}_123',
              pickupAddress: booking.pickupAddress,
              destinationAddress: booking.destinationAddress,
              pickupLat: booking.pickupLat,
              pickupLng: booking.pickupLng,
              destLat: booking.destLat,
              destLng: booking.destLng,
              status: 'accepted',
              fare: booking.fare,
              otp: booking.otp,
              createdAt: booking.createdAt,
              scheduledFor: booking.scheduledFor,
              vehicleType: selectedVehicle,
            );
            _onDriverAssigned(mockRide);
          });
          return true;
        }
        // Production path — automatically cancel and refund
        await cancelAndRefund();
        throw Exception('Rider is not available');
      }

      // Sort closest driver first
      nearbyDrivers.sort((a, b) {
        final distA = distanceCalc.as(
            LengthUnit.Meter, state.pickupLocation!, a.currentPosition!);
        final distB = distanceCalc.as(
            LengthUnit.Meter, state.pickupLocation!, b.currentPosition!);
        return distA.compareTo(distB);
      });

      unawaited(_rideSubscription?.cancel());
      _rideSubscription = ref
          .read(rideBookingRepositoryProvider)
          .watchBooking(bookingId)
          .listen((updatedRide) {
        if (updatedRide != null) {
          // When a driver accepts, status changes to 'accepted'
          if (updatedRide.status == 'accepted' &&
              updatedRide.driverId != null &&
              (state.status == RideStatus.booked ||
                  state.status == RideStatus.idle)) {
            _onDriverAssigned(updatedRide);
          }

          if (updatedRide.status == 'arrived') {
            state =
                state.copyWith(status: RideStatus.atPickup, eta: 'Arrived');
          } else if (updatedRide.status == 'started') {
            state = state.copyWith(status: RideStatus.headingToDropoff);
          } else if (updatedRide.status == 'completed') {
            state = state.copyWith(status: RideStatus.completed);
            _rideSubscription?.cancel();
            _driverLocationSubscription?.cancel();
          } else if (updatedRide.status == 'cancelled') {
            // Booking was cancelled (e.g. 90s timeout)
            state = state.copyWith(status: RideStatus.idle);
            _rideSubscription?.cancel();
          }
        }
      });

      // 90-second search timeout
      _searchTimeoutTimer?.cancel();
      _searchTimeoutTimer = Timer(const Duration(seconds: 90), () {
        if (state.status == RideStatus.booked) {
          _cancelBookingOnBackend();
          state = state.copyWith(status: RideStatus.idle);
          debugPrint('TaxiProvider: Driver search timed out after 90s');
        }
      });

      // NOTE: NO auto-accept here. We wait for a real driver to accept via
      // the Supabase Realtime listener above. The driver's app shows a request
      // notification and they tap Accept, which changes status → 'accepted'.
      return true;
    } catch (e) {
      debugPrint('Error booking ride: $e');
      state = state.copyWith(status: RideStatus.vehicleSelection);
      rethrow;
    }
  }

  void _onDriverAssigned(RideBooking ride) {
    _searchTimeoutTimer?.cancel();
    state = state.copyWith(
      status: RideStatus.tracking,
      roadroboName: ride.driverId!.startsWith('mock_')
          ? 'Simulated Rider'
          : 'Driver Assigned',
      driverId: ride.driverId,
    );

    _driverLocationSubscription?.cancel();
    if (ride.driverId!.startsWith('mock_')) {
      // Simulate driver approaching pickup — tracked for proper cancellation
      final startPos = LatLng(
        state.pickupLocation!.latitude + 0.015,
        state.pickupLocation!.longitude - 0.015,
      );
      state = state.copyWith(roadroboLocation: startPos);

      int steps = 0;
      const totalSteps = 10;
      _mockMovementTimer?.cancel();
      _mockMovementTimer =
          Timer.periodic(const Duration(seconds: 2), (timer) {
        if (!mounted || state.status != RideStatus.tracking) {
          timer.cancel();
          return;
        }

        steps++;
        final double fraction = steps / totalSteps;
        final lat = startPos.latitude +
            (state.pickupLocation!.latitude - startPos.latitude) * fraction;
        final lng = startPos.longitude +
            (state.pickupLocation!.longitude - startPos.longitude) * fraction;

        final currentPos = LatLng(lat, lng);
        const distanceCalc = Distance();
        final double meters = distanceCalc.as(
            LengthUnit.Meter, currentPos, state.pickupLocation!);
        final double distanceKm = meters / 1000.0;
        final int etaMins = (meters / 333).ceil().clamp(1, 120);

        state = state.copyWith(
          roadroboLocation: currentPos,
          eta: '${distanceKm.toStringAsFixed(1)} km • $etaMins mins',
        );

        if (steps >= totalSteps) {
          timer.cancel();
          arriveAtPickup();
        }
      });
    } else {
      _driverLocationSubscription = ref
          .read(driverRepositoryProvider)
          .watchDriver(ride.driverId!)
          .listen((driver) {
        if (driver != null && driver.currentPosition != null) {
          final targetLocation = state.status == RideStatus.headingToDropoff
              ? state.dropoffLocation!
              : state.pickupLocation!;

          const distanceCalc = Distance();
          final double meters = distanceCalc.as(
              LengthUnit.Meter, driver.currentPosition!, targetLocation);

          final double distanceKm = meters / 1000.0;
          final int etaMins = (meters / 333).ceil().clamp(1, 120);

          state = state.copyWith(
            roadroboLocation: driver.currentPosition,
            eta: '${distanceKm.toStringAsFixed(1)} km • $etaMins mins',
          );
        }
      });
    }
  }

  void completeRide() {
    _searchTimeoutTimer?.cancel();
    _mockMovementTimer?.cancel();
    state = state.copyWith(status: RideStatus.completed);
    _rideSubscription?.cancel();
    _driverLocationSubscription?.cancel();
  }

  void reset() {
    // Use clearTrip() to only reset trip-specific fields, preserving
    // the user's pickup location so they don't have to re-detect GPS.
    final currentPickup = state.pickupLocation;
    final currentPickupAddress = state.pickupAddress;
    final currentMock = state.mockLocations;
    final currentPaymentMethod = state.paymentMethod;
    state = TaxiState(
      pickupLocation: currentPickup,
      pickupAddress: currentPickupAddress,
      mockLocations: currentMock,
      paymentMethod: currentPaymentMethod,
    );
    _generateRideOptions();
  }

  Future<void> scheduleRideForLater(DateTime scheduledTime) async {
    final bookingId = state.rideId;
    if (bookingId == null || bookingId.isEmpty) return;
    
    try {
      if (bookingId != '00000000-0000-0000-0000-000000000000') {
        await ref.read(rideBookingRepositoryProvider).updateScheduledTime(bookingId, scheduledTime);
      }
      reset();
    } catch (e) {
      debugPrint('Failed to schedule ride for later: $e');
      throw Exception('Failed to schedule ride.');
    }
  }

  // Toggle to false in debug to exercise the production 'no drivers' path.
  // Always false in release (the kDebugMode guard prevents it from mattering).
  static const bool _simulateMockDriver = kDebugMode;

  @override
  void dispose() {
    _searchTimeoutTimer?.cancel();
    _mockMovementTimer?.cancel();
    _distanceDebounce?.cancel();
    _rideSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    super.dispose();
  }

  void _generateRideOptions([double? distance]) {
    final d = distance ?? state.distance;
    final bool hasDistance = d > 0.1;

    // ── Surge Pricing Logic ──
    final hour = DateTime.now().hour;
    double surgeMultiplier = 1.0;

    if (hour >= 8 && hour <= 11) {
      surgeMultiplier = 1.3; // Morning peak
    } else if (hour >= 17 && hour <= 20) {
      surgeMultiplier = 1.5; // Evening peak
    } else if (hour >= 23 || hour <= 4) {
      surgeMultiplier = 1.2; // Late night
    }

    // Pricing formulas: (Base + (Rate * Distance)) * Surge
    final double bikePrice =
        (hasDistance ? (25 + (12 * d)) : 105) * surgeMultiplier;
    final double autoPrice =
        (hasDistance ? (45 + (15 * d)) : 178) * surgeMultiplier;
    final double cabPrice =
        (hasDistance ? (70 + (22 * d)) : 267) * surgeMultiplier;

    state = state.copyWith(
      rideOptions: [
        RideOption(
          id: 'bike',
          title: 'Bike',
          subtitle: '1 min away • Drop 5:05pm',
          price: bikePrice.roundToDouble(),
          tag: 'Cheapest',
          icon: Icons.motorcycle,
          assetPath: 'assets/icons/bycicle.png',
        ),
        RideOption(
          id: 'auto_sharing',
          title: 'Auto Sharing',
          subtitle: '2 min away • Drop 5:08pm',
          price: (autoPrice * 0.7).roundToDouble(),
          tag: 'Eco',
          icon: Icons.electric_rickshaw,
          assetPath: 'assets/icons/rikshaw.png',
        ),
        RideOption(
          id: 'auto',
          title: 'Auto',
          subtitle: '2 min away • Drop 5:07pm',
          price: autoPrice.roundToDouble(),
          icon: Icons.electric_rickshaw,
          assetPath: 'assets/icons/rikshaw.png',
        ),
        RideOption(
          id: 'cab_economy',
          title: 'Cab Economy',
          subtitle: '5 min away • Drop 5:10pm',
          price: cabPrice.roundToDouble(),
          icon: Icons.local_taxi,
          assetPath: 'assets/icons/car.png',
        ),
        RideOption(
          id: 'cab_priority',
          title: 'Cab Priority',
          subtitle: '2 min away • Drop 5:06pm',
          price: (cabPrice * 1.3).roundToDouble(),
          tag: 'Quickest',
          icon: Icons.local_taxi,
          assetPath: 'assets/icons/car.png',
        ),
      ],
    );
  }

  void selectOption(RideOption option) {
    state = state.copyWith(selectedOption: option);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void applyPromoCode(String code, double amount) {
    state = state.copyWith(appliedPromoCode: code, discountAmount: amount);
  }

  void setTipAmount(double amount) {
    state = state.copyWith(tipAmount: amount);
  }

  void setScheduledTime(DateTime time) {
    state = state.copyWith(scheduledFor: time);
  }

  void setFocus(bool isPickup) {
    state = state.copyWith(
        status:
            isPickup ? RideStatus.selectingPickup : RideStatus.selectingDrop);
  }

  void cancelRide() {
    cancelAndRefund();
  }

  /// Called when user manually cancels or 10-min timer fires.
  /// Cancels on backend and triggers auto-refund if payment was online.
  Future<void> cancelAndRefund() async {
    _searchTimeoutTimer?.cancel();
    unawaited(_rideSubscription?.cancel());

    final bookingId = state.rideId;
    final wasOnline = state.paymentMethod == 'Online';
    final payId = state.razorpayPaymentId;

    await _cancelBookingOnBackend();

    if (wasOnline && payId != null) {
      // Trigger refund via Supabase Edge Function
      try {
        await Supabase.instance.client.functions.invoke(
          'initiate_refund',
          body: {
            'payment_id': payId,
            'booking_id': bookingId ?? '',
            'reason': 'no_driver_found',
          },
        );
        state = state.copyWith(refundInitiated: true);
        if (kDebugMode) debugPrint('Refund initiated for payment $payId');
      } catch (e) {
        if (kDebugMode) debugPrint('Refund initiation failed: $e');
      }
    }

    reset();
  }



  Future<void> _cancelBookingOnBackend() async {
    final bookingId = state.rideId;
    if (bookingId == null || bookingId.isEmpty) return;
    try {
      await ref.read(rideBookingRepositoryProvider).cancelBooking(bookingId);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to cancel booking on backend: $e');
    }
  }

  Future<bool> startSearching() async {
    // Do NOT set booked here — bookRide() handles status internally
    return await bookRide();
  }

  void shareTrip(String mapsLink) {
    Share.share('Track my RoAdRoBo trip live here: $mapsLink');
  }
}

// StateNotifierProvider
final taxiProvider = StateNotifierProvider<TaxiNotifier, TaxiState>((ref) {
  final notifier = TaxiNotifier(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

// Controllers using Provider.onDispose
final pickupControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final dropoffControllerProvider = Provider<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});
