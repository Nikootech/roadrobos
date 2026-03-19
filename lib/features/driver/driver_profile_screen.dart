import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        title: const Text('Captain Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting, color: AppColors.textPrimary),
            onPressed: () => context.push('/account-settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                   CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                    child: const Icon(Iconsax.user, size: 50, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  const Text('Rajesh Kumar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const Text('Senior Captain • ID: BLR-49281', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('ACTIVE', style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            Row(
              children: [
                _buildStat('Total Rides', '1.2k', Iconsax.car),
                const SizedBox(width: 12),
                _buildStat('Rating', '4.8', Iconsax.star),
                const SizedBox(width: 12),
                _buildStat('Acceptance', '98%', Iconsax.task_square),
              ],
            ),
            const SizedBox(height: 24),
            // Menu
            InkWell(
              onTap: () => context.push('/driver/documents'),
              child: _buildMenuItem(Iconsax.setting_4, 'Documents & Verification', 'Manage DL, RC, and proofs'),
            ),
            InkWell(
              onTap: () => context.pushReplacement('/driver-rides'),
              child: _buildMenuItem(Iconsax.clock, 'Ride History', 'View past trips and logs'),
            ),
            InkWell(
              onTap: () => context.pushReplacement('/driver-earnings'),
              child: _buildMenuItem(Iconsax.wallet, 'Earnings', 'View your payouts & incentives'),
            ),
            InkWell(
              onTap: () => context.push('/help-center'),
              child: _buildMenuItem(Iconsax.support, 'Help Center', 'Contact admin desk'),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/auth/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerRed.withValues(alpha: 0.1),
                  foregroundColor: AppColors.dangerRed,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        items: const [
          NavItemData(icon: Iconsax.home, activeIcon: Iconsax.home5, label: 'Home'),
          NavItemData(icon: Iconsax.car, activeIcon: Iconsax.car5, label: 'Rides'),
          NavItemData(icon: Iconsax.wallet, activeIcon: Iconsax.wallet5, label: 'Earnings'),
          NavItemData(icon: Iconsax.user, activeIcon: Iconsax.user, label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) context.pushReplacement('/driver-home');
          if (index == 1) context.pushReplacement('/driver-rides');
          if (index == 2) context.pushReplacement('/driver-earnings');
          if (index == 3) return;
        },
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

