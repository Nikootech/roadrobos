import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

/// Driver Earnings Screen — Premium Overhaul
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Earnings Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.calendar, color: Colors.white),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Top Summary (Premium Navy Card)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
            decoration: const BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
            ),
            child: Column(
              children: [
                const Text('TOTAL BALANCE', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                const SizedBox(height: 12),
                const Text('₹12,450.00', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w900)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _buildQuickStat(Iconsax.car, 'Rides', '42'),
                    _buildDivider(),
                    _buildQuickStat(Iconsax.clock, 'Online', '38h'),
                    _buildDivider(),
                    _buildQuickStat(Iconsax.star, 'Rating', '4.9'),
                  ],
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    context.push('/driver-bank-withdrawal');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
                    ),
                    child: const Text('Cash Out to Bank', style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ).animate().scale(delay: 400.ms),
              ],
            ),
          ).animate().slideY(begin: -0.1, end: 0, duration: 600.ms),

          // Payout History & Charts
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payout History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
                    Icon(Iconsax.filter, color: AppColors.textPrimary, size: 20),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPremiumPayoutRow('Oct 16 - Oct 22', '₹12,450', 'Processing', AppColors.warningAmber),
                _buildPremiumPayoutRow('Oct 09 - Oct 15', '₹14,200', 'Deposited', AppColors.successGreen),
                _buildPremiumPayoutRow('Oct 02 - Oct 08', '₹11,800', 'Deposited', AppColors.successGreen),
                
                const SizedBox(height: 48),
                const Text('Weekly Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
                const SizedBox(height: 24),
                // Premium Chart Area
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 160,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildPremiumBar('Mon', 0.6),
                            _buildPremiumBar('Tue', 0.8),
                            _buildPremiumBar('Wed', 0.4),
                            _buildPremiumBar('Thu', 0.94, isMax: true),
                            _buildPremiumBar('Fri', 0.7),
                            _buildPremiumBar('Sat', 0.85),
                            _buildPremiumBar('Sun', 0.3),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.trending_up_rounded, size: 16, color: AppColors.successGreen),
                            SizedBox(width: 10),
                            Text('You earned 12% more than last week', style: TextStyle(fontSize: 12, color: AppColors.successGreen, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1, end: 0),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        items: const [
          NavItemData(icon: Iconsax.home, activeIcon: Iconsax.home5, label: 'Home'),
          NavItemData(icon: Iconsax.wallet, activeIcon: Iconsax.wallet5, label: 'Earnings'),
          NavItemData(icon: Iconsax.star, activeIcon: Iconsax.star5, label: 'Ratings'),
          NavItemData(icon: Iconsax.user, activeIcon: Iconsax.user, label: 'Account'),
        ],
        onTap: (index) {
          if (index == 0) context.pushReplacement('/driver-home');
          if (index == 1) return;
          if (index == 2) context.pushReplacement('/driver-rides');
          if (index == 3) context.pushReplacement('/driver-profile');
        },
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.white12);
  }

  Widget _buildPremiumPayoutRow(String date, String amount, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Iconsax.empty_wallet_tick, color: color, size: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(status, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          Text(amount, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.deepNavy)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }

  Widget _buildPremiumBar(String day, double percent, {bool isMax = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 32,
          height: 100 * percent,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isMax 
                ? [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.7)]
                : [AppColors.primaryBlue.withOpacity(0.2), AppColors.primaryBlue.withOpacity(0.1)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Text(day, style: TextStyle(fontSize: 12, color: isMax ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: isMax ? FontWeight.w900 : FontWeight.w600)),
      ],
    );
  }
}
