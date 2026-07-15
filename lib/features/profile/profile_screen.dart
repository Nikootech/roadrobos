import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/app_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../core/services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Profile Screen matching Figma Screen [55]: "User Profile & Loyalty Rewards"
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isGold = user.points > 5000;
    final isSilver = user.points > 2000;

    final LinearGradient cardGradient = isGold
        ? const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706), Color(0xFF92400E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : (isSilver
            ? const LinearGradient(
                colors: [Color(0xFF94A3B8), Color(0xFF64748B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFB45309), Color(0xFF78350F), Color(0xFF451A03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ));

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
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
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/account-settings'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.settings_outlined,
                            color: AppColors.textPrimary, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Membership Card (Premium luxury gradient card)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: cardGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: (isGold
                            ? const Color(0xFFD97706)
                            : (isSilver ? const Color(0xFF64748B) : const Color(0xFF78350F)))
                        .withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery);
                          if (image != null) {
                            final storageService = StorageService();
                            final url = await storageService.uploadAvatar(
                                File(image.path), user.id);
                            if (url != null) {
                              await Supabase.instance.client
                                  .from('profiles')
                                  .update({'profile_pic': url}).eq(
                                      'id', user.id);
                              ref.invalidate(userProvider);
                            }
                          }
                        },
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 2.5),
                          ),
                          child: AppAvatar(
                            imageUrl: user.profileImageUrl,
                            radius: 32,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.3),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 16,
                                    color: isGold
                                        ? const Color(0xFFFDE047)
                                        : (isSilver
                                            ? Colors.grey.shade200
                                            : Colors.orange.shade300)),
                                const SizedBox(width: 4),
                                Text(
                                  isGold
                                      ? 'Gold Member'
                                      : (isSilver
                                          ? 'Silver Member'
                                          : 'Bronze Member'),
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: isGold
                                          ? const Color(0xFFFDE047)
                                          : (isSilver
                                              ? Colors.grey.shade200
                                              : Colors.orange.shade200)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Loyalty Points Display (Glassmorphism layout)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(AppStrings.loyaltyPoints,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70)),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    user.points.toString().replaceAllMapped(
                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                        (Match m) => '${m.group(1) ?? ''},'),
                                    style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 4.0),
                                    child: Text('pts',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 58,
                          height: 58,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: (user.points % 1000) / 1000,
                                strokeWidth: 4.5,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: const AlwaysStoppedAnimation(
                                    Colors.white),
                              ),
                              Text(
                                  '${((user.points % 1000) / 10).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white)),
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
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGold ? 'Your Gold Privileges' : 'Your Member Privileges',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildBenefitCard(Icons.confirmation_num_rounded,
                          '10% Off\nAll Services', const Color(0xFF3B82F6)),
                      const SizedBox(width: 10),
                      _buildBenefitCard(Icons.directions_car_rounded,
                          'Free Pickup\n& Drop', const Color(0xFF10B981)),
                      const SizedBox(width: 10),
                      _buildBenefitCard(Icons.auto_awesome_rounded,
                          'Priority\nBooking', const Color(0xFFF97316)),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 150.ms).fadeIn(),
          ),

          // Profile Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Column(
                children: [
                  _buildMenuItem(
                      Icons.person_outline_rounded,
                      'Account Settings',
                      'Profile, security, and more',
                      () => context.push('/account-settings')),
                  _buildMenuItem(
                      Icons.directions_car_filled_rounded,
                      'My Vehicles',
                      'Manage your vehicles',
                      () => context.push('/vehicles')),
                  _buildMenuItem(
                      Icons.location_on_outlined,
                      'Saved Locations',
                      'Add/edit addresses',
                      () => context.push('/saved-locations')),
                  _buildMenuItem(Icons.history_rounded, 'Ride History',
                      'View past trips', () => context.push('/ride-history')),
                  _buildMenuItem(
                      Icons.notifications_active_outlined,
                      'Service Reminders',
                      'Upcoming maintenance alerts',
                      () => context.push('/service-reminders')),
                  _buildMenuItem(
                      Icons.assignment_outlined,
                      'Service History',
                      'Maintenance logs & invoices',
                      () => context.push('/service-history')),
                  _buildMenuItem(Icons.card_giftcard_rounded, 'Refer & Earn',
                      'Invite friends & earn', () => context.push('/referral')),
                  _buildMenuItem(Icons.help_outline_rounded, 'Help Center',
                      'FAQ & support chat', () => context.push('/help-center')),
                  _buildMenuItem(
                      Icons.privacy_tip_outlined,
                      'Privacy Policy',
                      'Data usage and security',
                      () => context.push('/privacy-policy')),
                  _buildMenuItem(
                      Icons.description_outlined,
                      'Terms of Service',
                      'Read our terms and conditions',
                      () => context.push('/terms-of-service')),
                  
                  const SizedBox(height: 8),

                  // Logout button
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerRed.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: AppColors.dangerRed.withValues(alpha: 0.15)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await HapticFeedback.mediumImpact();
                          await ref.read(userProvider.notifier).logout();
                          if (context.mounted) context.go('/auth/login');
                        },
                        borderRadius: BorderRadius.circular(22),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Row(
                            children: [
                              const Icon(Icons.logout_rounded,
                                  color: AppColors.dangerRed, size: 22),
                              const SizedBox(width: 16),
                              const Text(
                                AppStrings.logout,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.dangerRed),
                              ),
                              const Spacer(),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: AppColors.dangerRed.withValues(alpha: 0.5)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 250.ms).fadeIn(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brandGreen.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: AppColors.brandGreen, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
