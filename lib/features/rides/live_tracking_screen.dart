import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import 'taxi_provider.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  LatLng? _captainLocation;
  double _simulationProgress = 0.0;
  late final AnimationController _simController;

  @override
  void initState() {
    super.initState();
    _simController = AnimationController(vsync: this, duration: 15.seconds);
    _simController.addListener(() {
      setState(() {
        _simulationProgress = _simController.value;
        _updateCaptainLocation();
      });
    });

    // Simulate finding a driver
    Future.delayed(2.seconds, () {
      if (mounted) {
        ref.read(taxiProvider.notifier).updateStatus(RideStatus.headingToPickup);
        _startSimulation();
      }
    });
  }

  void _startSimulation() {
    final taxiState = ref.read(taxiProvider);
    if (taxiState.pickupLocation != null) {
      // Start captain 0.005 away
      _captainLocation = LatLng(
        taxiState.pickupLocation!.latitude + 0.005,
        taxiState.pickupLocation!.longitude + 0.005,
      );
      _simController.forward();
    }
  }

  void _updateCaptainLocation() {
    final taxiState = ref.read(taxiProvider);
    if (taxiState.pickupLocation != null && _captainLocation != null) {
      final startLat = taxiState.pickupLocation!.latitude + 0.005;
      final startLng = taxiState.pickupLocation!.longitude + 0.005;
      
      _captainLocation = LatLng(
        startLat + (taxiState.pickupLocation!.latitude - startLat) * _simulationProgress,
        startLng + (taxiState.pickupLocation!.longitude - startLng) * _simulationProgress,
      );
    }
  }

  @override
  void dispose() {
    _simController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiProvider);
    final isSearching = taxiState.status == RideStatus.searching;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Live Map
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              showLiveIndicator: true,
              captainLocation: _captainLocation,
            ),
          ),

          // 2. Searching Overlay (Rapido Style)
          if (isSearching)
            Container(
              color: Colors.white.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        color: AppColors.primaryBlue,
                        backgroundColor: AppColors.bgLightAlt,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Finding Captain...',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryNavy),
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 12),
                    Text(
                      'Requesting nearby drivers for you',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(),

          // 3. Header Status (Pill style)
          if (!isSearching)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              child: _buildTrackingStatusPill(taxiState),
            ),

          // 4. Driver Details Card (Bottom)
          if (!isSearching)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildDriverBottomCard(context, taxiState),
            ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),

          // 5. Back/Floating Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStatusPill(TaxiState state) {
    String statusStr = "Captain is 2 mins away";
    if (state.status == RideStatus.headingToDropoff) statusStr = "Arriving in 12 mins";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flash_on, color: AppColors.primaryBlue, size: 18),
          const SizedBox(width: 12),
          Text(
            statusStr,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverBottomCard(BuildContext context, TaxiState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=captain'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sohan Kumar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.primaryBlue, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '4.9 • ${state.selectedRide?.name ?? "Vehicle"}', 
                          style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      'KA 01 EB 4567',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildCircleAction(Icons.chat_bubble, Colors.blue),
                  const SizedBox(width: 12),
                  _buildCircleAction(Icons.call, Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('OTP to Start', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
                  const Text('4582', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
                ],
              ),
              ElevatedButton(
                onPressed: () => context.push('/taxi/complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bgLightAlt,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Finish trip', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
