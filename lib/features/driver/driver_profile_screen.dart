import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../profile/user_provider.dart';

/// Driver Profile Screen — Premium Overhaul with Real Data
class DriverProfileScreen extends ConsumerWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final String name = user?.name ?? 'Driver';

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        title: const Text(
          'Roadrobo Profile',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.deepNavy, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
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
            // Profile Card (Premium)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                   Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: AppColors.bgLightGrey,
                          backgroundImage: (user?.profilePic != null)
                              ? NetworkImage(user!.profilePic!)
                              : const NetworkImage('https://i.pravatar.cc/150?u=roadrobo'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.successGreen, shape: BoxShape.circle),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  const Text('Senior Roadrobo • ID: BLR-49281', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.successGreen, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('ONLINE & ACTIVE', style: TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 24),
            
            // Stats Grid
            Row(
              children: [
                _buildStat('Rides', (user?.totalRides ?? 0).toString(), Icons.directions_car_rounded, AppColors.primaryBlue),
                const SizedBox(width: 12),
                _buildStat('Rating', '4.8', Icons.star_rounded, Colors.orange),
                const SizedBox(width: 12),
                _buildStat('Exp', '3y', Icons.workspace_premium_rounded, AppColors.successGreen),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),
            
            // Menu Section
            _buildSectionHeader('Management'),
            const SizedBox(height: 12),
            _buildPremiumMenuItem(Icons.description_outlined, 'Documents & Verification', 'DL, RC, Insurance', () => context.push('/driver/documents')),
            _buildPremiumMenuItem(Icons.account_balance_wallet_outlined, 'Wallet & Payments', 'Balance, History, Payouts', () => context.pushReplacement('/driver-earnings')),
            
            const SizedBox(height: 16),
            _buildSectionHeader('Performance'),
            const SizedBox(height: 12),
            _buildPremiumMenuItem(Icons.analytics_outlined, 'Analytics', 'Weekly reports & stats', () => _showAnalyticsBottomSheet(context)),
            _buildPremiumMenuItem(Icons.star_outline_rounded, 'Reviews', 'Passenger feedback', () => _showReviewsBottomSheet(context)),
            _buildPremiumMenuItem(Icons.help_outline_rounded, 'Help & Support', 'FAQs & Contact Support', () => context.push('/help-center')),
            
            const SizedBox(height: 32),
            
            // Sign Out
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  HapticFeedback.heavyImpact();
                  await ref.read(userProvider.notifier).logout();
                  if (context.mounted) context.go('/auth/login');
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: AppColors.dangerRed.withOpacity(0.08),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Sign Out', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w900, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        items: const [
          NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
          NavItemData(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet_rounded, label: 'Earnings'),
          NavItemData(icon: Icons.star_outline_rounded, activeIcon: Icons.star_rounded, label: 'Ratings'),
          NavItemData(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Account'),
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
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: AppColors.deepNavy, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15)),
                      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
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
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Weekly Analytics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepNavy)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(24)),
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
              _buildStatRow(Icons.timer_outlined, 'Online Hours', '42.5h', '+12% from last week'),
              const SizedBox(height: 16),
              _buildStatRow(Icons.directions_car_outlined, 'Total Rides', '142', '+8% from last week'),
              const SizedBox(height: 16),
              _buildStatRow(Icons.account_balance_wallet_outlined, 'Net Earnings', '₹12,450', '₹850/avg daily'),
            ],
          ),
        ),
      ),
    );
  }

  void _showReviewsBottomSheet(BuildContext context) {
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
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Passenger Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.deepNavy)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('4.8', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (index) => Icon(Icons.star_rounded, color: index < 4 ? Colors.orange : Colors.grey[300], size: 20)),
                    ),
                    const Text('Based on 1,240 reviews', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildReviewItem('Ankit Sharma', '4.5', '2 hours ago', 'Great driver, reached on time and the car was very clean.'),
                  _buildReviewItem('Priya Patel', '5.0', 'Yesterday', 'Very polite behavior and safe driving. Highly recommended!'),
                  _buildReviewItem('Suresh Raina', '4.0', '2 days ago', 'Good experience but traffic was bad. Driver handled it well.'),
                  _buildReviewItem('Amit Mishra', '5.0', '3 days ago', 'Excellent service!'),
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
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.6)]),
            borderRadius: BorderRadius.circular(8),
          ),
        ).animate().scaleY(begin: 0, end: 1),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              ],
            ),
          ),
          Text(trend, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.successGreen)),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String name, String rating, String time, String comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: AppColors.bgLightGrey), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15)), Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))]),
          const SizedBox(height: 4),
          Row(children: [const Icon(Icons.star_rounded, color: Colors.orange, size: 14), const SizedBox(width: 4), Text(rating, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary))]),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}
