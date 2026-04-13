import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_provider.dart';

/// Profile Screen matching Figma Screen [55]: "User Profile & Loyalty Rewards"
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    // If user is null, we are likely in a logout transition or loading
    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.bgDarkProfile,
        body: Center(child: CircularProgressIndicator(color: AppColors.brandGreen)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDarkProfile,
      body: CustomScrollView(
        slivers: [
          // Top Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      AppStrings.myProfile,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textOnDark),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/account-settings'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bgDarkSurface),
                        child: const Icon(Icons.settings_outlined, color: AppColors.textOnDark, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Membership Card
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.bgDarkSurface, AppColors.bgDarkSurface.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warningAmber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.warningAmber, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: (user.profileImageUrl.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: user.profileImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppColors.bgDarkSurface,
                                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.warningAmber)),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.bgDarkSurface,
                                    child: const Icon(Icons.person_rounded, color: AppColors.textOnDark, size: 32),
                                  ),
                                )
                              : Container(
                                  color: AppColors.bgDarkSurface,
                                  child: const Icon(Icons.person_rounded, color: AppColors.textOnDark, size: 32),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textOnDark),
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Icon(Icons.star_rounded, size: 16, color: AppColors.warningAmber),
                                SizedBox(width: 4),
                                Text(
                                  AppStrings.goldMember,
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.warningAmber),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Points display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgDarkProfile.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(AppStrings.loyaltyPoints, style: TextStyle(fontSize: 12, color: AppColors.textOnDarkMuted)),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  Text(
                                    user.points.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.warningAmber),
                                  ),
                                  const SizedBox(width: 14),
                                  const Text('pts', style: TextStyle(fontSize: 14, color: AppColors.textOnDarkMuted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 56,
                          height: 56,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: 0.95,
                                strokeWidth: 4,
                                backgroundColor: AppColors.bgDarkSurface,
                                valueColor: AlwaysStoppedAnimation(AppColors.warningAmber),
                              ),
                              Text('95%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warningAmber)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),
          ),

          // Loyalty Benefits
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Gold Privileges', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textOnDark)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildBenefitCard(Icons.confirmation_num_rounded, '10% Off\nAll Services', const Color(0xFF3B82F6)),
                      const SizedBox(width: 10),
                      _buildBenefitCard(Icons.directions_car_rounded, 'Free Pickup\n& Drop', const Color(0xFF10B981)),
                      const SizedBox(width: 10),
                      _buildBenefitCard(Icons.auto_awesome_rounded, 'Priority\nBooking', const Color(0xFFF97316)),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(),
          ),

          // Profile Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                children: [
                  _buildMenuItem(Icons.person_outline_rounded, 'Account Settings', 'Profile, security, and more', () => context.push('/account-settings')),
                  _buildMenuItem(Icons.directions_car_filled_rounded, 'My Garage', 'Manage your vehicles', () => context.push('/my-vehicles')),
                  _buildMenuItem(Icons.location_on_outlined, 'Saved Locations', 'Add/edit addresses', () => context.push('/saved-locations')),
                  _buildMenuItem(Icons.history_rounded, 'Ride History', 'View past trips', () => context.push('/ride-history')),
                  _buildMenuItem(Icons.notifications_active_outlined, 'Service Reminders', 'Upcoming maintenance alerts', () => context.push('/service-reminders')),
                  _buildMenuItem(Icons.assignment_outlined, 'Service History', 'Maintenance logs & invoices', () => context.push('/service-history')),
                  _buildMenuItem(Icons.notifications_none_rounded, 'Notifications', 'Manage alerts', () => context.push('/notifications')),
                  _buildMenuItem(Icons.card_giftcard_rounded, 'Refer & Earn', 'Invite friends & earn', () => context.push('/referral')),
                  _buildMenuItem(Icons.help_outline_rounded, 'Help Center', 'FAQ & support chat', () => context.push('/help-center')),
                  const SizedBox(height: 12),
                  // Logout button
                  GestureDetector(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      await ref.read(userProvider.notifier).logout();
                      if (context.mounted) context.go('/auth/login');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.dangerRed.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded, color: AppColors.dangerRed, size: 22),
                          const SizedBox(width: 14),
                          const Text(AppStrings.logout, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.dangerRed)),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.dangerRed.withOpacity(0.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color, height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.bgDarkSurface.withOpacity(0.4), borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.bgDarkSurface, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.textOnDark, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textOnDark)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textOnDarkMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
