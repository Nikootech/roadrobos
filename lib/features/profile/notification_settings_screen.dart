import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  _buildSwitchTile('Ride Updates', 'Status, driver info, and trip alerts', _rides, (v) => setState(() => _rides = v)),
                  const Divider(height: 1),
                  _buildSwitchTile('Promotions & Offers', 'Coupons, flash sales, and rewards', _offers, (v) => setState(() => _offers = v)),
                  const Divider(height: 1),
                  _buildSwitchTile('Vehicle Maintenance', 'Service remainders and health alerts', _maintenance, (v) => setState(() => _maintenance = v)),
                  const Divider(height: 1),
                  _buildSwitchTile('Wallet & Billing', 'Top-up alerts and monthly invoices', _wallet, (v) => setState(() => _wallet = v)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      activeThumbColor: AppColors.primaryBlue,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
