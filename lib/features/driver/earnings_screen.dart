import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

/// Driver Earnings History matching Figma Screen [17]
class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Earnings Overview',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Top Summary (Dark)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 16),
            decoration: const BoxDecoration(
              color: AppColors.deepNavy,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const Text('This Week', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                const Text('₹12,450.00', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: _buildStat(Icons.local_taxi, 'Rides', '42')),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(child: _buildStat(Icons.schedule, 'Online hours', '38h')),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: const Text('Cash Out to Bank', style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.w700, fontSize: 16)),
                )
              ],
            ),
          ).animate().slideY(begin: -0.1, end: 0, duration: 500.ms),

          // Chart/List Area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payout History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Icon(Icons.filter_list_rounded, color: AppColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 16),
                _buildEarningRow('Oct 16 - Oct 22', '₹12,450', 'Processing', AppColors.warningAmber),
                _buildEarningRow('Oct 09 - Oct 15', '₹14,200', 'Deposited', AppColors.successGreen),
                _buildEarningRow('Oct 02 - Oct 08', '₹11,800', 'Deposited', AppColors.successGreen),
                _buildEarningRow('Sep 25 - Oct 01', '₹13,500', 'Deposited', AppColors.successGreen),
                
                const SizedBox(height: 32),
                const Text('Daily Breakdown (This week)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                // Simple bar chart vis
                SizedBox(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildChartBar('Mon', 0.6),
                      _buildChartBar('Tue', 0.8),
                      _buildChartBar('Wed', 0.4),
                      _buildChartBar('Thu', 0.9),
                      _buildChartBar('Fri', 1.0, isMax: true),
                      _buildChartBar('Sat', 0.7),
                      _buildChartBar('Sun', 0.3),
                    ],
                  ),
                ).animate(delay: 300.ms).fadeIn(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildEarningRow(String date, String amount, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle), child: const Icon(Iconsax.wallet_1, color: AppColors.textPrimary, size: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 4),
                      Text(status, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                    ],
                  )
                ],
              ),
            ],
          ),
          Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildChartBar(String day, double percent, {bool isMax = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isMax) const Text('₹2.4k', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        if (isMax) const SizedBox(height: 4),
        Container(
          width: 24,
          height: 100 * percent,
          decoration: BoxDecoration(
            color: isMax ? AppColors.primaryBlue : AppColors.primaryBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(fontSize: 12, color: isMax ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: isMax ? FontWeight.w700 : FontWeight.w500)),
      ],
    );
  }
}

