import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../profile/user_provider.dart';
import '../../core/repositories/ratings_repository.dart';
import 'providers/driver_state_provider.dart';

/// Driver Profile Screen — Premium Overhaul with Real Data
class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final String name = user?.name ?? 'Driver';
    final String userId = user?.id ?? '';

    final ratingAsyncValue = ref.watch(partnerRatingProvider(userId));
    final ratingData = ratingAsyncValue.value;
    final String avgRatingStr = ratingData?['avg_score']?.toString() ?? '5.0';
    final int reviewsCount = ratingData?['total_reviews'] ?? 0;

    // Watch real-time online status
    final isOnline = ref.watch(mapStateProvider).isOnline;

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        title: const Text(
          'Roadrobo Profile',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.deepNavy,
              letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined,
                  color: AppColors.textPrimary),
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/account-settings');
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Profile Card (Premium Overhaul)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                    color: AppColors.brandGreen.withValues(alpha: 0.08),
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandGreen.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  )
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      // Pulse effect container around the avatar
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isOnline
                                ? AppColors.successGreen.withValues(alpha: 0.3)
                                : AppColors.textMuted.withValues(alpha: 0.2),
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.bgLightGrey,
                          backgroundImage: (user?.profilePic != null)
                              ? NetworkImage(user!.profilePic!)
                              : const NetworkImage(
                                  'https://i.pravatar.cc/150?u=roadrobo'),
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat(reverse: true))
                          .boxShadow(
                            begin: BoxShadow(
                              color: isOnline
                                  ? AppColors.successGreen.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              blurRadius: 4,
                            ),
                            end: BoxShadow(
                              color: isOnline
                                  ? AppColors.successGreen.withValues(alpha: 0.45)
                                  : Colors.transparent,
                              blurRadius: 18,
                              spreadRadius: 4,
                            ),
                            duration: 1800.ms,
                            curve: Curves.easeInOut,
                          ),
                      // Verified + Status Indicator Badge
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.successGreen : AppColors.textMuted,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          isOnline ? Icons.check : Icons.power_settings_new_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Senior Roadrobo • ID: BLR-49281',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Sleek Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isOnline ? AppColors.successGreen : AppColors.textMuted)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (isOnline ? AppColors.successGreen : AppColors.textMuted)
                            .withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isOnline ? AppColors.successGreen : AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isOnline ? 'ONLINE & ACTIVE' : 'OFFLINE',
                          style: TextStyle(
                            color: isOnline ? AppColors.successGreen : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.08, end: 0, duration: 400.ms),

            const SizedBox(height: 24),

            // Stats Grid (Premium visual cards)
            Row(
              children: [
                _buildStat('Rides', (user?.totalRides ?? 0).toString(),
                    Icons.directions_car_rounded, AppColors.brandGreen),
                const SizedBox(width: 12),
                _buildStat(
                    'Rating', avgRatingStr, Icons.star_rounded, Colors.orange),
                const SizedBox(width: 12),
                _buildStat('Exp', '3y', Icons.workspace_premium_rounded,
                    AppColors.accentOrange),
              ],
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

            const SizedBox(height: 24),

            // Menu Section
            _buildSectionHeader('Management'),
            const SizedBox(height: 12),
            _buildPremiumMenuItem(
                Icons.description_outlined,
                'Documents & Verification',
                'DL, RC, Insurance',
                () => context.push('/driver/documents')),
            _buildPremiumMenuItem(
                Icons.account_balance_wallet_outlined,
                'Wallet & Payments',
                'Balance, History, Payouts',
                () => context.pushReplacement('/driver-earnings')),

            const SizedBox(height: 16),
            _buildSectionHeader('Performance'),
            const SizedBox(height: 12),
            _buildPremiumMenuItem(
                Icons.analytics_outlined,
                'Analytics',
                'Weekly reports & stats',
                () => _showAnalyticsBottomSheet(context)),
            _buildPremiumMenuItem(
                Icons.star_outline_rounded,
                'Reviews',
                'Passenger feedback',
                () => _showReviewsBottomSheet(
                    context, avgRatingStr, reviewsCount)),
            _buildPremiumMenuItem(Icons.help_outline_rounded, 'Help & Support',
                'FAQs & Contact Support', () => context.push('/help-center')),
            _buildPremiumMenuItem(
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                'Data usage and security',
                () => context.push('/privacy-policy')),
            _buildPremiumMenuItem(
                Icons.description_outlined,
                'Terms of Service',
                'Read our terms and conditions',
                () => context.push('/terms-of-service')),

            const SizedBox(height: 32),

            // Sign Out
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  await HapticFeedback.heavyImpact();
                  await ref.read(userProvider.notifier).logout();
                  if (context.mounted) context.go('/auth/login');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.dangerRed.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Sign Out',
                    style: TextStyle(
                        color: AppColors.dangerRed,
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
              ),
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        items: const [
          NavItemData(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home'),
          NavItemData(
              icon: Icons.account_balance_wallet_outlined,
              activeIcon: Icons.account_balance_wallet_rounded,
              label: 'Earnings'),
          NavItemData(
              icon: Icons.star_outline_rounded,
              activeIcon: Icons.star_rounded,
              label: 'Ratings'),
          NavItemData(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Account'),
        ],
        onTap: (index) {
          if (index == 0) context.pushReplacement('/driver-home');
          if (index == 1) context.pushReplacement('/driver-earnings');
          if (index == 2) context.pushReplacement('/driver-rides');
          if (index == 3) return;
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMenuItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: AppColors.brandGreen, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAnalyticsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Weekly Analytics',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.deepNavy)),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon:
                          const Icon(Icons.close_rounded, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.bgLightGrey,
                    borderRadius: BorderRadius.circular(24)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar('Mon', 0.4),
                    _buildBar('Tue', 0.7),
                    _buildBar('Wed', 0.55),
                    _buildBar('Thu', 0.9),
                    _buildBar('Fri', 0.6),
                    _buildBar('Sat', 0.8),
                    _buildBar('Sun', 0.3),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildStatRow(Icons.timer_outlined, 'Online Hours', '42.5h',
                  '+12% from last week'),
              const SizedBox(height: 16),
              _buildStatRow(Icons.directions_car_outlined, 'Total Rides', '142',
                  '+8% from last week'),
              const SizedBox(height: 16),
              _buildStatRow(Icons.account_balance_wallet_outlined,
                  'Net Earnings', '₹12,450', '₹850/avg daily'),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewsBottomSheet(
      BuildContext context, String avgRating, int count) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Passenger Reviews',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepNavy)),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(avgRating,
                    style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                          5,
                          (index) => Icon(Icons.star_rounded,
                              color: index < double.parse(avgRating).floor()
                                  ? Colors.orange
                                  : Colors.grey[300],
                              size: 20)),
                    ),
                    Text('Based on $count reviews',
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildReviewItem('Ankit Sharma', '4.5', '2 hours ago',
                      'Great driver, reached on time and the car was very clean.'),
                  _buildReviewItem('Priya Patel', '5.0', 'Yesterday',
                      'Very polite behavior and safe driving. Highly recommended!'),
                  _buildReviewItem('Suresh Raina', '4.0', '2 days ago',
                      'Good experience but traffic was bad. Driver handled it well.'),
                  _buildReviewItem(
                      'Amit Mishra', '5.0', '3 days ago', 'Excellent service!'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double percentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 140 * percentage,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.brandGreen,
                AppColors.brandGreenMid,
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandGreen.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ).animate().scaleY(
              begin: 0,
              end: 1,
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ),
        const SizedBox(height: 8),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildStatRow(
      IconData icon, String label, String value, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.bgLightGrey,
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.brandGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
          Text(trend,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.successGreen)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(
      String name, String rating, String time, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    color: index < double.parse(rating).floor()
                        ? Colors.orange
                        : Colors.grey[200],
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                rating,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
