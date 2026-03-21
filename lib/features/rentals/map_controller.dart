import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

final mapControllerProvider = StateNotifierProvider<AppMapController, AppMapState>((ref) {
  return AppMapController();
});

class AppMapState {
  final MapController? controller; // from flutter_map
  final LatLng userLocation;
  final LatLng? destination;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final bool isLoading;
  final String? errorMessage;

  AppMapState({
    this.controller,
    LatLng? userLocation,
    this.destination,
    this.markers = const [],
    this.polylines = const [],
    this.isLoading = true,
    this.errorMessage,
  }) : userLocation = userLocation ?? const LatLng(12.9716, 77.5946);

  AppMapState copyWith({
    MapController? controller,
    LatLng? userLocation,
    LatLng? destination,
    List<Marker>? markers,
    List<Polyline>? polylines,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AppMapState(
      controller: controller ?? this.controller,
      userLocation: userLocation ?? this.userLocation,
      destination: destination ?? this.destination,
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AppMapController extends StateNotifier<AppMapState> {
  AppMapController() : super(AppMapState()) {
    _initLocation();
  }

  Future<void> _initLocation() async {
    state = state.copyWith(isLoading: true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(isLoading: false, errorMessage: 'Location services disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(isLoading: false, errorMessage: 'Permission denied');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final newLocation = LatLng(position.latitude, position.longitude);
      
      state = state.copyWith(
        userLocation: newLocation,
        isLoading: false,
      );
      
      // addMockVehicles(); // Removed as requested to hide riders/hubs
      // addRentalHubs(); // Removed as requested to hide riders/hubs
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&viewbox=77.3,13.1,77.8,12.8&bounded=1' // Bounded to Bengaluru region
      );
      
      final response = await http.get(url, headers: {
        'User-Agent': 'RoAdRoBosApp/1.0',
      });

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) => {
          'display_name': item['display_name'],
          'lat': double.parse(item['lat']),
          'lon': double.parse(item['lon']),
        }).toList();
      }
    } catch (e) {
      debugPrint('Search error: $e');
    }
    return [];
  }

  void _updateRoute() {
    if (state.destination == null) return;
    
    final route = Polyline(
      points: [state.userLocation, state.destination!],
      color: AppColors.textPrimary.withValues(alpha: 0.7),
      strokeWidth: 5,
    );
    state = state.copyWith(polylines: [route]);
  }

  void addMockVehicles() {
    final center = state.userLocation;
    final List<Marker> vehicleMarkers = [];
    
    for (int i = 0; i < 6; i++) {
        final lat = center.latitude + (i * 0.002) - 0.005;
        final lng = center.longitude + (i * 0.003) - 0.005;
        vehicleMarkers.add(
          Marker(
            point: LatLng(lat, lng),
            width: 45,
            height: 45,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
                ],
              ),
              child: const Icon(Icons.electric_rickshaw_rounded, color: AppColors.accentOrange, size: 28),
            ),
          ),
        );
    }
    state = state.copyWith(markers: vehicleMarkers);
  }

  void addRentalHubs() {
    final center = state.userLocation;
    final List<Marker> hubMarkers = [...state.markers];
    
    final locations = [
      LatLng(center.latitude + 0.008, center.longitude + 0.008),
      LatLng(center.latitude - 0.007, center.longitude - 0.012),
      LatLng(center.latitude + 0.015, center.longitude - 0.005),
    ];

    for (var loc in locations) {
      hubMarkers.add(
        Marker(
          point: loc,
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 24),
          ),
        ),
      );
    }
    state = state.copyWith(markers: hubMarkers);
  }

  void selectDestination(LatLng location) {
    state = state.copyWith(
      destination: location,
      markers: [
        ...state.markers.where((m) => m.key != const Key('destination_marker')),
        Marker(
          key: const Key('destination_marker'),
          point: location,
          width: 50,
          height: 50,
          child: const Icon(Icons.location_on_rounded, color: AppColors.dangerRed, size: 40)
              .animate()
              .slideY(begin: -0.5, end: 0)
              .fadeIn(),
        ),
      ],
    );
    _updateRoute();
  }

  void addMarker(Marker marker) {
    state = state.copyWith(markers: [...state.markers, marker]);
  }

  void clearMarkers() {
    state = state.copyWith(markers: []);
  }
}
