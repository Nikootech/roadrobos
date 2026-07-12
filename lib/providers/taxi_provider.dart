// IMPORTANT: All StreamSubscription fields must be cancelled in dispose/onDispose.

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import '../features/profile/user_provider.dart';
import '../core/models/ride_booking.dart';
import '../core/repositories/ride_booking_repository.dart';
import '../core/repositories/driver_repository.dart';
import '../core/services/user_tracking_service.dart';
import '../core/services/osm_maps_service.dart';


enum RideStatus { 
  idle, 
  selectingPickup, 
  selectingDrop, 
  vehicleSelection, 
  booked, 
  tracking, 
  atPickup, 
  headingToDropoff, 
  completed 
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
  });

  TaxiState copyWith({
    RideStatus? status,
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
    LatLng? roadroboLocation,
    String? pickupAddress,
    String? dropoffAddress,
    String? roadroboName,
    String? driverId,
    String? eta,
    double? distance,
    String? otp,
    bool? isOtpVerified,
    List<NearbyVehicle>? nearbyVehicles,
    List<RideOption>? rideOptions,
    RideOption? selectedOption,
    List<Map<String, dynamic>>? mockLocations,
    String? rideId,
    String? paymentMethod,
    double? discountAmount,
    String? appliedPromoCode,
    double? tipAmount,
    DateTime? scheduledFor,
  }) {
    return TaxiState(
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      roadroboLocation: roadroboLocation ?? this.roadroboLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      roadroboName: roadroboName ?? this.roadroboName,
      driverId: driverId ?? this.driverId,
      eta: eta ?? this.eta,
      distance: distance ?? this.distance,
      otp: otp ?? this.otp,
      isOtpVerified: isOtpVerified ?? this.isOtpVerified,
      nearbyVehicles: nearbyVehicles ?? this.nearbyVehicles,
      rideOptions: rideOptions ?? this.rideOptions,
      selectedOption: selectedOption ?? this.selectedOption,
      mockLocations: mockLocations ?? this.mockLocations,
      rideId: rideId ?? this.rideId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      discountAmount: discountAmount ?? this.discountAmount,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
      tipAmount: tipAmount ?? this.tipAmount,
      scheduledFor: scheduledFor ?? this.scheduledFor,
    );
  }
}

class TaxiNotifier extends StateNotifier<TaxiState> {
  final Ref ref;
  TaxiNotifier(this.ref) : super(TaxiState());

  StreamSubscription? _driverLocationSubscription;
  StreamSubscription? _rideSubscription;
  Timer? _searchTimeoutTimer;
  final _trackingService = UserTrackingService();

  Future<void> initializeLocation() async {
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

      final location = await _trackingService.getCurrentLocation() ?? const LatLng(12.9716, 77.5946);
      
      // Auto fetch address
      final osmService = OSMMapsService();
      final address = await osmService.getAddressFromCoords(location);

      state = state.copyWith(
        pickupLocation: location,
        pickupAddress: address ?? 'Current Location',
        mockLocations: [
          {'name': 'MG Road', 'address': 'MG Road, Bengaluru', 'distance': '2.4 km', 'lat': 12.9716, 'lng': 77.5946},
          {'name': 'Indiranagar', 'address': 'Indiranagar, Bengaluru', 'distance': '4.1 km', 'lat': 12.9719, 'lng': 77.6412},
          {'name': 'Koramangala', 'address': 'Koramangala, Bengaluru', 'distance': '5.8 km', 'lat': 12.9352, 'lng': 77.6245},
        ],
      );
      // _generateNearbyVehicles(location); // Removed as requested
      _generateRideOptions();
    } catch (e) {
      debugPrint('Error initializing location: $e');
      _setFallbackLocation();
    }
  }

  void _setFallbackLocation() {
    // Default to Bengaluru center if location fails
    const location = LatLng(12.9716, 77.5946);
    state = state.copyWith(
      pickupLocation: location,
      pickupAddress: 'Bengaluru, Karnataka',
      mockLocations: [
        {'name': 'MG Road', 'address': 'MG Road, Bengaluru', 'distance': '2.4 km', 'lat': 12.9716, 'lng': 77.5946},
        {'name': 'Indiranagar', 'address': 'Indiranagar, Bengaluru', 'distance': '4.1 km', 'lat': 12.9719, 'lng': 77.6412},
        {'name': 'Koramangala', 'address': 'Koramangala, Bengaluru', 'distance': '5.8 km', 'lat': 12.9352, 'lng': 77.6245},
      ],
    );
    // _generateNearbyVehicles(location); // Removed as requested
    _generateRideOptions();
  }

  void setPickup(LatLng location, String address) {
    state = state.copyWith(
      pickupLocation: location, 
      pickupAddress: address,
      status: state.dropoffLocation == null ? RideStatus.selectingDrop : RideStatus.vehicleSelection,
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

  void _calculateDistance() async {
    if (state.pickupLocation != null && state.dropoffLocation != null) {
      final osmService = OSMMapsService();
      final route = await osmService.getRoute(state.pickupLocation!, state.dropoffLocation!);
      final distanceKm = osmService.calculateDistanceInKm(route);
      
      state = state.copyWith(distance: distanceKm);
      _generateRideOptions(distanceKm);
    }
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
      roadroboLocation: const LatLng(12.9716, 77.5946), // Driver starting position
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
      return true;
    }
    return false;
  }

  void startTrip() {
    if (state.isOtpVerified) {
      state = state.copyWith(status: RideStatus.headingToDropoff);
      // Wait for backend updates for live tracking
    }
  }

  Future<bool> bookRide() async {
    state = state.copyWith(status: RideStatus.booked);
    
    try {
      final user = ref.read(userProvider);
      
      // Check for available drivers based on selected option
      final selectedVehicle = state.selectedOption?.id ?? 'auto';
      final onlineDrivers = await ref.read(driverRepositoryProvider).getOnlineDrivers(selectedVehicle);
      
      if (onlineDrivers.isEmpty) {
        // No drivers found, reset status and return false
        state = state.copyWith(status: RideStatus.idle);
        return false;
      }
      
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

      if (nearbyDrivers.isEmpty) {
        // No drivers within the search radius
        state = state.copyWith(status: RideStatus.idle);
        return false;
      }

      // Sort closest driver first
      nearbyDrivers.sort((a, b) {
        final distA = distanceCalc.as(LengthUnit.Meter, state.pickupLocation!, a.currentPosition!);
        final distB = distanceCalc.as(LengthUnit.Meter, state.pickupLocation!, b.currentPosition!);
        return distA.compareTo(distB);
      });

      final random = Random();
      final generatedOtp = (1000 + random.nextInt(9000)).toString(); // 4 digit OTP

      final booking = RideBooking(
        id: '', 
        customerId: user.user?.id ?? 'demo',
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
      );

      final bookingId = await ref.read(rideBookingRepositoryProvider).createRideBooking(booking);
      state = state.copyWith(rideId: bookingId, otp: generatedOtp, isOtpVerified: false);
      
      unawaited(_rideSubscription?.cancel());
      _rideSubscription = ref.read(rideBookingRepositoryProvider)
          .watchBooking(bookingId)
          .listen((updatedRide) {
            if (updatedRide != null) {
              // When a driver accepts, status changes to 'accepted'
              if (updatedRide.status == 'accepted' && updatedRide.driverId != null &&
                  (state.status == RideStatus.booked || state.status == RideStatus.idle)) {
                _onDriverAssigned(updatedRide);
              }

              if (updatedRide.status == 'arrived') {
                state = state.copyWith(status: RideStatus.atPickup, eta: 'Arrived');
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
      state = state.copyWith(status: RideStatus.idle);
      return false;
    }
  }

  void _onDriverAssigned(RideBooking ride) {
    _searchTimeoutTimer?.cancel();
    state = state.copyWith(
      status: RideStatus.tracking,
      roadroboName: 'Driver Assigned', 
      driverId: ride.driverId,
    );

    _driverLocationSubscription?.cancel();
    _driverLocationSubscription = ref.read(driverRepositoryProvider)
        .watchDriver(ride.driverId!)
        .listen((driver) {
          if (driver != null && driver.currentPosition != null) {
            final targetLocation = state.status == RideStatus.headingToDropoff 
                ? state.dropoffLocation! 
                : state.pickupLocation!;
            
            const distanceCalc = Distance();
            final double meters = distanceCalc.as(LengthUnit.Meter, driver.currentPosition!, targetLocation);
            
            final double distanceKm = meters / 1000.0;
            final int etaMins = (meters / 333).ceil().clamp(1, 120);
            
            state = state.copyWith(
              roadroboLocation: driver.currentPosition,
              eta: '${distanceKm.toStringAsFixed(1)} km • $etaMins mins',
            );
          }
        });
  }

  void completeRide() {
    _searchTimeoutTimer?.cancel();
    state = state.copyWith(status: RideStatus.completed);
    _rideSubscription?.cancel();
    _driverLocationSubscription?.cancel();
  }

  void reset() {
    state = TaxiState();
    initializeLocation();
  }

  @override
  void dispose() {
    _searchTimeoutTimer?.cancel();
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
    final double bikePrice = (hasDistance ? (25 + (12 * d)) : 105) * surgeMultiplier;
    final double autoPrice = (hasDistance ? (45 + (15 * d)) : 178) * surgeMultiplier;
    final double cabPrice = (hasDistance ? (70 + (22 * d)) : 267) * surgeMultiplier;

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
    state = state.copyWith(status: isPickup ? RideStatus.selectingPickup : RideStatus.selectingDrop);
  }

  void cancelRide() {
    _cancelBookingOnBackend();
    _searchTimeoutTimer?.cancel();
    reset();
  }

  Future<void> _cancelBookingOnBackend() async {
    final bookingId = state.rideId;
    if (bookingId == null || bookingId.isEmpty) return;
    try {
      await ref.read(rideBookingRepositoryProvider).cancelBooking(bookingId);
    } catch (e) {
      debugPrint('Failed to cancel booking on backend: $e');
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
