import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  Future<void> _makeCall() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '+911234567890',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showCategoryFAQ(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Finding the right help for $category... This section will contain frequently asked questions and detailed guides shortly.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

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
                style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  icon: Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                  hintText: 'Search for help...',
                  border: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
             const Text('Popular Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildCategoryCard(context, 'Getting Started', Icons.rocket_launch_rounded),
                _buildCategoryCard(context, 'Booking & Rides', Icons.car_rental_rounded),
                _buildCategoryCard(context, 'Wallet & Billing', Icons.account_balance_wallet_rounded),
                _buildCategoryCard(context, 'Account Security', Icons.shield_rounded),
              ],
            ),
            
            const SizedBox(height: 32),
            _buildActionCard(
              context, 
              'Contact Support', 
              'Chat with our team 24/7', 
              Icons.chat_bubble_rounded, 
              AppColors.primaryBlue,
              onTap: () => context.push('/chat'),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              context, 
              'Call Support', 
              'Talk to our representative', 
              Icons.phone_in_talk_rounded, 
              AppColors.successGreen,
              onTap: _makeCall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String label, IconData icon) {
    return InkWell(
      onTap: () => _showCategoryFAQ(context, label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 28),
            const SizedBox(height: 12),
             Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
          ],
        ),
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                   Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.border),
          ],
        ),
      ),
    );
  }
}

