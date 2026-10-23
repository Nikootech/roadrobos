import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

class DemandHub {
  final String name;
  final LatLng location;
  final double surgeMultiplier;
  final int activeOrders;
  final Color color;

  const DemandHub({
    required this.name,
    required this.location,
    required this.surgeMultiplier,
    required this.activeOrders,
    required this.color,
  });
}

/// Rapido-inspired Demand Heatmap screen showing live commuter demand hubs and surge clusters.
class DemandHeatmapScreen extends StatefulWidget {
  const DemandHeatmapScreen({super.key});

  @override
  State<DemandHeatmapScreen> createState() => _DemandHeatmapScreenState();
}

class _DemandHeatmapScreenState extends State<DemandHeatmapScreen> {
  final MapController _mapController = MapController();
  Timer? _refreshTimer;
  DateTime _lastUpdated = DateTime.now();
  bool _isRefreshing = false;

  // Curated demand hotspots (sample cities: Bengaluru / Delhi NCR / Mumbai hubs)
  final List<DemandHub> _hubs = const [
    DemandHub(
      name: 'Central Metro Transit',
      location: LatLng(12.9716, 77.5946),
      surgeMultiplier: 1.6,
      activeOrders: 42,
      color: Color(0xFFDC2626), // High surge Red
    ),
    DemandHub(
      name: 'Cyber City Tech Park',
      location: LatLng(12.9850, 77.6050),
      surgeMultiplier: 1.4,
      activeOrders: 28,
      color: Color(0xFFEA580C), // Moderate surge Orange
    ),
    DemandHub(
      name: 'Railway Junction',
      location: LatLng(12.9780, 77.5700),
      surgeMultiplier: 1.3,
      activeOrders: 19,
      color: Color(0xFFF59E0B), // Mild surge Amber
    ),
    DemandHub(
      name: 'Electronic City Toll',
      location: LatLng(12.8450, 77.6650),
      surgeMultiplier: 1.5,
      activeOrders: 35,
      color: Color(0xFFDC2626),
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-refresh every 5 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _refreshDemandData();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _refreshDemandData() {
    setState(() {
      _isRefreshing = true;
      _lastUpdated = DateTime.now();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Live Demand Hubs',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _refreshDemandData();
            },
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Iconsax.refresh, color: Color(0xFF0F172A)),
            tooltip: 'Refresh Demand',
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap Tile Layer
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(12.9716, 77.5946),
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.roadrobos.partner',
                tileProvider: CancellableNetworkTileProvider(),
              ),

              // Circle Surge Overlays (Heatmap representation)
              CircleLayer(
                circles: _hubs.map((hub) {
                  return CircleMarker(
                    point: hub.location,
                    radius: 800,
                    useRadiusInMeter: true,
                    color: hub.color.withValues(alpha: 0.22),
                    borderColor: hub.color.withValues(alpha: 0.8),
                    borderStrokeWidth: 2.0,
                  );
                }).toList(),
              ),

              // Hub Markers
              MarkerLayer(
                markers: _hubs.map((hub) {
                  return Marker(
                    point: hub.location,
                    width: 140,
                    height: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hub.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: hub.color.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.flash,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                '${hub.surgeMultiplier}x Surge',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hub.name,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            backgroundColor: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Bottom Legend & Live Status Strip
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.radar_rounded,
                          size: 18, color: Color(0xFFEA580C)),
                      const SizedBox(width: 8),
                      Text(
                        'High Booking Demand Areas',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Updated ${_lastUpdated.minute}:${_lastUpdated.second.toString().padLeft(2, '0')}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSurgeTag('1.1x - 1.3x', const Color(0xFFF59E0B)),
                      _buildSurgeTag('1.4x - 1.5x', const Color(0xFFEA580C)),
                      _buildSurgeTag('1.6x+ Peak', const Color(0xFFDC2626)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurgeTag(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}
