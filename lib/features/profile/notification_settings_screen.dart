import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'user_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  // Notification Channels
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsAlerts = false;
  bool _whatsappUpdates = true;

  // Notification Types
  bool _rides = true;
  bool _offers = true;
  bool _maintenance = true;
  bool _wallet = false;

  // Advanced Preferences
  bool _quietHours = false;
  bool _soundVibration = true;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(userProvider).user?.notificationPreferences;
    if (prefs != null) {
      _pushNotifications = prefs['push'] ?? true;
      _emailNotifications = prefs['email'] ?? true;
      _smsAlerts = prefs['sms'] ?? false;
      _whatsappUpdates = prefs['whatsapp'] ?? true;
      _rides = prefs['rides'] ?? true;
      _offers = prefs['offers'] ?? true;
      _maintenance = prefs['maintenance'] ?? true;
      _wallet = prefs['wallet'] ?? false;
      _quietHours = prefs['quiet'] ?? false;
      _soundVibration = prefs['sound'] ?? true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.bgDarkCard : Colors.white;
    final headerTextColor = isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary;
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.bgDarkDeep : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: isDark ? Colors.white : AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notification Settings',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('NOTIFICATION CHANNELS', headerTextColor),
            const SizedBox(height: 12),
            _buildCardContainer(cardBgColor, [
              _buildSwitchTile(
                Icons.notifications_active_outlined,
                'Push Notifications',
                'Instantly receive alerts on your device screen',
                _pushNotifications,
                (v) {
                  setState(() => _pushNotifications = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'push': v});
                },
              ),
              const Divider(height: 1, indent: 60),
              _buildSwitchTile(
                Icons.mail_outline_rounded,
                'Email Notifications',
                'Weekly summaries, invoices, and service updates',
                _emailNotifications,
                (v) {
                  setState(() => _emailNotifications = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'email': v});
                },
              ),
              const Divider(height: 1, indent: 60),
              _buildSwitchTile(
                Icons.sms_outlined,
                'SMS Alerts',
                'Urgent travel updates and verification alerts',
                _smsAlerts,
                (v) {
                  setState(() => _smsAlerts = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'sms': v});
                },
              ),
              const Divider(height: 1, indent: 60),
              _buildSwitchTile(
                Icons.chat_bubble_outline_rounded,
                'WhatsApp Updates',
                'Get updates, tracking links, and customer support via WhatsApp',
                _whatsappUpdates,
                (v) {
                  setState(() => _whatsappUpdates = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'whatsapp': v});
                },
              ),
            ]),
            const SizedBox(height: 28),
            _buildSectionHeader('ALERT TYPES & PREFERENCES', headerTextColor),
            const SizedBox(height: 12),
            _buildCardContainer(cardBgColor, [
              _buildSwitchTile(
                Icons.local_taxi_rounded,
                'Ride Updates',
                'Status, driver details, and live trip alerts',
                _rides,
                (v) {
                  setState(() => _rides = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'rides': v});
                },
              ),
              const Divider(height: 1, indent: 60),
              _buildSwitchTile(
                Icons.local_offer_outlined,
                'Promotions & Offers',
                'Exclusive loyalty discounts, coupons, and campaigns',
                _offers,
                (v) {
                  setState(() => _offers = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'offers': v});
                },
              ),
              const Divider(height: 1, indent: 60),
              _buildSwitchTile(
                Icons.build_circle_outlined,
                'Vehicle Maintenance',
                'Service booking alerts, renewals, and diagnostic checks',
                _maintenance,
                (v) {
                  setState(() => _maintenance = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'maintenance': v});
                },
              ),
              const Divider(height: 1, indent: 60),
              _buildSwitchTile(
                Icons.account_balance_wallet_outlined,
                'Wallet & Billing',
                'Monthly statement alerts, transaction confirmations',
                _wallet,
                (v) {
                  setState(() => _wallet = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'wallet': v});
                },
              ),
            ]),
            const SizedBox(height: 28),
            _buildSectionHeader('ADVANCED PREFERENCES', headerTextColor),
            const SizedBox(height: 12),
            _buildCardContainer(cardBgColor, [
              _buildSwitchTile(
                Icons.do_not_disturb_on_outlined,
                'Quiet Hours',
                'Mute all non-critical notifications from 10:00 PM to 7:00 AM',
                _quietHours,
                (v) {
                  setState(() => _quietHours = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'quiet': v});
                },
              ),
              const Divider(height: 1, indent: 60),
              _buildSwitchTile(
                Icons.volume_up_outlined,
                'Sound & Vibration',
                'Play alert tones and trigger haptics for incoming alerts',
                _soundVibration,
                (v) {
                  setState(() => _soundVibration = v);
                  ref.read(userProvider.notifier).updateNotificationPreferences({'sound': v});
                },
              ),
            ]),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 18),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'System alerts and critical security notifications cannot be disabled.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCardContainer(Color bgColor, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileTitleColor = isDark ? Colors.white : AppColors.textPrimary;
    final tileSubColor = isDark ? AppColors.textOnDarkMuted : AppColors.textSecondary;
    final iconBgColor = isDark ? AppColors.bgDarkSurface : AppColors.bgLightGrey;

    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: tileTitleColor,
              ),
            ),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 44.0, top: 2),
        child: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: tileSubColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      activeThumbColor: AppColors.primaryBlue,
      activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }
}
