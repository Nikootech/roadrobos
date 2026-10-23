import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconsax/iconsax.dart';

/// Rapido Captain Interactive Live Map Cockpit
/// Displays real-time driver positioning, high-demand surge pricing zones,
/// and live navigation controls.
class RapidoMapCockpit extends StatefulWidget {
  final LatLng? driverLocation;
  final bool isOnline;
  final VoidCallback? onRecenter;

  const RapidoMapCockpit({
    super.key,
    required this.driverLocation,
    required this.isOnline,
    this.onRecenter,
  });

  @override
  State<RapidoMapCockpit> createState() => _RapidoMapCockpitState();
}

class _RapidoMapCockpitState extends State<RapidoMapCockpit>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late final AnimationController _beaconController;

  static const LatLng _fallbackLocation = LatLng(12.9716, 77.5946); // Bangalore

  // Simulated live Rapido Surge Hotspots in the city
  static final List<Map<String, dynamic>> _surgeZones = [
    {
      'name': 'Koramangala',
      'surge': '+₹40',
      'location': const LatLng(12.9352, 77.6245),
      'color': const Color(0xFFEF4444), // High surge red
    },
    {
      'name': 'Indiranagar',
      'surge': '+₹35',
      'location': const LatLng(12.9784, 77.6408),
      'color': const Color(0xFFF59E0B), // Medium-high yellow
    },
    {
      'name': 'HSR Layout',
      'surge': '+₹25',
      'location': const LatLng(12.9121, 77.6446),
      'color': const Color(0xFF10B981), // Steady green
    },
    {
      'name': 'MG Road',
      'surge': '+₹50',
      'location': const LatLng(12.9756, 77.6066),
      'color': const Color(0xFFDC2626), // Peak surge
    },
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _beaconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _beaconController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RapidoMapCockpit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.driverLocation != null &&
        widget.driverLocation != oldWidget.driverLocation) {
      _mapController.move(widget.driverLocation!, 15.0);
    }
  }

  void _recenter() {
    HapticFeedback.lightImpact();
    final target = widget.driverLocation ?? _fallbackLocation;
    _mapController.move(target, 15.5);
    widget.onRecenter?.call();
  }

  @override
  Widget build(BuildContext context) {
    final currentPos = widget.driverLocation ?? _fallbackLocation;

    return Stack(
      children: [
        // --- LIVE MAP TILES ---
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: currentPos,
            initialZoom: 15.0,
            minZoom: 10.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.roadrobos.partner',
              tileProvider: CancellableNetworkTileProvider(),
            ),

            // High-Demand Surge Heatmap Zones
            CircleLayer(
              circles: _surgeZones.map((zone) {
                final color = zone['color'] as Color;
                return CircleMarker(
                  point: zone['location'] as LatLng,
                  radius: 700,
                  useRadiusInMeter: true,
                  color: color.withValues(alpha: 0.22),
                  borderColor: color.withValues(alpha: 0.8),
                  borderStrokeWidth: 2,
                );
              }).toList(),
            ),

            // Markers Layer (Surge tags + Driver GPS Pin)
            MarkerLayer(
              markers: [
                // Hotspot Surge Badges
                ..._surgeZones.map((zone) {
                  return Marker(
                    point: zone['location'] as LatLng,
                    width: 110,
                    height: 38,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (zone['color'] as Color).withValues(alpha: 0.8),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.flash5, size: 12, color: zone['color'] as Color),
                          const SizedBox(width: 4),
                          Text(
                            '${zone['surge']}',
                            style: TextStyle(
                              color: zone['color'] as Color,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${zone['name']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // Real-Time Driver Marker
                Marker(
                  point: currentPos,
                  width: 64,
                  height: 64,
                  child: AnimatedBuilder(
                    animation: _beaconController,
                    builder: (context, child) {
                      final scale = 1.0 + (_beaconController.value * 0.25);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Pulse Wave
                          Container(
                            width: 52 * scale,
                            height: 52 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (widget.isOnline
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B))
                                  .withValues(alpha: 0.3 * (1 - _beaconController.value)),
                            ),
                          ),
                          // Inner Core Marker
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: widget.isOnline
                                    ? [const Color(0xFF34D399), const Color(0xFF059669)]
                                    : [const Color(0xFFFBBF24), const Color(0xFFD97706)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.navigation_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),

        // --- FLOATING MAP CONTROLS ---
        // GPS Accuracy & Connectivity Pill
        Positioned(
          top: 14,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.isOnline
                        ? const Color(0xFF10B981)
                        : const Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'GPS High Accuracy • 5G',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Surge Zones Indicator
        Positioned(
          top: 14,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.flash5, size: 12, color: Color(0xFFF59E0B)),
                SizedBox(width: 4),
                Text(
                  'Surge Active',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Recenter to My Location Button
        Positioned(
          bottom: 20,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: 'cockpit_recenter',
            backgroundColor: const Color(0xFF1E1E24),
            foregroundColor: const Color(0xFFF59E0B),
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white24),
            ),
            onPressed: _recenter,
            child: const Icon(Icons.my_location_rounded, size: 20),
          ),
        ),
      ],
    );
  }
}
