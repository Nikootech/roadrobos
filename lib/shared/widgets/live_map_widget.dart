import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/taxi_provider.dart';
import '../../features/rentals/map_controller.dart';
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
  });

  @override
  ConsumerState<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends ConsumerState<LiveMapWidget> with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _pulseController;
  LatLng? _selectedPoint;
  String? _selectedLabel;
  LatLng? _lastPickup;
  LatLng? _lastDropoff;

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

  LatLng? _lastRoadroboFit;
  LatLng? _lastTargetFit;

  void _fitBounds(LatLng p1, LatLng p2) {
    // Only fit if points have changed significantly or it's the first time
    if (_lastRoadroboFit != null && _lastTargetFit != null) {
      const distanceCalc = Distance();
      final d1 = distanceCalc.as(LengthUnit.Meter, p1, _lastRoadroboFit!);
      final d2 = distanceCalc.as(LengthUnit.Meter, p2, _lastTargetFit!);
      if (d1 < 10 && d2 < 10) return; // Skip if less than 10m change
    }
    
    _lastRoadroboFit = p1;
    _lastTargetFit = p2;

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

    // Auto-fit or Auto-follow logic matching Rapido Captain
    if (widget.isTracking && widget.roadroboLocation != null) {
      LatLng? target;
      if (taxiState.status == RideStatus.headingToDropoff) {
        target = taxiState.dropoffLocation;
      } else {
        target = widget.pickupLocation;
      }

      if (target != null) {
        // Fit both driver and target destination
        _fitBounds(widget.roadroboLocation!, target);
      } else {
        // Just center on driver if no target
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(widget.roadroboLocation!, 16);
        });
      }
    } else if (taxiState.pickupLocation != null && taxiState.dropoffLocation != null) {
      if (taxiState.pickupLocation != _lastPickup || taxiState.dropoffLocation != _lastDropoff) {
        _lastPickup = taxiState.pickupLocation;
        _lastDropoff = taxiState.dropoffLocation;
        _fitBounds(taxiState.pickupLocation!, taxiState.dropoffLocation!);
      }
    } else if (taxiState.dropoffLocation != null) {
      if (taxiState.dropoffLocation != _lastDropoff) {
        _lastDropoff = taxiState.dropoffLocation;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _mapController.move(taxiState.dropoffLocation!, 15);
        });
      }
    }

    final markers = <Marker>[];
    
    // Only show pickup/drop if NOT in focus tracking mode OR if specifically allowed
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
      // TRACKING MODE logic
      if (widget.pickupLocation != null) {
        // Show pickup pin when approaching or at pickup
        if (taxiState.status != RideStatus.headingToDropoff) {
          markers.add(
            Marker(
              point: widget.pickupLocation!,
              width: 40,
              height: 40,
              child: _buildLocationPin(isPickup: true, point: widget.pickupLocation!, label: 'Pickup Point'),
            ),
          );
        }
      }
      
      // Show drop-off pin when at pickup or heading to drop-off
      if ((taxiState.status == RideStatus.atPickup || taxiState.status == RideStatus.headingToDropoff) && taxiState.dropoffLocation != null) {
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

    // 3. Roadrobo Marker
    if (widget.roadroboLocation != null) {
      markers.add(
        Marker(
          point: widget.roadroboLocation!,
          width: 50,
          height: 50,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                    ],
                    border: Border.all(color: AppColors.primaryBlue, width: 2),
                  ),
                  child: Image.asset(
                    taxiState.selectedOption?.assetPath ?? 'assets/icons/car.png',
                    width: 30,
                    height: 30,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // 4. Dynamic Nearby Vehicles - Only show matching the selected ride type
    if (widget.showBackgroundMarkers && !widget.isDriver &&
        (taxiState.status == RideStatus.idle || taxiState.status == RideStatus.vehicleSelection)) {
      for (final vehicle in taxiState.nearbyVehicles) {
        String assetPath = 'assets/icons/car.png';
        if (vehicle.type == 'bike') {
          assetPath = 'assets/icons/bycicle.png';
        } else if (vehicle.type == 'auto') {
          assetPath = 'assets/icons/rikshaw.png';
        }

        markers.add(
          Marker(
            point: vehicle.position,
            width: 40,
            height: 40,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        assetPath, 
                        width: 28, height: 28,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }
    }

    final polylines = <Polyline>[];
    if (widget.isTracking && widget.roadroboLocation != null) {
      if (taxiState.status == RideStatus.headingToDropoff && taxiState.dropoffLocation != null) {
        // Route to dropoff
        polylines.add(
          Polyline(
            points: [widget.roadroboLocation!, taxiState.dropoffLocation!],
            color: AppColors.primaryBlue,
            strokeWidth: 5,
          ),
        );
      } else if (widget.pickupLocation != null) {
        // Route to pickup
        polylines.add(
          Polyline(
            points: [widget.roadroboLocation!, widget.pickupLocation!],
            color: AppColors.primaryBlue.withOpacity(0.8),
            strokeWidth: 4,
          ),
        );
      }
    } else if (taxiState.pickupLocation != null && taxiState.dropoffLocation != null) {
      polylines.add(
        Polyline(
          points: [taxiState.pickupLocation!, taxiState.dropoffLocation!],
          color: AppColors.primaryBlue.withOpacity(0.7),
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
              onPositionChanged: widget.onPositionChanged,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roadrobos.app',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              // --- Phase 3: Traffic Overlay ---
              TileLayer(
                urlTemplate: 'https://api.mapbox.com/styles/v1/mapbox/traffic-day-v2/tiles/{z}/{x}/{y}?access_token={accessToken}',
                additionalOptions: const {
                  'accessToken': 'pk.placeholder_mapbox_token', // User to update with real token
                },
                userAgentPackageName: 'com.roadrobos.app',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              PolylineLayer(polylines: polylines.isNotEmpty ? polylines : mapState.polylines),
              MarkerLayer(
                markers: [
                  // Only show background markers (rental hubs, etc.) when permitted
                  if (widget.showBackgroundMarkers && 
                      taxiState.status != RideStatus.selectingPickup && 
                      taxiState.status != RideStatus.selectingDrop)
                    ...mapState.markers,
                    
                  ...markers, // Top layer (Ride markers: Pickup/Drop/Roadrobo)
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
            decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
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
          // Outer Glow
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 5,
                )
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1000.ms),
           
          // Inner Circle
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
          
          // Label if selected (optional, for now just the pin)
        ],
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }

  Widget _buildLiveIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
