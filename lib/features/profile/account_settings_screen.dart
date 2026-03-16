import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

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
        title: const Text('Account Settings', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSettingsGroup('Personal Information', [
              _buildSettingsTile(Iconsax.user, 'Edit Profile', 'Update name, email, phone'),
              _buildSettingsTile(Iconsax.location_add, 'Saved Locations', 'Manage home and office addresses', onTap: () => context.push('/saved-locations')),
              _buildSettingsTile(Iconsax.car, 'My Vehicles', 'Vehicle details and RC docs', onTap: () => context.push('/my-vehicles')),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup('Security', [
              _buildSettingsTile(Iconsax.lock_1, 'Change Password', 'Update your security credentials'),
              _buildSettingsTile(Iconsax.shield_security, 'Two-Factor Authentication', 'Add extra layer of security'),
            ]),
            const SizedBox(height: 24),
            _buildSettingsGroup('Preferences', [
              _buildSettingsTile(Iconsax.notification, 'Notification Settings', 'Manage push and email alerts', onTap: () => context.push('/notification-settings')),
              _buildSettingsTile(Iconsax.language_square, 'Language', 'Choose your preferred language', onTap: () => context.push('/language')),
            ]),
            const SizedBox(height: 48),
            TextButton(
              onPressed: () => context.go('/auth/login'),
              child: const Text('LOGOUT', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.border),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}
