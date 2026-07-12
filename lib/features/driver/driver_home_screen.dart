import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';


import '../../core/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/responsive_utils.dart';
import 'providers/driver_state_provider.dart';
import '../../features/delivery/driver_delivery_panel.dart';
import '../chat/providers/chat_providers.dart';
import '../../features/profile/user_provider.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  @override
  Widget build(BuildContext context) {
    final earningsAsync = ref.watch(earningsProvider);
    final isOnline = ref.watch(mapStateProvider).isOnline;
    final userAsync = ref.watch(userProvider);
    final driverName = userAsync.user?.name ?? 'Driver';
    final profileUrl = userAsync.user?.profilePic;

    ref.listen(rideRequestsProvider, (previous, next) {
      if (isOnline && next.hasValue && next.value != null && next.value!.isNotEmpty) {
        final currentRequests = next.value!;
        final previousRequests = previous?.value ?? [];
        if (currentRequests.isNotEmpty && (previousRequests.isEmpty || currentRequests.first.id != previousRequests.first.id)) {
          context.push('/driver-ride-request', extra: currentRequests.first);
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header (Profile & Notification)
                Padding(
                  padding: ResponsiveLayout.responsivePadding(context, vertical: 20),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context.pushReplacement('/driver-profile');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 2),
                                image: DecorationImage(
                                  image: NetworkImage(profileUrl ?? 'https://i.pravatar.cc/150?u=driver'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('GOOD MORNING', style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 10), fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1)),
                                Text(driverName, style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 17), fontWeight: FontWeight.w900, color: AppColors.deepNavy, letterSpacing: -0.5)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Consumer(
                        builder: (context, ref, child) {
                          final unreadCountAsync = ref.watch(unreadMessagesCountProvider);
                          final count = unreadCountAsync.value ?? 0;
                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                              },
                              child: Stack(
                                children: [
                                  const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.deepNavy, size: 24),
                                  if (count > 0)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: AppColors.dangerRed, shape: BoxShape.circle, border: Border(bottom: BorderSide(color: Colors.white, width: 2))),
                                        child: Text(
                                          count > 9 ? '9+' : count.toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle),
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You have no new notifications'), behavior: SnackBarBehavior.floating),
                            );
                          },
                          child: Stack(
                            children: [
                              const Icon(Iconsax.notification, color: AppColors.deepNavy, size: 24),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: AppColors.dangerRed, shape: BoxShape.circle, border: Border(bottom: BorderSide(color: Colors.white, width: 2))),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: ResponsiveLayout.responsivePadding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map Status Card
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            minHeight: ResponsiveLayout.responsiveHeight(context, 28),
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            image: const DecorationImage(
                              image: NetworkImage('https://static-maps.yandex.ru/1.x/?lang=en_US&ll=77.5946,12.9716&size=450,450&z=13&l=map&pt=77.5946,12.9716,pm2rdm'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.black.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.5)],
                              ),
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Container(width: 8, height: 8, decoration: BoxDecoration(color: isOnline ? AppColors.successGreen : AppColors.textMuted, shape: BoxShape.circle)),
                                    const SizedBox(width: 10),
                                    Text(isOnline ? 'Currently Online' : 'Currently Offline', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Go online to receive rides', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.mediumImpact();
                                    ref.read(mapStateProvider.notifier).toggleOnline();
                                  },
                                  child: Container(
                                    height: 56,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: isOnline ? AppColors.dangerRed : AppColors.successGreen,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [BoxShadow(color: (isOnline ? AppColors.dangerRed : AppColors.successGreen).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(isOnline ? Icons.power_settings_new_rounded : Iconsax.flash, color: Colors.white, size: 22),
                                          const SizedBox(width: 12),
                                          Text(
                                            isOnline ? 'GO OFFLINE' : 'GO ONLINE',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Earnings Card (Premium Redesign)
                        GestureDetector(
                          onTap: () => context.pushReplacement('/driver-earnings'),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF2563EB), Color(0xFF3B82F6), Color(0xFF1E40AF)],
                                stops: [0.0, 0.4, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.35), blurRadius: 25, offset: const Offset(0, 12))],
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  right: -20,
                                  bottom: -20,
                                  child: Opacity(
                                    opacity: 0.1,
                                    child: Transform.rotate(angle: -0.2, child: const Icon(Iconsax.wallet, size: 140, color: Colors.white)),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Earnings Today', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.2)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.trending_up_rounded, color: Colors.white, size: 12),
                                              SizedBox(width: 4),
                                              Text('+12%', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    earningsAsync.when(
                                      data: (earnings) => FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('₹', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))),
                                            const SizedBox(width: 4),
                                            Text('${earnings.todayEarnings.toInt()}', style: TextStyle(color: Colors.white, fontSize: ResponsiveLayout.responsiveFontSize(context, 48), fontWeight: FontWeight.w900, letterSpacing: -1.5)),
                                            const Padding(padding: EdgeInsets.only(bottom: 8.0), child: Text('.50', style: TextStyle(color: Colors.white70, fontSize: 22, fontWeight: FontWeight.w800))),
                                          ],
                                        ),
                                      ),
                                      loading: () => const CircularProgressIndicator(color: Colors.white),
                                      error: (e, _) => const Text('Error', style: TextStyle(color: Colors.white)),
                                    ),
                                    const SizedBox(height: 32),
                                    Row(
                                      children: [
                                        _buildMiniStat(Iconsax.car, '7', 'RIDES'),
                                        Container(width: 1, height: 24, color: Colors.white24, margin: const EdgeInsets.symmetric(horizontal: 20)),
                                        _buildMiniStat(Iconsax.timer_1, '4.2h', 'ONLINE'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1, end: 0),

                        const SizedBox(height: 32),

                        // Quick Actions
                        Text('Quick Actions', style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 18), fontWeight: FontWeight.w900, color: AppColors.deepNavy)),
                        const SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: ResponsiveLayout.isTablet(context) ? 4 : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.4,
                          children: [
                            _buildQuickAction('Incentives', Iconsax.gift, const Color(0xFFF97316), () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('My Incentives'),
                                  content: const Text('Complete 5 more rides today to earn an extra ₹500!'),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
                                ),
                              );
                            }),
                            _buildQuickAction('Wallet', Iconsax.wallet, const Color(0xFF8B5CF6), () {
                              context.push('/driver-bank-withdrawal');
                            }),
                            _buildQuickAction('Help Center', Iconsax.message_question, const Color(0xFF3B82F6), () {
                              context.push('/help-center');
                            }),
                            _buildQuickAction('High Demand', Iconsax.direct_up, const Color(0xFFEC4899), () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('High Demand Zones'),
                                  content: const Text('Hot Zones: Koramangala, Indiranagar.\nSurge pricing active (+1.5x). Head there to earn more.'),
                                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                                ),
                              );
                            }),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Recent Rides
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Recent Rides', style: TextStyle(fontSize: ResponsiveLayout.responsiveFontSize(context, 18), fontWeight: FontWeight.w900, color: AppColors.deepNavy)),
                            TextButton(
                              onPressed: () => context.pushReplacement('/driver-rides'),
                              child: const Text('View All', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800, fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRecentRide('Indiranagar to Koramangala', 'Today, 10:23 AM', '₹185.00', 'Completed'),
                        const SizedBox(height: 100),
                      ],
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
                  ),
                ),
              ],
            ),

            // ── Delivery request / active delivery panel ──
            if (isOnline)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: DriverDeliveryPanel(),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        items: const [
          NavItemData(icon: Iconsax.home, activeIcon: Iconsax.home5, label: 'Home'),
          NavItemData(icon: Iconsax.wallet, activeIcon: Iconsax.wallet5, label: 'Earnings'),
          NavItemData(icon: Iconsax.star, activeIcon: Iconsax.star5, label: 'Ratings'),
          NavItemData(icon: Iconsax.user, activeIcon: Iconsax.user, label: 'Account'),
        ],
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) context.pushReplacement('/driver-earnings');
          if (index == 2) context.pushReplacement('/driver-rides');
          if (index == 3) context.pushReplacement('/driver-profile');
        },
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 20),
            ),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRide(String title, String time, String amount, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle),
            child: const Icon(Iconsax.car, color: AppColors.deepNavy, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
              Text(time, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(amount, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.deepNavy, fontSize: 14)),
            Text(status, style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w800)),
          ]),
        ],
      ),
    );
  }
}
