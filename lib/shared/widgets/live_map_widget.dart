import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../features/rides/taxi_provider.dart';
import '../../features/rentals/map_controller.dart';
import 'glass_card.dart';

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

class _LiveMapWidgetState extends ConsumerState<LiveMapWidget> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;
  LatLng? _selectedPoint;
  String? _selectedLabel;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onMarkerTap(LatLng point, String label) {
    setState(() {
      _selectedPoint = point;
      _selectedLabel = label;
    });
    _mapController.move(point, 17);
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
        child: _buildLocationPin(isPickup: true, point: taxiState.pickupLocation ?? mapState.userLocation, label: 'Pickup Point'),
      ),
    ];

    if (taxiState.dropoffLocation != null) {
      markers.add(
        Marker(
          point: taxiState.dropoffLocation!,
          width: 60,
          height: 60,
          child: _buildLocationPin(isPickup: false, point: taxiState.dropoffLocation!, label: 'Drop-off Point'),
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
              onTap: (_, __) => setState(() {
                _selectedPoint = null;
                _selectedLabel = null;
              }),
              onLongPress: (tapPosition, point) {
                HapticFeedback.heavyImpact();
                ref.read(mapControllerProvider.notifier).selectDestination(point);
                setState(() {
                  _selectedPoint = point;
                  _selectedLabel = 'Selected Destination';
                });
              },
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roadrobos.app',
                tileProvider: CancellableNetworkTileProvider(),
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
            
          if (_selectedPoint != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildMarkerCallout(),
            ),

          if (mapState.isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildMarkerCallout() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      opacity: 0.8,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Iconsax.location, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedLabel ?? 'Location Details', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Text('Arriving in 4 mins', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: AppColors.textMuted),
            onPressed: () => setState(() {
              _selectedPoint = null;
              _selectedLabel = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptainPin() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 50 * _pulseController.value,
              height: 50 * _pulseController.value,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.3 * (1 - _pulseController.value)),
                shape: BoxShape.circle,
              ),
            ),
            GestureDetector(
              onTap: () => _onMarkerTap(widget.captainLocation!, 'Captain Location'),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.delivery_dining_rounded, color: AppColors.primaryBlue, size: 30),
                ),
              ),
            ),
          ],
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn();
      },
    );
  }

  Widget _buildLocationPin({required bool isPickup, LatLng? point, required String label}) {
    return GestureDetector(
      onTap: point != null ? () => _onMarkerTap(point, label) : null,
      child: Stack(
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
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
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
