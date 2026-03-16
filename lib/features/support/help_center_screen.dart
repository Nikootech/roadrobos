import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

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
        title: const Text('Help Center', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(16)),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Iconsax.search_normal, size: 20, color: AppColors.textSecondary),
                  hintText: 'Search for help...',
                  border: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Popular Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildCategoryCard('Getting Started', Iconsax.flag),
                _buildCategoryCard('Booking & Rides', Iconsax.car),
                _buildCategoryCard('Wallet & Billing', Iconsax.wallet),
                _buildCategoryCard('Account Security', Iconsax.shield_security),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildActionCard('Contact Support', 'Chat with our team 24/7', Iconsax.message_text, AppColors.primaryBlue),
            const SizedBox(height: 12),
            _buildActionCard('Call Support', 'Talk to our representative', Iconsax.call, AppColors.successGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 28),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 18, color: AppColors.border),
        ],
      ),
    );
  }
}

