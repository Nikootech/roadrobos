import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

/// Driver Rides Screen matching Figma Screen [21]: My Rides History (Driver View)
class DriverRidesScreen extends StatelessWidget {
  const DriverRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgLightGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: const Text(
            'My Rides',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.deepNavy,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.filter, color: AppColors.textPrimary),
              onPressed: () => HapticFeedback.lightImpact(),
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgLightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.deepNavy,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Completed Tab
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildPremiumRideCard(
                  context,
                  passenger: 'Rahul Sharma',
                  date: 'Today, 10:30 AM',
                  fare: '₹145.50',
                  status: 'COMPLETED',
                  statusColor: AppColors.successGreen,
                  pickup: 'Vidyut Nagar, Delhi',
                  drop: 'Indira Gandhi Int\'l Airport',
                ),
                _buildPremiumRideCard(
                  context,
                  passenger: 'Priya Verma',
                  date: 'Yesterday, 06:15 PM',
                  fare: '₹280.00',
                  status: 'COMPLETED',
                  statusColor: AppColors.successGreen,
                  pickup: 'Sector 15, Gurgaon',
                  drop: 'Cyber City, Gurgaon',
                ),
                _buildPremiumRideCard(
                  context,
                  passenger: 'Amit Singh',
                  date: '24 Oct, 02:45 PM',
                  fare: '₹110.00',
                  status: 'COMPLETED',
                  statusColor: AppColors.successGreen,
                  pickup: 'Rajouri Garden',
                  drop: 'Connaught Place',
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),

            // Cancelled Tab
            ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildPremiumRideCard(
                  context,
                  passenger: 'Sunil Kumar',
                  date: '23 Oct, 11:20 AM',
                  fare: '₹0.00',
                  status: 'CANCELLED',
                  statusColor: AppColors.dangerRed,
                  pickup: 'Noida City Center',
                  drop: 'Okhla Phase 3',
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 2,
          items: const [
            NavItemData(icon: Iconsax.home, activeIcon: Iconsax.home5, label: 'Home'),
            NavItemData(icon: Iconsax.wallet, activeIcon: Iconsax.wallet5, label: 'Earnings'),
            NavItemData(icon: Iconsax.star, activeIcon: Iconsax.star5, label: 'Ratings'),
            NavItemData(icon: Iconsax.user, activeIcon: Iconsax.user, label: 'Account'),
          ],
          onTap: (index) {
            if (index == 0) context.pushReplacement('/driver-home');
            if (index == 1) context.pushReplacement('/driver-earnings');
            if (index == 2) return;
            if (index == 3) context.pushReplacement('/driver-profile');
          },
        ),
      ),
    );
  }

  Widget _buildPremiumRideCard(
    BuildContext context, {
    required String passenger,
    required String date,
    required String fare,
    required String status,
    required Color statusColor,
    required String pickup,
    required String drop,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            // Could navigate to details here
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row: Avatar, Info, Fare
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Iconsax.user, color: AppColors.primaryBlue, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            passenger,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      fare,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.bgLightGrey, height: 1),
                const SizedBox(height: 16),
                // Trip Trail (Figma Style)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.circle, color: AppColors.primaryBlue, size: 8),
                        Container(width: 1.5, height: 28, color: AppColors.border.withValues(alpha: 0.5)),
                        const Icon(Icons.location_on_rounded, color: AppColors.dangerRed, size: 14),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup,
                            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            drop,
                            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: statusColor.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }
}
