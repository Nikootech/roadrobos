import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class ManageRemindersScreen extends StatelessWidget {
  const ManageRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Manage Reminders',
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionHeader('Upcoming Reminders'),
            const SizedBox(height: 16),
            _buildReminderCard(
                'Service Due Reminder',
                'Target: Bajaj Pulsar Owners',
                'Scheduled: Oct 20, 10:00 AM',
                true),
            const SizedBox(height: 12),
            _buildReminderCard('Subscription Expiry', 'Target: Premium Users',
                'Scheduled: Oct 22, 09:00 AM', true),
            const SizedBox(height: 32),
            _buildSectionHeader('Past Reminders',
                () => context.push('/admin-past-notifications')),
            const SizedBox(height: 16),
            _buildReminderCard('Weekend Offer Blast', 'Target: All Users',
                'Sent: Oct 15, 05:00 PM', false),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => _showNewReminderDialog(context),
              icon: const Icon(Iconsax.add_circle, size: 20),
              label: const Text('SCHEDULE NEW NOTIFICATION'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewReminderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('New Notification',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(
                decoration: InputDecoration(
                    labelText: 'Target Users',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 12),
            TextField(
                maxLines: 3,
                decoration: InputDecoration(
                    labelText: 'Message Body',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)))),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Notification scheduled!'),
                  behavior: SnackBarBehavior.floating));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white),
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, [VoidCallback? onTap]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: onTap,
          child: const Text('View All',
              style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildReminderCard(
      String title, String target, String meta, bool isUpcoming) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color:
                    (isUpcoming ? AppColors.primaryBlue : AppColors.textMuted)
                        .withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: Icon(Iconsax.notification_bing,
                color: isUpcoming ? AppColors.primaryBlue : AppColors.textMuted,
                size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(target,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 6),
                Text(meta,
                    style: TextStyle(
                        color: isUpcoming
                            ? AppColors.primaryBlue
                            : AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (isUpcoming)
            const Icon(Iconsax.edit, size: 18, color: AppColors.textSecondary),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
