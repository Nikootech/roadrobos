import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

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
        title: const Text('Notifications', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => NavHelpers.showSuccess(context, 'All notifications marked as read'), child: const Text('Mark all as read', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12))),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 6,
        separatorBuilder: (_, __) => const Divider(height: 32),
        itemBuilder: (context, index) {
          return _buildNotificationTile(index);
        },
      ),
    );
  }

  Widget _buildNotificationTile(int index) {
    final titles = ['Ride Confirmed', 'Special Offer Unlocked', 'Maintenance Alert', 'Points Earned', 'New Feature!', 'Safety Check'];
    final descs = ['Your ride with Ravi is confirmed.', 'Get 20% off on your next car rental.', 'Your Baleno service is due in 5 days.', 'You earned 500 loyalty points!', 'Try our new live vehicle tracking.', 'Emergency contact added successfully.'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
          child: Icon(index.isEven ? Iconsax.notification : Iconsax.ticket_discount, color: AppColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titles[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text(descs[index], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
              const SizedBox(height: 8),
              const Text('2 hours ago', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
        ),
        if(index < 2) const CircleAvatar(radius: 4, backgroundColor: AppColors.primaryBlue),
      ],
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
