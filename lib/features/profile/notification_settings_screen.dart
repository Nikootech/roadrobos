import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _rides = true;
  bool _offers = true;
  bool _maintenance = true;
  bool _wallet = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notification Settings', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  _buildSwitchTile(Icons.local_taxi_rounded, 'Ride Updates', 'Status, driver info, and trip alerts', _rides, (v) => setState(() => _rides = v)),
                  const Divider(height: 1, indent: 60),
                  _buildSwitchTile(Icons.local_offer_outlined, 'Promotions & Offers', 'Coupons, flash sales, and rewards', _offers, (v) => setState(() => _offers = v)),
                  const Divider(height: 1, indent: 60),
                  _buildSwitchTile(Icons.build_circle_outlined, 'Vehicle Maintenance', 'Service remainders and health alerts', _maintenance, (v) => setState(() => _maintenance = v)),
                  const Divider(height: 1, indent: 60),
                  _buildSwitchTile(Icons.account_balance_wallet_outlined, 'Wallet & Billing', 'Top-up alerts and monthly invoices', _wallet, (v) => setState(() => _wallet = v)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 18),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'System alerts and critical updates cannot be disabled.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(IconData icon, String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppColors.primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14))),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(left: 44.0),
        child: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ),
      activeThumbColor: AppColors.primaryBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }
}
