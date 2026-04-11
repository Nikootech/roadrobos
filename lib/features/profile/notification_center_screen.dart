import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';
import 'notification_provider.dart';
import 'package:intl/intl.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

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
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
                NavHelpers.showSuccess(context, 'All notifications marked as read');
              }, 
              child: const Text('Mark all as read', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12))
            ),
        ],
      ),
      body: notifications.isEmpty 
        ? _buildEmptyState()
        : ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 32),
            itemBuilder: (context, index) {
              return _buildNotificationTile(ref, notifications[index]);
            },
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.notification_status, size: 80, color: AppColors.textMuted.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No notifications yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(WidgetRef ref, AppNotification notification) {
    final timeStr = DateFormat('h:mm a').format(notification.timestamp);
    
    return GestureDetector(
      onTap: () => ref.read(notificationProvider.notifier).markAsRead(notification.id),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: notification.isRead ? AppColors.bgLightGrey : AppColors.primaryBlue.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: Icon(notification.icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 4),
                Text(notification.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
                const SizedBox(height: 8),
                Text(timeStr, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
          ),
          if(!notification.isRead) const CircleAvatar(radius: 4, backgroundColor: AppColors.primaryBlue),
        ],
      ).animate().fadeIn().slideX(begin: 0.05, end: 0),
    );
  }
}
