import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';

import 'providers/driver_state_provider.dart';
import '../chat/providers/chat_providers.dart';
import '../../features/profile/user_provider.dart';
import 'widgets/instant_cashout_sheet.dart';
import 'widgets/rapido_slide_to_online.dart';
import 'widgets/rapido_map_cockpit.dart';
import 'widgets/rapido_incentive_card.dart';
import '../../core/repositories/ratings_repository.dart';

/// Rapido Captain Cockpit Home Screen
/// Full-screen high-contrast dark cockpit with live GPS map,
/// swipe-to-online switch, live address banner, and incentive quests.
class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final earningsAsync = ref.watch(earningsProvider);
    final mapState = ref.watch(mapStateProvider);
    final isOnline = mapState.isOnline;
    final userAsync = ref.watch(userProvider);
    final driverName = userAsync.user?.name ?? 'Captain';
    final profileUrl = userAsync.user?.profilePic;
    final currentDriverAsync = ref.watch(currentDriverProvider);
    final ratingAsync = ref.watch(partnerRatingProvider(userAsync.user?.id ?? ''));
    final avgRating = ratingAsync.value?['avg_score']?.toString() ?? '5.0';

    final driver = currentDriverAsync.value;
    final vehicleDisplay = (driver != null &&
            driver.vehicleModel.isNotEmpty &&
            driver.vehiclePlate.isNotEmpty)
        ? '${driver.vehicleModel} • ${driver.vehiclePlate}'
        : (driver != null && driver.vehicleModel.isNotEmpty
            ? driver.vehicleModel
            : (driver != null && driver.vehiclePlate.isNotEmpty
                ? driver.vehiclePlate
                : 'Vehicle Pending Verification'));

    // Listen for incoming ride dispatch requests in real-time
    ref.listen(rideRequestsProvider, (previous, next) {
      if (isOnline &&
          next.hasValue &&
          next.value != null &&
          next.value!.isNotEmpty) {
        final currentRequests = next.value!;
        final previousRequests = previous?.value ?? [];
        if (currentRequests.isNotEmpty &&
            (previousRequests.isEmpty ||
                currentRequests.first.id != previousRequests.first.id)) {
          context.push('/driver-ride-request', extra: currentRequests.first);
        }
      }
    });

    final driverLocation = LatLng(mapState.lat, mapState.lng);

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Rapido Dark Cockpit Canvas
      body: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // 1. TOP CAPTAIN HEADER BAR
            // ==========================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF1E1E24),
              child: Row(
                children: [
                  // Profile Avatar + Gold Star Badge
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/driver-profile');
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF2A2A32),
                            border: Border.all(
                              color: const Color(0xFFF59E0B),
                              width: 2,
                            ),
                            image: (profileUrl != null && profileUrl.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(profileUrl),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (profileUrl == null || profileUrl.isEmpty)
                              ? Center(
                                  child: Text(
                                    driverName.isNotEmpty
                                        ? driverName[0].toUpperCase()
                                        : 'C',
                                    style: const TextStyle(
                                      color: Color(0xFFF59E0B),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 10, color: Color(0xFF121212)),
                                Text(
                                  avgRating,
                                  style: const TextStyle(
                                    color: Color(0xFF121212),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Pilot Name & Vehicle Class
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                driverName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'CAPTAIN',
                                style: TextStyle(
                                  color: Color(0xFFF59E0B),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vehicleDisplay,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Today's Earnings Quick Pill
                  earningsAsync.maybeWhen(
                    data: (earnings) => GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/driver-earnings');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              '₹',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${earnings.todayEarnings.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${earnings.totalRides})',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),

                  const SizedBox(width: 8),

                  // Unread Messages / Chat
                  Consumer(
                    builder: (context, ref, child) {
                      final count =
                          ref.watch(unreadMessagesCountProvider).value ?? 0;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.white12,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            children: [
                              const Icon(Icons.chat_bubble_outline_rounded,
                                  color: Colors.white, size: 18),
                              if (count > 0)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ==========================================
            // 2. LIVE MAP COCKPIT CANVAS
            // ==========================================
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  RapidoMapCockpit(
                    driverLocation: driverLocation,
                    isOnline: isOnline,
                    onRecenter: () {
                      ref
                          .read(mapStateProvider.notifier)
                          .fetchDeviceLocation();
                    },
                  ),

                  // Prominent Slide-to-Online Widget Anchored Floating Over Map
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: RapidoSlideToOnline(
                      isOnline: isOnline,
                      presentAddress: mapState.currentAddress,
                      isFetchingAddress: mapState.isFetchingAddress,
                      onToggle: (targetOnline) {
                        ref
                            .read(mapStateProvider.notifier)
                            .toggleOnline();
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // 3. EXPANDABLE CAPTAIN DASHBOARD & QUESTS
            // ==========================================
            Expanded(
              flex: 3,
              child: Container(
                color: const Color(0xFF121212),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Present Address Live Beacon Bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isOnline
                                ? const Color(0xFF10B981).withValues(alpha: 0.4)
                                : Colors.white12,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: isOnline
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isOnline
                                    ? (mapState.currentAddress.isNotEmpty
                                        ? mapState.currentAddress
                                        : 'Detecting GPS location...')
                                    : 'Go online to start receiving rides',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(mapStateProvider.notifier)
                                    .fetchDeviceLocation();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white12,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.refresh_rounded,
                                    size: 14, color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Quick Stats Cockpit Row (Gross, Online Time, Acceptance)
                      earningsAsync.maybeWhen(
                        data: (earnings) => Row(
                          children: [
                            Expanded(
                              child: _buildCockpitStatCard(
                                title: 'TODAY GROSS',
                                value: '₹${earnings.todayEarnings.toInt()}',
                                subtitle: '${earnings.totalRides} rides',
                                valueColor: const Color(0xFF10B981),
                                icon: Iconsax.wallet_3,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildCockpitStatCard(
                                title: 'ONLINE HOURS',
                                value: earnings.onlineTime,
                                subtitle: isOnline ? 'Active' : 'Paused',
                                valueColor: const Color(0xFFF59E0B),
                                icon: Iconsax.clock,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildCockpitStatCard(
                                title: 'ACCEPTANCE',
                                value: earnings.acceptanceRate,
                                subtitle: 'Top Captain',
                                valueColor: Colors.white,
                                icon: Iconsax.like_1,
                              ),
                            ),
                          ],
                        ),
                        orElse: () => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 14),

                      // Rapido Incentive Quest Milestone Card
                      RapidoIncentiveCard(
                        completedTrips: earningsAsync.value?.totalRides ?? 0,
                      ),

                      const SizedBox(height: 14),

                      // Rapido Quick Actions Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionBtn(
                              title: 'Instant Cashout',
                              subtitle: 'UPI Transfer',
                              icon: Iconsax.money_send,
                              iconColor: const Color(0xFF10B981),
                              onTap: () {
                                final balance =
                                    earningsAsync.value?.todayEarnings ?? 0.0;
                                InstantCashoutSheet.show(
                                  context,
                                  availableBalance: balance,
                                  defaultUpiId: (userAsync.user?.phone != null &&
                                          userAsync.user!.phone.isNotEmpty)
                                      ? '${userAsync.user!.phone}@upi'
                                      : 'Primary Verified Account',
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickActionBtn(
                              title: 'Surge Heatmap',
                              subtitle: 'View Hotspots',
                              icon: Iconsax.map_1,
                              iconColor: const Color(0xFFF59E0B),
                              onTap: () {
                                context.push('/demand-map');
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildQuickActionBtn(
                              title: 'Safety SOS',
                              subtitle: '24x7 Support',
                              icon: Icons.shield_rounded,
                              iconColor: const Color(0xFFEF4444),
                              onTap: () {
                                context.push('/sos-setup');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCockpitStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color valueColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 12, color: Colors.white38),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionBtn({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
