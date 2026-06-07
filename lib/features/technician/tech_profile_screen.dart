import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../profile/user_provider.dart';
import '../../core/repositories/ratings_repository.dart';

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
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final String name = user?.name ?? 'Guest Technician';
    final String userId = user?.id ?? '';
    
    final ratingAsyncValue = ref.watch(partnerRatingProvider(userId));
    final ratingData = ratingAsyncValue.value;
    final String avgRatingStr = ratingData?['avg_score']?.toString() ?? '5.0';

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        title: const Text('Technician Profile', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
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
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                   CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                    child: (user?.profilePic != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(user!.profilePic!, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.person_outline_rounded, size: 50, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Senior Technician • ID: TECH-099', style: TextStyle(color: AppColors.textSecondary)),
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
                _buildStat('Jobs Done', '142', Icons.task_alt_rounded),
                const SizedBox(width: 12),
                _buildStat('Rating', avgRatingStr, Icons.star_rounded),
                const SizedBox(width: 12),
                _buildStat('Experience', '5Y', Icons.timer_outlined),
              ],
            ),
            const SizedBox(height: 24),
            // Menu
            _buildMenuItem(Icons.menu_book_rounded, 'Service Manuals', 'Browse technical guides', () {
              HapticFeedback.lightImpact();
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                backgroundColor: Colors.white,
                builder: (modalContext) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Service Manuals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: const Text('Hyundai Creta 2021 Service Guide'),
                        trailing: const Icon(Icons.download_rounded),
                        onTap: () => Navigator.pop(modalContext),
                      ),
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: const Text('Honda City Electrical Diagram'),
                        trailing: const Icon(Icons.download_rounded),
                        onTap: () => Navigator.pop(modalContext),
                      ),
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: const Text('Tata Nexon Routine Maintenance'),
                        trailing: const Icon(Icons.download_rounded),
                        onTap: () => Navigator.pop(modalContext),
                      ),
                    ],
                  ),
                ),
              );
            }),
            _buildMenuItem(Icons.account_balance_wallet_outlined, 'Earnings', 'View your payouts & incentives', () {
              HapticFeedback.lightImpact();
              context.push('/tech-earnings');
            }),
            _buildMenuItem(Icons.support_agent_rounded, 'Technical Support', 'Contact admin desk', () {
              HapticFeedback.lightImpact();
              context.push('/chat');
            }),
            _buildMenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', 'Data usage and security', () {
              HapticFeedback.lightImpact();
              launchUrl(Uri.parse('https://roadrobos.com/privacy'));
            }),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await ref.read(userProvider.notifier).logout();
                  if (context.mounted) context.go('/auth/login');
                },
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
          _navItem(context, Icons.home_outlined, 'Dashboard', 0),
          _navItem(context, Icons.task_alt_rounded, 'Jobs', 1),
          _navItem(context, Icons.inventory_2_outlined, 'Parts', 2),
          _navItem(context, Icons.person_rounded, 'Profile', 3),
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
