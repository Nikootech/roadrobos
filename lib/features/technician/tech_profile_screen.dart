import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../profile/user_provider.dart';

class TechProfileScreen extends ConsumerWidget {
  const TechProfileScreen({super.key});

  void _onBottomNavTap(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    switch (index) {
      case 0: context.go('/tech-dashboard'); break;
      case 1: context.go('/tech-tasks'); break;
      case 2: context.go('/tech-spare-parts'); break;
      case 3: break; // Already here
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final String name = user?.name ?? 'Guest Technician';

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        title: const Text('Technician Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
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
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                   CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                    child: (user.profileImageUrl.isNotEmpty)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(user.profileImageUrl, fit: BoxFit.cover),
                          )
                        : const Icon(Iconsax.user, size: 50, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Senior Technician • ID: TECH-099', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.successGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Text('ACTIVE', style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            Row(
              children: [
                _buildStat('Jobs Done', '142', Iconsax.tick_circle),
                const SizedBox(width: 12),
                _buildStat('Rating', '4.9', Iconsax.star),
                const SizedBox(width: 12),
                _buildStat('Experience', '5Y', Iconsax.timer),
              ],
            ),
            const SizedBox(height: 24),
            // Menu
            _buildMenuItem(Iconsax.book, 'Service Manuals', 'Browse technical guides', () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service Manuals coming soon!'), backgroundColor: Color(0xFF1A237E)),
              );
            }),
            _buildMenuItem(Iconsax.wallet, 'Earnings', 'View your payouts & incentives', () {
              HapticFeedback.lightImpact();
              context.push('/tech-earnings');
            }),
            _buildMenuItem(Iconsax.support, 'Technical Support', 'Contact admin desk', () {
              HapticFeedback.lightImpact();
              context.push('/chat');
            }),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.go('/auth/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerRed.withOpacity(0.1),
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
      bottomNavigationBar: _buildBottomNav(context),
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
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F2F4))),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Iconsax.home, 'Dashboard', 0),
          _navItem(context, Iconsax.task_square, 'Jobs', 1),
          _navItem(context, Iconsax.box, 'Parts', 2),
          _navItem(context, Iconsax.user5, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = index == 3;
    return GestureDetector(
      onTap: () => _onBottomNavTap(context, index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE8EAF6) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isActive ? const Color(0xFF1A237E) : Colors.grey, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? const Color(0xFF1A237E) : Colors.grey)),
          ],
        ),
      ),
    );
  }
}
