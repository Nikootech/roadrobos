import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class UserLoyaltyScreen extends StatelessWidget {
  const UserLoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('RoAdRoBos Platinum', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Points Card
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2B32B2), Color(0xFF1488CC)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text('Available Points', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  const Text('12,450', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Platinum Tier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            ).animate().scale(),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Exclusive Rewards'),
            const SizedBox(height: 16),
            _buildRewardTile('Free Car Spa', '5,000 Pts', Iconsax.brush_1),
            _buildRewardTile('₹500 Fuel Coupon', '4,500 Pts', Iconsax.gas_station),
            _buildRewardTile('Priority Support', 'FREE', Iconsax.headphone),
            
            const SizedBox(height: 32),
            _buildSectionHeader('How to earn?'),
            const SizedBox(height: 16),
            const Text('Earn 1 point for every ₹10 spent on rides, rentals, or services.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Text('History', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildRewardTile(String title, String cost, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.white, child: Icon(icon, color: AppColors.primaryBlue, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(cost, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w800, fontSize: 12)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}

