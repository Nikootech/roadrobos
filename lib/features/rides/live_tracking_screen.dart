import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../providers/taxi_provider.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiProvider);
    final isSearching = taxiState.status == RideStatus.booked;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Live Map - With focused tracking
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              showLiveIndicator: true,
              roadroboLocation: taxiState.roadroboLocation,
              isTracking: !isSearching,
              pickupLocation: taxiState.pickupLocation,
            ),
          ),

          // 2. Searching Overlay (Rapido Style)
          if (isSearching)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 120,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 8,
                            color: AppColors.primaryBlue,
                            backgroundColor: Color(0xFFF3F4F6),
                          ),
                          Icon(Icons.directions_bike_rounded, size: 40, color: AppColors.primaryBlue),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Finding Your Roadrobo',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryNavy),
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'This might take a minute...',
                        style: TextStyle(color: AppColors.primaryBlueDark, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2.seconds),
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
            ).animate().fadeIn().slideY(begin: -0.5, end: 0),

          // 4. Driver Details Card (Bottom)
          if (!isSearching)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildDriverBottomCard(context, taxiState),
            ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),
          
          // 5. Back Button (only when not searching or for canceling)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            child: GestureDetector(
              onTap: () {
                ref.read(taxiProvider.notifier).cancelRide();
                context.go('/main/home');
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                child: const Icon(Icons.close, color: Colors.black, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStatusPill(TaxiState state) {
    String statusStr = "Roadrobo is 2 mins away";
    if (state.status == RideStatus.atPickup) {
      statusStr = "Roadrobo has arrived!";
    } else if (state.status == RideStatus.headingToDropoff) {
      statusStr = "Heading to destination";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: state.status == RideStatus.atPickup ? Colors.green : AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.status == RideStatus.atPickup ? Icons.check_circle : Icons.flash_on, 
            color: state.status == RideStatus.atPickup ? Colors.white : AppColors.primaryBlue, 
            size: 18
          ).animate(onPlay: (c) => c.repeat()).shimmer(),
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          
          Row(
            children: [
              // Roadrobo Profile Image with Vehicle Badge
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFF3F4F6),
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=roadrobo123'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                      child: Image.asset(state.selectedOption?.assetPath ?? 'assets/icons/car.png', width: 16, height: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.roadroboName ?? 'Roadrobo', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(state.selectedOption?.title ?? 'Vehicle', style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                      child: const Text('KA 01 EB 4567', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildCircleAction(Icons.chat_bubble_rounded, AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  _buildCircleAction(Icons.call_rounded, Colors.green),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // OTP / Action Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (state.status == RideStatus.atPickup) ...[
                   const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VERIFY OTP', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('4582', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.green)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => ref.read(taxiProvider.notifier).startTrip(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Start Trip', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                  ),
                ] else if (state.status == RideStatus.headingToDropoff) ...[
                   Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HEADING TO', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(state.dropoffAddress ?? 'Destination', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryNavy)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => context.push('/taxi/complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Finish Trip', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ] else ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('OTP TO START TRIP', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(state.otp ?? '4582', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.primaryNavy, letterSpacing: 4)),
                    ],
                  ),
                  Opacity(
                    opacity: 0.5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                      child: const Text('Waiting for Arrival', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ],
            ),
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
