import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../shared/widgets/live_map_widget.dart';

class MapPickerScreen extends ConsumerStatefulWidget {
  const MapPickerScreen({super.key});

  @override
  ConsumerState<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends ConsumerState<MapPickerScreen> {
  String _currentAddress = "Searching for address...";
  LatLng _lastSelectedLocation = const LatLng(12.9716, 77.5946); // Default

  @override
  void initState() {
    super.initState();
    // Simulate reverse geocoding
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _currentAddress = "MG Road, Bengaluru, Karnataka 560001";
          _lastSelectedLocation = const LatLng(12.9716, 77.5946);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              showLiveIndicator: false,
              showBackgroundMarkers: false,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _lastSelectedLocation = camera.center;
                    // Simple mock geocoding: use coordinates as address if needed,
                    // or just keep a generic "Selected Location" text that updates.
                    _currentAddress = "Location: ${camera.center.latitude.toStringAsFixed(4)}, ${camera.center.longitude.toStringAsFixed(4)}";
                  });
                }
              },
            ),
          ),

          // 2. Central Pin
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 35), // Offset for pin point
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Select this point',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.location_on, color: Colors.black, size: 40),
                ],
              ),
            ),
          ),

          // 3. Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
              ),
            ),
          ),

          // 4. Bottom Panel
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1F2937))),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Iconsax.location5, color: Color(0xFF22C55E), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _currentAddress,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => context.pop({
                        'address': _currentAddress,
                        'location': _lastSelectedLocation,
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Confirm Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
