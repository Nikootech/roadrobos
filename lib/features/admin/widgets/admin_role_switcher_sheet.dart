import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/models/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/user_provider.dart';
import '../admin_providers.dart';

/// Modal bottom sheet allowing SuperAdmin/Founder to switch and preview any of the 14 role views live.
class AdminRoleSwitcherSheet extends ConsumerWidget {
  const AdminRoleSwitcherSheet({super.key});

  static const allRoles = UserRole.values;

  static void show(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdminRoleSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentImpersonation = ref.watch(impersonatedRoleProvider);
    final userState = ref.watch(userProvider);
    final actualRole = userState.user?.role ?? UserRole.superAdmin;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role Impersonation Engine',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Preview & test UI layouts across all 14 roles',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
              if (currentImpersonation != null)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    ref.read(impersonatedRoleProvider.notifier).state = null;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh_rounded,
                      size: 16, color: AppColors.dangerRed),
                  label: const Text(
                    'Reset',
                    style: TextStyle(
                      color: AppColors.dangerRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: allRoles.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final role = allRoles[index];
                final isSelected = currentImpersonation == role ||
                    (currentImpersonation == null && role == actualRole);

                return Material(
                  color: isSelected
                      ? AppColors.brandGreen.withValues(alpha: 0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (role == actualRole) {
                        ref.read(impersonatedRoleProvider.notifier).state =
                            null;
                      } else {
                        ref.read(impersonatedRoleProvider.notifier).state =
                            role;
                      }
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brandGreen
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.brandGreen.withValues(alpha: 0.15)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _iconForRole(role),
                              size: 18,
                              color: isSelected
                                  ? AppColors.brandGreen
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      role.roleLabel,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? AppColors.brandGreen
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (role == actualRole) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.brandGreen
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'YOUR ROLE',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.brandGreen,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _descriptionForRole(role),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.brandGreen,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForRole(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => Iconsax.crown,
      UserRole.founderAdmin => Iconsax.shield_security,
      UserRole.opsHead => Iconsax.radar,
      UserRole.cityManager => Iconsax.building_3,
      UserRole.areaManager => Iconsax.map_1,
      UserRole.financeManager => Iconsax.wallet_3,
      UserRole.supportManager => Iconsax.headphone,
      UserRole.marketingAdmin => Iconsax.discount_shape,
      UserRole.auditor => Iconsax.document_text,
      UserRole.analyst => Iconsax.chart_21,
      UserRole.admin => Iconsax.security_user,
      UserRole.driver => Iconsax.car,
      UserRole.technician => Iconsax.setting_4,
      UserRole.customer => Iconsax.user,
    };
  }

  String _descriptionForRole(UserRole role) {
    return switch (role) {
      UserRole.superAdmin => 'Full system control and strategic metrics',
      UserRole.founderAdmin => 'Unrestricted platform and executive command',
      UserRole.opsHead => 'Real-time fleet operations and SOS escalations',
      UserRole.cityManager =>
        'Territorial city-level management and active drivers',
      UserRole.areaManager => 'Local zone coordination and service allocations',
      UserRole.financeManager =>
        'Revenue KPIs, pending settlements and dispute ledger',
      UserRole.supportManager =>
        'Customer tickets, rating metrics and dispute center',
      UserRole.marketingAdmin =>
        'Campaign offers, promo codes and customer acquisition',
      UserRole.auditor => 'Read-only compliance audit trail and verification',
      UserRole.analyst =>
        'Data telemetry, retention charts and reporting exports',
      UserRole.admin => 'General administrative control (legacy view)',
      UserRole.driver => 'Driver mobile experience with earnings and rides',
      UserRole.technician => 'Service partner queue and repair tools',
      UserRole.customer => 'Standard consumer booking portal',
    };
  }
}
