import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import 'providers/driver_state_provider.dart';
import 'widgets/ride_request_overlay.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {

  @override
  Widget build(BuildContext context) {
    final earnings = ref.watch(earningsProvider);
    final isOnline = ref.watch(mapStateProvider).isOnline;
    final rideRequests = ref.watch(rideRequestsProvider);

    return Scaffold(
      extendBody: true, // For bottom nav bar to float over map
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 85% screen = LiveMapWidget
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              captainLocation: const LatLng(12.9716, 77.5946),
            ),
          ),
          
          // Offline overlay or Incoming Ride Cards
          if (!isOnline)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.7),
                child: Center(
                  child: const GlassCard(
                    blur: 20,
                    opacity: 0.1,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text('You are offline.\nGo online to start receiving rides', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                  ).animate().fadeIn().scale(),
                ),
              ),
            ),
            
          // Gradient to fade map at top
          Positioned(
            top: 0, left: 0, right: 0, height: 140,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent]
                )
              ),
            ),
          ),

          // Top: Earnings & Bonus
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GlassCard(
                blur: 20,
                opacity: 0.85,
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Earnings Today', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                          FittedBox(fit: BoxFit.scaleDown, child: Text('₹${earnings.todayEarnings.toInt()}', style: const TextStyle(color: AppColors.deepNavy, fontSize: 24, fontWeight: FontWeight.w900))),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: AppColors.border),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Bonus Target', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                          FittedBox(fit: BoxFit.scaleDown, child: Text('₹${(earnings.bonusTarget - earnings.bonusAchieved).toInt()} left', style: const TextStyle(color: AppColors.warningAmber, fontSize: 18, fontWeight: FontWeight.w800))),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.2).fadeIn(),
            ),
          ),
          ),

          // Online / Offline Toggle
          Positioned(
            top: 130, right: 16,
            child: GestureDetector(
              onTap: () => ref.read(mapStateProvider.notifier).toggleOnline(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.dangerRed : AppColors.successGreen,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    Icon(isOnline ? Icons.power_settings_new_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(isOnline ? 'GO OFFLINE' : 'GO ONLINE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ).animate(target: isOnline ? 1 : 0).shimmer(),
            ),
          ),



          if (isOnline && rideRequests.isNotEmpty)
            RideRequestOverlay(
              request: rideRequests.first,
              onAccept: () {
                ref.read(rideRequestsProvider.notifier).acceptRequest(rideRequests.first.id);
                context.push('/driver-assigned'); // Or start active ride
              },
              onReject: () {
                ref.read(rideRequestsProvider.notifier).rejectRequest(rideRequests.first.id);
              },
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        items: const [
          NavItemData(icon: Iconsax.home, activeIcon: Iconsax.home5, label: 'Home'),
          NavItemData(icon: Iconsax.car, activeIcon: Iconsax.car5, label: 'Rides'),
          NavItemData(icon: Iconsax.wallet, activeIcon: Iconsax.wallet5, label: 'Earnings'),
          NavItemData(icon: Iconsax.user, activeIcon: Iconsax.user, label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) context.pushReplacement('/driver-rides');
          if (index == 2) context.pushReplacement('/driver-earnings');
          if (index == 3) context.pushReplacement('/driver-profile');
        },
      ),
    );
  }
}
