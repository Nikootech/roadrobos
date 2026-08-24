import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
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
                colors: [
                  Color(0xFF94A3B8),
                  Color(0xFF64748B),
                  Color(0xFF334155)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  Color(0xFFB45309),
                  Color(0xFF78350F),
                  Color(0xFF451A03)
                ],
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
                      onTap: () => context.push('/settings'),
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
                            : (isSilver
                                ? const Color(0xFF64748B)
                                : const Color(0xFF78350F)))
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
                            border: Border.all(color: Colors.white, width: 2.5),
                          ),
                          child: AppAvatar(
                            imageUrl: user.profileImageUrl,
                            radius: 32,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
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
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5),
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
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.15),
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.white),
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGold ? 'Your Gold Privileges' : 'Your Member Privileges',
                    style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildBenefitCard(
                        Iconsax.discount_shape,
                        '10% OFF',
                        'All Services',
                        const [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                      ),
                      const SizedBox(width: 10),
                      _buildBenefitCard(
                        Iconsax.car,
                        'FREE',
                        'Pickup & Drop',
                        const [Color(0xFF006241), Color(0xFF10B981)],
                      ),
                      const SizedBox(width: 10),
                      _buildBenefitCard(
                        Iconsax.flash_1,
                        'PRIORITY',
                        'Instant Booking',
                        const [Color(0xFFEA580C), Color(0xFFF59E0B)],
                      ),
                    ],
                  ),
                ],
              ),
            ).animate(delay: 150.ms).fadeIn(),
          ),

          // Profile Actions — Grouped React Tier-1 Menu System
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('MOBILITY & ASSETS'),
                  _buildMenuItem(
                    icon: Iconsax.car,
                    title: 'My Garage & Vehicles',
                    subtitle: 'Manage cars, bikes & EV fleet',
                    gradient: const [Color(0xFF0284C7), Color(0xFF38BDF8)],
                    badge: 'GARAGE',
                    badgeBg: const Color(0xFFF0F9FF),
                    badgeColor: const Color(0xFF0284C7),
                    onTap: () => context.push('/vehicles'),
                  ),
                  _buildMenuItem(
                    icon: Iconsax.shield_tick,
                    title: 'Insurance & Policies',
                    subtitle: 'Active coverage & 1-tap claims',
                    gradient: const [Color(0xFF006241), Color(0xFF10B981)],
                    badge: 'INSURED',
                    badgeBg: const Color(0xFFF0FDF4),
                    badgeColor: const Color(0xFF006241),
                    onTap: () => context.push('/insurance'),
                  ),
                  _buildMenuItem(
                    icon: Iconsax.location,
                    title: 'Saved Locations',
                    subtitle: 'Home, office & favorite pins',
                    gradient: const [Color(0xFF0D9488), Color(0xFF14B8A6)],
                    badge: 'SAVED',
                    badgeBg: const Color(0xFFF0FDFA),
                    badgeColor: const Color(0xFF0D9488),
                    onTap: () => context.push('/saved-locations'),
                  ),

                  _buildSectionHeader('ACTIVITY & HISTORY'),
                  _buildMenuItem(
                    icon: Iconsax.routing,
                    title: 'Ride & Taxi History',
                    subtitle: 'Past trips, invoices & drivers',
                    gradient: const [Color(0xFF0284C7), Color(0xFF38BDF8)],
                    badge: 'TRIPS',
                    badgeBg: const Color(0xFFF0F9FF),
                    badgeColor: const Color(0xFF0284C7),
                    onTap: () => context.push('/ride-history'),
                  ),
                  _buildMenuItem(
                    icon: Iconsax.notification_bing,
                    title: 'Service Reminders',
                    subtitle: 'Upcoming maintenance & alerts',
                    gradient: const [Color(0xFFD97706), Color(0xFFFBBF24)],
                    badge: 'ALERTS',
                    badgeBg: const Color(0xFFFFFBEB),
                    badgeColor: const Color(0xFFD97706),
                    onTap: () => context.push('/service-reminders'),
                  ),
                  _buildMenuItem(
                    icon: Iconsax.clipboard_text,
                    title: 'Service History & Logs',
                    subtitle: 'Full maintenance records & bills',
                    gradient: const [Color(0xFF334155), Color(0xFF64748B)],
                    badge: 'LOGS',
                    badgeBg: const Color(0xFFF8FAFC),
                    badgeColor: const Color(0xFF475569),
                    onTap: () => context.push('/service-history'),
                  ),

                  _buildSectionHeader('ACCOUNT & PREFERENCES'),
                  _buildMenuItem(
                    icon: Iconsax.user_edit,
                    title: 'Account Settings',
                    subtitle: 'Profile info, phone & security',
                    gradient: const [Color(0xFF006241), Color(0xFF10B981)],
                    badge: 'VERIFIED',
                    badgeBg: const Color(0xFFF0FDF4),
                    badgeColor: const Color(0xFF006241),
                    onTap: () => context.push('/account-settings'),
                  ),
                  _buildMenuItem(
                    icon: Iconsax.gift,
                    title: 'Refer & Earn',
                    subtitle: 'Invite friends & get ₹250 credits',
                    gradient: const [Color(0xFFE11D48), Color(0xFFFB7185)],
                    badge: '₹250 BONUS',
                    badgeBg: const Color(0xFFFFF1F2),
                    badgeColor: const Color(0xFFE11D48),
                    onTap: () => context.push('/referral'),
                  ),
                  _buildMenuItem(
                    icon: Iconsax.message_question,
                    title: 'Help Center 24/7',
                    subtitle: 'Live support, FAQs & tickets',
                    gradient: const [Color(0xFF0D9488), Color(0xFF14B8A6)],
                    badge: '24/7 LIVE',
                    badgeBg: const Color(0xFFF0FDFA),
                    badgeColor: const Color(0xFF0D9488),
                    onTap: () => context.push('/help-center'),
                  ),
                  _buildMenuItem(
                    icon: Iconsax.security_safe,
                    title: 'Privacy & Legal Terms',
                    subtitle: 'Data protection & user agreement',
                    gradient: const [Color(0xFF475569), Color(0xFF64748B)],
                    badge: 'SECURE',
                    badgeBg: const Color(0xFFF8FAFC),
                    badgeColor: const Color(0xFF475569),
                    onTap: () => context.push('/privacy-policy'),
                  ),

                  const SizedBox(height: 12),

                  // Modern Sign Out Card
                  GestureDetector(
                    onTap: () async {
                      await HapticFeedback.mediumImpact();
                      await ref.read(userProvider.notifier).logout();
                      if (context.mounted) context.go('/auth/login');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFFE11D48).withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFDC2626)
                                      .withValues(alpha: 0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Iconsax.logout,
                                  color: Colors.white, size: 21),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.logout,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sign out of your RoadRobos session',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    color: const Color(0xFF991B1B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border:
                                  Border.all(color: const Color(0xFFFECDD3)),
                            ),
                            child: const Center(
                              child: Icon(
                                Iconsax.arrow_right_3,
                                size: 13,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF94A3B8),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildBenefitCard(
      IconData icon, String badge, String label, List<Color> gradient) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              badge,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: gradient[0],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required String badge,
    required Color badgeBg,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.first.withValues(alpha: 0.28),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6.5, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: badgeColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              badge,
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: badgeColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Icon(
                      Iconsax.arrow_right_3,
                      size: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
