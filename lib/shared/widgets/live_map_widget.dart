import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/taxi_provider.dart';
import '../../features/rentals/map_controller.dart';
import '../../core/services/osm_maps_service.dart';
import '../../core/providers/driver_location_provider.dart';
import 'glass_card.dart';

class LiveMapWidget extends ConsumerStatefulWidget {
  final double height;
  final bool showLiveIndicator;
  final LatLng? roadroboLocation;
  final void Function(MapCamera, bool)? onPositionChanged;
  final bool showBackgroundMarkers;
  final bool isTracking;
  final LatLng? pickupLocation;
  final bool isDriver;
  final bool showNearbyTaxis;
  final String? driverId;

  const LiveMapWidget({
    super.key,
    required this.height,
    this.showLiveIndicator = true,
    this.roadroboLocation,
    this.onPositionChanged,
    this.showBackgroundMarkers = true,
    this.isTracking = false,
    this.pickupLocation,
    this.isDriver = false,
    this.showNearbyTaxis = false,
    this.driverId,
  });

  @override
  ConsumerState<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends ConsumerState<LiveMapWidget> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;
  final _osmService = OSMMapsService();
  
  LatLng? _selectedPoint;
  String? _selectedLabel;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _listenToDriver();
  }

  void _listenToDriver() {
    if (widget.driverId != null) {
      Supabase.instance.client
          .from('driver_locations')
          .stream(primaryKey: ['driver_id'])
          .eq('driver_id', widget.driverId!)
          .listen((data) {
        if (data.isNotEmpty) {
          final lat = data.first['lat'] as double?;
          final lng = data.first['lng'] as double?;
          if (lat != null && lng != null && mounted) {
            setState(() {
              _selectedPoint = LatLng(lat, lng);
            });
            if (widget.isTracking) {
              _mapController.move(LatLng(lat, lng), _mapController.camera.zoom);
            }
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget(LiveMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pickupLocation != oldWidget.pickupLocation || 
        widget.roadroboLocation != oldWidget.roadroboLocation) {
      _updateRoute();
    }
  }

  Future<void> _updateRoute() async {
    if (widget.roadroboLocation != null) {
      final taxiState = ref.read(taxiProvider);
      LatLng? target;
      
      if (taxiState.status == RideStatus.headingToDropoff) {
        target = taxiState.dropoffLocation;
      } else {
        target = widget.pickupLocation;
      }

      if (target != null) {
        final points = await _osmService.getRoute(widget.roadroboLocation!, target);
        if (mounted) {
          setState(() {
            _routePoints = points;
          });
        }
      }
    }
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
      if (!mounted) return;
      final bounds = LatLngBounds(p1, p2);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.only(top: 80, bottom: 340, left: 60, right: 60),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(mapControllerProvider);
    final taxiState = ref.watch(taxiProvider);

    // Auto-fit or Auto-follow logic
    if (widget.isTracking && widget.roadroboLocation != null) {
      LatLng? target;
      if (taxiState.status == RideStatus.headingToDropoff) {
        target = taxiState.dropoffLocation;
      } else {
        target = widget.pickupLocation;
      }

      if (target != null) {
        _fitBounds(widget.roadroboLocation!, target);
      } else {
        _mapController.move(widget.roadroboLocation!, 16);
      }
    }

    final markers = <Marker>[];
    
    // Pickup/Drop Markers
    if (!widget.isTracking) {
      markers.add(
        Marker(
          point: taxiState.pickupLocation ?? mapState.userLocation,
          width: 60,
          height: 60,
          child: _buildLocationPin(isPickup: true, point: taxiState.pickupLocation ?? mapState.userLocation, label: 'Pickup Point'),
        ),
      );

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
    } else {
      if (widget.pickupLocation != null && taxiState.status != RideStatus.headingToDropoff) {
        markers.add(
          Marker(
            point: widget.pickupLocation!,
            width: 40,
            height: 40,
            child: _buildLocationPin(isPickup: true, point: widget.pickupLocation!, label: 'Pickup Point'),
          ),
        );
      }
      
      if (taxiState.dropoffLocation != null) {
        markers.add(
          Marker(
            point: taxiState.dropoffLocation!,
            width: 50,
            height: 50,
            child: _buildLocationPin(isPickup: false, point: taxiState.dropoffLocation!, label: 'Drop-off Point'),
          ),
        );
      }
    }

    // Roadrobo Marker
    if (widget.roadroboLocation != null) {
      markers.add(
        Marker(
          point: widget.roadroboLocation!,
          width: 50,
          height: 50,
          child: _buildVehicleMarker(taxiState.selectedOption?.assetPath ?? 'assets/icons/car.png'),
        ),
      );
    }

    // Live Taxis from Supabase
    if (widget.showNearbyTaxis) {
      final liveTaxis = ref.watch(availableTaxiLocationsProvider).value ?? const [];
      for (final taxi in liveTaxis) {
        markers.add(
          Marker(
            point: taxi.position,
            width: 40,
            height: 40,
            child: _buildVehicleMarker(
              taxi.type == 'bike' 
                  ? 'assets/icons/bycicle.png' 
                  : taxi.type == 'auto' 
                      ? 'assets/icons/rikshaw.png' 
                      : 'assets/icons/car.png'
            ),
          ),
        );
      }
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
              onPositionChanged: widget.onPositionChanged,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roadrobos.app',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              PolylineLayer(
                polylines: [
                  if (_routePoints.isNotEmpty)
                    Polyline(
                      points: _routePoints,
                      color: AppColors.primaryBlue,
                      strokeWidth: 5,
                      borderColor: Colors.white,
                      borderStrokeWidth: 2,
                    ),
                  ...mapState.polylines,
                ],
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // --- UI Overlays ---
          if (widget.showLiveIndicator)
            Positioned(top: 20, right: 20, child: _buildLiveIndicator()),
            
          Positioned(
            bottom: 24,
            right: 20,
            child: _buildMapControls(),
          ),

          if (_selectedPoint != null)
            Positioned(bottom: 100, left: 20, right: 20, child: _buildMarkerCallout()),

          if (mapState.isLoading)
            const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Column(
      children: [
        _buildCircleButton(
          icon: Iconsax.gps,
          onTap: () {
            final loc = ref.read(mapControllerProvider).userLocation;
            _mapController.move(loc, 16);
          },
        ),
        const SizedBox(height: 12),
        _buildCircleButton(
          icon: Icons.add,
          onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1),
        ),
        const SizedBox(height: 12),
        _buildCircleButton(
          icon: Icons.remove,
          onTap: () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1),
        ),
      ],
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: AppColors.primaryNavy, size: 24),
      ),
    );
  }

  Widget _buildVehicleMarker(String asset) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (value * 0.2),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 10, spreadRadius: 2)],
              border: Border.all(color: AppColors.primaryBlue, width: 2),
            ),
            child: Image.asset(asset, width: 30, height: 30),
          ),
        );
      },
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

  Widget _buildLocationPin({required bool isPickup, LatLng? point, required String label}) {
    final color = isPickup ? Colors.green : AppColors.errorRed;
    return GestureDetector(
      onTap: point != null ? () => _onMarkerTap(point, label) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 45, height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 5)],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1000.ms),
           
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Center(
              child: Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle))
            .animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 1.seconds),
          const SizedBox(width: 6),
          const Text('LIVE TRACKING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        ],
      ),
    );
  }
}

