import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../features/rides/taxi_provider.dart';
import '../../features/rentals/map_controller.dart';

class LiveMapWidget extends ConsumerStatefulWidget {
  final double height;
  final bool showLiveIndicator;
  final LatLng? captainLocation;

  const LiveMapWidget({
    super.key,
    required this.height,
    this.showLiveIndicator = true,
    this.captainLocation,
  });

  @override
  ConsumerState<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends ConsumerState<LiveMapWidget> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _fitBounds(LatLng p1, LatLng p2) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bounds = LatLngBounds(p1, p2);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapControllerProvider);
    final taxiState = ref.watch(taxiProvider);

    // Auto-fit if both locations are present
    if (taxiState.pickupLocation != null && taxiState.dropoffLocation != null) {
      _fitBounds(taxiState.pickupLocation!, taxiState.dropoffLocation!);
    } else if (taxiState.dropoffLocation != null) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         _mapController.move(taxiState.dropoffLocation!, 15);
       });
    }

    final markers = <Marker>[
      // 1. Pickup Location
      Marker(
        point: taxiState.pickupLocation ?? mapState.userLocation,
        width: 60,
        height: 60,
        child: _buildLocationPin(isPickup: true),
      ),
    ];

    if (taxiState.dropoffLocation != null) {
      markers.add(
        Marker(
          point: taxiState.dropoffLocation!,
          width: 60,
          height: 60,
          child: _buildLocationPin(isPickup: false),
        ),
      );
    }

    if (widget.captainLocation != null) {
      markers.add(
        Marker(
          point: widget.captainLocation!,
          width: 50,
          height: 50,
          child: _buildCaptainPin(),
        ),
      );
    }

    final polylines = <Polyline>[];
    if (taxiState.pickupLocation != null && taxiState.dropoffLocation != null) {
      polylines.add(
        Polyline(
          points: [taxiState.pickupLocation!, taxiState.dropoffLocation!],
          color: AppColors.primaryBlue.withValues(alpha: 0.7),
          strokeWidth: 4,
        ),
      );
    }

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: taxiState.pickupLocation ?? mapState.userLocation,
              initialZoom: 15,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roadrobos.app',
              ),
              PolylineLayer(polylines: polylines.isNotEmpty ? polylines : mapState.polylines),
              MarkerLayer(
                markers: [
                  ...markers,
                  ...mapState.markers,
                ],
              ),
            ],
          ),

          if (widget.showLiveIndicator)
            Positioned(
              top: 20,
              right: 20,
              child: _buildLiveIndicator(),
            ),
            
          if (mapState.isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildCaptainPin() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: AppColors.primaryBlue, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.delivery_dining_rounded, color: AppColors.primaryBlue, size: 30),
      ),
    );
  }

  Widget _buildLocationPin({required bool isPickup}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (isPickup ? Colors.green : Colors.red).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
        ),
        Icon(
          isPickup ? Icons.radio_button_checked : Icons.location_on_rounded,
          color: isPickup ? Colors.green : Colors.red,
          size: 28,
        ),
      ],
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}
