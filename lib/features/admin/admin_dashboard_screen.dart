import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/models/user_role.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../shared/widgets/responsive_utils.dart';
import '../../features/profile/user_provider.dart';
import 'admin_providers.dart';
import 'admin_ops_provider.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../core/services/language_service.dart';
import 'models/role_dashboard_config.dart';
import 'widgets/admin_bottom_nav_bar.dart';
import 'widgets/admin_role_switcher_sheet.dart';
import 'widgets/zone_filter_dropdown.dart';
import 'widgets/predictive_heatmap_card.dart';
import 'b2b_fleet_portal_screen.dart';
import 'widgets/role_sections/finance_dashboard_section.dart';
import 'widgets/role_sections/support_dashboard_section.dart';
import 'widgets/role_sections/marketing_dashboard_section.dart';
import 'widgets/role_sections/audit_dashboard_section.dart';
import 'widgets/role_sections/analytics_chart_section.dart';

/// Admin Dashboard Overview matching modern Executive Fintech aesthetic
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  void _showEmergencyAlertDetails(EmergencyAlert alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.55,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: AppColors.dangerRed.withValues(alpha: 0.1),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.emergency_rounded,
                      color: AppColors.dangerRed, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🚨 Roadside Emergency SOS',
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dangerRed)),
                      Text(
                          'User ID: ${alert.userId.length > 8 ? alert.userId.substring(0, 8).toUpperCase() : alert.userId}',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _buildDetailRow('Reported Location/Coordinates', alert.message,
                Icons.location_on_rounded),
            const SizedBox(height: 16),
            _buildDetailRow(
                'Triggered At',
                '${alert.timestamp.day}/${alert.timestamp.month}/${alert.timestamp.year} at ${alert.timestamp.hour.toString().padLeft(2, '0')}:${alert.timestamp.minute.toString().padLeft(2, '0')}',
                Icons.access_time_rounded),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Close',
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final scaffoldMessenger =
                            ScaffoldMessenger.of(sheetContext);
                        Navigator.pop(sheetContext);
                        await HapticFeedback.mediumImpact();
                        try {
                          await ref
                              .read(adminOpsRepositoryProvider)
                              .acknowledgeEmergencyAlert(alert.id);
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('SOS emergency alert acknowledged.'),
                                ],
                              ),
                              backgroundColor: AppColors.brandGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Error acknowledging alert: $e'),
                              backgroundColor: AppColors.dangerRed,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerRed,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Acknowledge SOS',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String desc, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.brandGreenMid),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(desc,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  void _showAdminQuickMenu(
    BuildContext context,
    UserRole actualRole,
    UserRole effectiveRole,
    UserRole? impersonatedRole,
    String userName,
  ) {
    final isSuperAdmin = actualRole == UserRole.superAdmin ||
        actualRole == UserRole.founderAdmin ||
        actualRole == UserRole.admin;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag pill
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title and user info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: AppColors.brandGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Console & Quick Actions',
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$userName • ${effectiveRole.roleLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                    splashRadius: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 14),

              // 1. Role Switcher / Impersonator (if admin)
              if (isSuperAdmin)
                _buildQuickMenuItem(
                  sheetContext: sheetContext,
                  icon: Iconsax.profile_2user,
                  iconColor: impersonatedRole != null
                      ? AppColors.warningYellow
                      : const Color(0xFF6366F1),
                  bgColor: impersonatedRole != null
                      ? AppColors.warningYellow.withValues(alpha: 0.12)
                      : const Color(0xFF6366F1).withValues(alpha: 0.1),
                  title: 'Switch Role & Preview Mode',
                  subtitle: impersonatedRole != null
                      ? 'Previewing as ${impersonatedRole.roleLabel}'
                      : 'Simulate Customer, Driver, Tech, Dispatcher',
                  badge: impersonatedRole != null ? 'ACTIVE' : null,
                  badgeColor: AppColors.warningYellow,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    AdminRoleSwitcherSheet.show(context);
                  },
                ),

              // 2. Unified Settings
              _buildQuickMenuItem(
                sheetContext: sheetContext,
                icon: Iconsax.setting_2,
                iconColor: const Color(0xFF0284C7),
                bgColor: const Color(0xFF0284C7).withValues(alpha: 0.1),
                title: 'System & App Settings',
                subtitle: 'Preferences, security, notifications & profile',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/settings');
                },
              ),

              // 3. Notification Center
              _buildQuickMenuItem(
                sheetContext: sheetContext,
                icon: Iconsax.notification,
                iconColor: const Color(0xFFEA580C),
                bgColor: const Color(0xFFEA580C).withValues(alpha: 0.1),
                title: 'Notifications & Alerts',
                subtitle: 'Real-time alerts, operational tickets & approvals',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/notifications');
                },
              ),

              // 4. Audit Log
              _buildQuickMenuItem(
                sheetContext: sheetContext,
                icon: Iconsax.shield_tick,
                iconColor: AppColors.brandGreen,
                bgColor: AppColors.brandGreen.withValues(alpha: 0.1),
                title: 'Audit & Compliance Logs',
                subtitle: 'Immutable record of administrative operations',
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/admin-audit-log');
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required BuildContext sheetContext,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (badgeColor ?? AppColors.brandGreen)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: badgeColor ?? AppColors.brandGreen,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final userState = ref.watch(userProvider);
    final actualRole = userState.user?.role ?? UserRole.admin;
    final effectiveRole = ref.watch(effectiveAdminRoleProvider);
    final impersonatedRole = ref.watch(impersonatedRoleProvider);
    final config = RoleDashboardConfig.forRole(effectiveRole);
    final userName = userState.user?.name ?? 'Admin';
    final firstName = userName.split(' ')[0];
    final imageUrl = userState.profileImageUrl;

    // Scoped provider subscriptions — only subscribe streams this role needs.
    final liveMetricsAsync = ref.watch(adminLiveMetricsStreamProvider);
    final liveMetrics = liveMetricsAsync.valueOrNull ?? AdminLiveMetrics();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F8FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 70,
        title: Row(
          children: [
            // Enhanced Avatar with active beacon
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.brandGreen, AppColors.brandGreenLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandGreen.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildAvatarFallback(firstName),
                            )
                          : _buildAvatarFallback(firstName),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.successDark,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.greeting} $firstName',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: config.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          config.roleLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: config.accentColor,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Realtime Ops',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Notifications button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/notifications');
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Iconsax.notification,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.dangerRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 3-Dot (Kebab Menu) Button — Opens Consolidated Admin Quick Actions
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: impersonatedRole != null
                  ? AppColors.warningYellow.withValues(alpha: 0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: impersonatedRole != null
                    ? AppColors.warningYellow
                    : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showAdminQuickMenu(
                    context,
                    actualRole,
                    effectiveRole,
                    impersonatedRole,
                    userName,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: impersonatedRole != null
                        ? AppColors.warningYellow
                        : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: ResponsiveLayout.responsivePadding(context,
            horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Impersonation Active Banner
            if (impersonatedRole != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.visibility_rounded,
                        size: 18, color: Color(0xFFD97706)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Previewing as ${effectiveRole.roleLabel} • Testing mode',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(impersonatedRoleProvider.notifier).state = null;
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Exit Preview',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().shake(offset: const Offset(2, 0)),

            // Read-only role banner
            if (config.isReadOnly && impersonatedRole == null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF475569).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF475569).withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 16, color: Color(0xFF475569)),
                    SizedBox(width: 10),
                    Text(
                      'View-only mode — no write actions available in this role.',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569)),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

            // Zone Selector for Ops & Territorial Managers
            if (effectiveRole == UserRole.opsHead ||
                effectiveRole == UserRole.cityManager ||
                effectiveRole == UserRole.areaManager ||
                effectiveRole == UserRole.superAdmin ||
                effectiveRole == UserRole.founderAdmin) ...[
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Operational Territory',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  ZoneFilterDropdown(),
                ],
              ),
              const SizedBox(height: 14),
              const PredictiveHeatmapCard(),
              const SizedBox(height: 18),
            ],

            // Emergency Alerts Section — only for roles that need it
            if (config.subscribeEmergencies)
            ref.watch(emergencyAlertsProvider).when(
                  data: (alerts) {
                    if (alerts.isEmpty) return const SizedBox.shrink();
                    final latest = alerts.first;
                    final shortUserId = latest.userId.length > 8
                        ? latest.userId.substring(0, 8).toUpperCase()
                        : latest.userId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          _showEmergencyAlertDetails(latest);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.dangerRed.withValues(alpha: 0.12),
                                Colors.white
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.dangerRed, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.dangerRed.withValues(alpha: 0.15),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const _AnimatedEmergencyIcon(),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('🚨 SOS EMERGENCY',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.dangerRed,
                                                fontSize: 15)),
                                        Text(
                                            '${latest.timestamp.hour.toString().padLeft(2, '0')}:${latest.timestamp.minute.toString().padLeft(2, '0')}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textMuted)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('User: $shortUserId',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    Text(latest.message,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: AppColors.dangerRed),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .shimmer(duration: 2.seconds, color: Colors.white24)
                        .shake(offset: const Offset(2, 0));
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (e, s) => const SizedBox.shrink(),
                ),

            // High-Tech Telemetry & System Health Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandGreen.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Subtle ambient top gradient
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 4,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.brandGreenLight,
                              AppColors.brandGreen,
                              AppColors.brandGreenMid,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.brandGreenBg,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Iconsax.activity,
                                      color: AppColors.brandGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'System Telemetry',
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Central Fleet Health',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.successDark
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.successDark
                                        .withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: AppColors.successDark,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                        .animate(
                                            onPlay: (controller) =>
                                                controller.repeat())
                                        .fadeIn(duration: 700.ms)
                                        .fadeOut(duration: 700.ms),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Live Realtime',
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.successDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Custom Gradient Progress Bar
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final healthRatio =
                                  (liveMetrics.systemHealthPercent / 100.0)
                                      .clamp(0.05, 1.0);
                              return Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    width: constraints.maxWidth,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  Container(
                                    height: 8,
                                    width: constraints.maxWidth * healthRatio,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF34D399),
                                          AppColors.brandGreen,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.brandGreen
                                              .withValues(alpha: 0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      size: 14, color: AppColors.successDark),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${liveMetrics.systemHealthPercent.toStringAsFixed(0)}% Operational',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Iconsax.car,
                                      size: 14, color: AppColors.brandGreenMid),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${liveMetrics.onlineDrivers} / ${liveMetrics.totalDrivers > 0 ? liveMetrics.totalDrivers : 1} Drivers Online',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.1, end: 0).fadeIn(),

            const SizedBox(height: 18),

            // Stat Cards Grid — filtered by role permissions
            if (config.sections.contains(DashboardSection.statCards))
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.32,
              children: [
                // Revenue — only for finance-capable roles
                if (effectiveRole.canAccessFinancials)
                  _buildExecutiveStatCard(
                    title: 'Total Revenue',
                    value: liveMetrics.formattedRevenue,
                    icon: Iconsax.wallet_3,
                    accentColor: const Color(0xFF059669),
                    bgGradient: [
                      const Color(0xFF059669).withValues(alpha: 0.06),
                      Colors.white
                    ],
                    badgeText: '+8.4%',
                    isStreamActive: true,
                    // Read-only roles: no navigation onTap
                    onTap: config.isReadOnly
                        ? null
                        : () => context.push('/admin-revenue-referral'),
                  ),
                // Active Rides — ops roles only
                if (!effectiveRole.canAccessFinancials || effectiveRole.canDispatch)
                  _buildExecutiveStatCard(
                    title: 'Active Rides',
                    value: '${liveMetrics.activeRides}',
                    icon: Iconsax.routing_2,
                    accentColor: const Color(0xFF0284C7),
                    bgGradient: [
                      const Color(0xFF0284C7).withValues(alpha: 0.06),
                      Colors.white
                    ],
                    badgeText: 'Live Stream',
                    isStreamActive: true,
                    onTap: config.isReadOnly
                        ? null
                        : () => context.push('/admin-active-rides'),
                  ),
                // Pending Services — dispatch-capable roles
                if (effectiveRole.canDispatch)
                  _buildExecutiveStatCard(
                    title: 'Pending Services',
                    value: '${liveMetrics.pendingServices}',
                    icon: Iconsax.setting_4,
                    accentColor: const Color(0xFFD97706),
                    bgGradient: [
                      const Color(0xFFD97706).withValues(alpha: 0.06),
                      Colors.white
                    ],
                    badgeText: liveMetrics.pendingServices > 0 ? 'Action Req' : 'Optimal',
                    isStreamActive: true,
                    onTap: config.isReadOnly
                        ? null
                        : () => context.push('/admin-service-dispatch'),
                  ),
                // KYC Approvals — approval-capable roles
                if (effectiveRole.canApprove)
                  _buildExecutiveStatCard(
                    title: 'KYC Approvals',
                    value: '${liveMetrics.pendingKycApprovals}',
                    icon: Iconsax.shield_tick,
                    accentColor: const Color(0xFF4F46E5),
                    bgGradient: [
                      const Color(0xFF4F46E5).withValues(alpha: 0.06),
                      Colors.white
                    ],
                    badgeText: 'Review >',
                    isStreamActive: true,
                    onTap: config.isReadOnly
                        ? null
                        : () => context.push('/admin-approvals'),
                  ),
              ],
            ).animate(delay: 100.ms).slideY(begin: 0.1, end: 0).fadeIn(),

            // Interactive Analytics Chart Section for Analytics / Finance / SuperAdmin
            if (effectiveRole.canAccessAnalytics) ...
              [
                const SizedBox(height: 22),
                const AnalyticsChartSection(),
              ],

            // Finance-specific section
            if (config.sections.contains(DashboardSection.financeSection)) ...
              [
                const SizedBox(height: 22),
                FinanceDashboardSection(
                  totalRevenue: liveMetrics.formattedRevenue,
                  pendingServices: liveMetrics.pendingServices,
                ),
              ],

            // Support-specific section
            if (config.sections.contains(DashboardSection.supportSection)) ...
              [
                const SizedBox(height: 22),
                const SupportDashboardSection(),
              ],

            // Marketing-specific section
            if (config.sections.contains(DashboardSection.marketingSection)) ...
              [
                const SizedBox(height: 22),
                const MarketingDashboardSection(),
              ],

            // Audit/Analytics section
            if (config.sections.contains(DashboardSection.auditSection)) ...
              [
                const SizedBox(height: 22),
                const AuditDashboardSection(),
              ],

            // Ops Overview — full admin + ops roles only
            if (config.sections.contains(DashboardSection.opsOverview)) ...
              [
                const SizedBox(height: 22),
                const _AdminOpsThreeCardSection(),
              ],

            const SizedBox(height: 24),

            // Quick Actions — role-gated tiles
            if (config.sections.contains(DashboardSection.quickActions)) ...
              [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Access',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Core Modules',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    if (effectiveRole.canAccessFinancials)
                      _QuickActionCard(
                        title: 'Revenue Hub',
                        subtitle: 'Analytics & Payouts',
                        icon: Iconsax.chart_2,
                        color: const Color(0xFF0D9488),
                        onTap: config.isReadOnly
                            ? null
                            : () => context.push('/admin-revenue-referral'),
                      ),
                    if (effectiveRole.canDispatch)
                      _QuickActionCard(
                        title: 'Rides Map',
                        subtitle: 'Real-time Telemetry',
                        icon: Iconsax.map_1,
                        color: const Color(0xFF0284C7),
                        onTap: () => context.push('/admin-active-rides'),
                      ),
                    if (effectiveRole.canDispatch)
                      _QuickActionCard(
                        title: 'Logistics',
                        subtitle: 'Hub Operations',
                        icon: Iconsax.box_1,
                        color: const Color(0xFFD97706),
                        onTap: () => context.push('/admin-logistics-hub'),
                      ),
                    if (effectiveRole == UserRole.superAdmin ||
                        effectiveRole == UserRole.founderAdmin ||
                        effectiveRole == UserRole.opsHead ||
                        effectiveRole == UserRole.cityManager)
                      _QuickActionCard(
                        title: 'B2B Fleet',
                        subtitle: 'Corporate SLA Portals',
                        icon: Iconsax.building,
                        color: const Color(0xFF059669),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const B2BFleetPortalScreen(),
                          ),
                        ),
                      ),
                    if (effectiveRole.canManageSystem)
                      _QuickActionCard(
                        title: 'Permissions',
                        subtitle: 'Staff Roles & RBAC',
                        icon: Iconsax.security_user,
                        color: const Color(0xFF4F46E5),
                        onTap: () => context.push('/admin-management'),
                      ),
                    if (effectiveRole.canApprove)
                      _QuickActionCard(
                        title: 'Approvals',
                        subtitle: 'Maker Checker',
                        icon: Iconsax.task_square,
                        color: const Color(0xFF10B981),
                        onTap: config.isReadOnly
                            ? null
                            : () => context.push('/admin-approvals'),
                      ),
                    if (effectiveRole.canHandleSupport)
                      _QuickActionCard(
                        title: 'Feedback',
                        subtitle: 'User Sentiments',
                        icon: Iconsax.messages_1,
                        color: const Color(0xFFE11D48),
                        onTap: () => context.push('/admin-feedback-analytics'),
                      ),
                    if (effectiveRole.canAccessMarketing)
                      _QuickActionCard(
                        title: 'Offers & Deals',
                        subtitle: 'Coupons & Promos',
                        icon: Iconsax.discount_shape,
                        color: const Color(0xFFF59E0B),
                        onTap: config.isReadOnly
                            ? null
                            : () => context.push('/admin-manage-offers'),
                      ),
                    if (effectiveRole.canAccessAudit)
                      _QuickActionCard(
                        title: 'Audit Logs',
                        subtitle: 'Compliance Trail',
                        icon: Iconsax.document_text,
                        color: const Color(0xFF475569),
                        onTap: () => context.push('/admin/audit-logs'),
                      ),
                  ],
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              ],

            // Fleet & Operations Control — dispatch roles only
            if (config.sections.contains(DashboardSection.fleetControl)) ...
              [
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fleet & Operations Control',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Control Unit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                  children: [
                    _QuickActionCard(
                      title: 'Service Dispatch',
                      subtitle: 'Tech Allocation',
                      icon: Iconsax.truck_fast,
                      color: const Color(0xFF059669),
                      onTap: effectiveRole.canDispatch
                          ? () => context.push('/admin-service-dispatch')
                          : null,
                    ),
                    _QuickActionCard(
                      title: 'Disputes & Claims',
                      subtitle: 'Refund Center',
                      icon: Iconsax.judge,
                      color: const Color(0xFFDC2626),
                      onTap: () => context.push('/admin-disputes'),
                    ),
                    _QuickActionCard(
                      title: 'Fleet Health',
                      subtitle: 'Battery & Assets',
                      icon: Iconsax.car,
                      color: const Color(0xFF0284C7),
                      onTap: () => context.push('/admin-assets'),
                    ),
                    _QuickActionCard(
                      title: 'Live Radar',
                      subtitle: 'GPS Triangulation',
                      icon: Iconsax.radar_2,
                      color: const Color(0xFF0D9488),
                      onTap: () => context.push('/admin-active-rides'),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
              ],

            // S5 Fix: Removed hardcoded fake 'Bandra zone' system alert.
            // Real operational alerts should come from a Supabase stream.
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    return Container(
      color: AppColors.brandGreenBg,
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.brandGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
    required List<Color> bgGradient,
    required String badgeText,
    bool isStreamActive = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: accentColor, size: 18),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isStreamActive)
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 800.ms).fadeOut(duration: 800.ms),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
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

class _AdminOpsThreeCardSection extends StatelessWidget {
  const _AdminOpsThreeCardSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 900;
        final double cardWidth =
            isWide ? (constraints.maxWidth / 3) - 16 : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(width: cardWidth, child: const _CustomerOperationsCard()),
            SizedBox(width: cardWidth, child: const _DriverManagementCard()),
            SizedBox(width: cardWidth, child: const _TechnicianServicesCard()),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 1. CUSTOMER OPERATIONS CARD (REVAMPED)
// -----------------------------------------------------------------------------
class _CustomerOperationsCard extends ConsumerWidget {
  const _CustomerOperationsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(customersOpProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.profile_2user,
                        color: Color(0xFF0284C7), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Customers',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Active Pipeline',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.brandGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          asyncData.when(
            loading: () => const ShimmerListPlaceholder(itemCount: 1),
            error: (e, s) => const Text('Error loading customer ops',
                style: TextStyle(color: Colors.red)),
            data: (data) => Column(
              children: [
                // Metric Pills Row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEEF2F6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPillMetric('Active', data.activeBookings.toString(),
                          const Color(0xFF0284C7)),
                      Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                      _buildPillMetric('Rentals', data.activeRentals.toString(),
                          AppColors.brandGreen),
                      Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                      _buildPillMetric('Services', data.activeServices.toString(),
                          const Color(0xFFD97706)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (data.recentRides.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No recent customer activity',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.recentRides.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, i) {
                      final ride = data.recentRides[i];
                      final shortRideId = ride.id.length > 6
                          ? ride.id.substring(0, 6).toUpperCase()
                          : ride.id;
                      final shortCustId = ride.customer.length > 6
                          ? ride.customer.substring(0, 6).toUpperCase()
                          : ride.customer;
                      final isCompleted =
                          ride.status.toLowerCase().contains('complete');
                      final isActive =
                          ride.status.toLowerCase().contains('active');

                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.receipt_item,
                                size: 15, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order #$shortRideId • Cust: $shortCustId',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${ride.vehicle} • ${ride.time}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFECFDF5)
                                  : isCompleted
                                      ? const Color(0xFFF0FDF4)
                                      : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isActive
                                    ? const Color(0xFFA7F3D0)
                                    : isCompleted
                                        ? const Color(0xFFBBF7D0)
                                        : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Text(
                              ride.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                color: isActive
                                    ? AppColors.brandGreen
                                    : isCompleted
                                        ? const Color(0xFF16A34A)
                                        : AppColors.textSecondary,
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/admin-customer-database'),
              icon: const Icon(Iconsax.arrow_right_3, size: 14),
              label: const Text('View All Customers',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandGreen,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. DRIVER MANAGEMENT CARD (REVAMPED)
// -----------------------------------------------------------------------------
class _DriverManagementCard extends ConsumerWidget {
  const _DriverManagementCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(driversOpProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreenBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.car,
                        color: AppColors.brandGreen, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Drivers',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'KYC Queue',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          asyncData.when(
            loading: () => const ShimmerListPlaceholder(itemCount: 1),
            error: (e, s) => const Text('Error loading driver ops',
                style: TextStyle(color: Colors.red)),
            data: (data) => Column(
              children: [
                // Metric Pills Row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEEF2F6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPillMetric('Online', data.online.toString(),
                          AppColors.brandGreen),
                      Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                      _buildPillMetric('Pending', data.pending.toString(),
                          const Color(0xFFD97706)),
                      Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                      _buildPillMetric('Total', data.total.toString(),
                          AppColors.textPrimary),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (data.topPending.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No pending driver approvals',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.topPending.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, i) {
                      final driver = data.topPending[i];
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Iconsax.user_tag,
                                size: 15, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.name,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Docs: ${driver.docsCount}/4 • ${driver.uploadDate}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandGreen,
                              minimumSize: const Size(64, 30),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () => ref
                                .read(adminOpsRepositoryProvider)
                                .approveDriver(driver.id),
                            child: const Text('Approve',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/admin-driver-database'),
              icon: const Icon(Iconsax.verify, size: 14, color: Colors.white),
              label: const Text('Verify All Documents',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 3. TECHNICIAN SERVICES CARD (REVAMPED)
// -----------------------------------------------------------------------------
class _TechnicianServicesCard extends ConsumerWidget {
  const _TechnicianServicesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(techOpProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.setting_2,
                        color: Color(0xFFD97706), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Technicians',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              asyncData.when(
                loading: () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('Jobs Queue',
                      style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary)),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (data) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: data.pending > 0
                        ? const Color(0xFFD97706).withValues(alpha: 0.1)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.pending > 0 ? '${data.pending} Active' : 'No Queue',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: data.pending > 0
                          ? const Color(0xFFD97706)
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          asyncData.when(
            loading: () => const ShimmerListPlaceholder(itemCount: 1),
            error: (e, s) => const Text('Error loading tech ops',
                style: TextStyle(color: Colors.red)),
            data: (data) => Column(
              children: [
                // Metric Pills Row
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEEF2F6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildPillMetric('In Service', data.inService.toString(),
                          const Color(0xFFD97706)),
                      Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                      _buildPillMetric('Progress', data.progress.toString(),
                          const Color(0xFF0284C7)),
                      Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                      _buildPillMetric('Done', data.completed.toString(),
                          AppColors.brandGreen),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (data.recentServices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No active technician jobs',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.recentServices.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 16, color: Color(0xFFF1F5F9)),
                    itemBuilder: (context, i) {
                      final job = data.recentServices[i];
                      final isActive = job.status == 'IN PROGRESS' || job.status == 'ACCEPTED';
                      final isScheduled = job.status == 'SCHEDULED';
                      final isDone = job.status == 'COMPLETED';
                      final statusColor = isActive
                          ? const Color(0xFF0284C7)
                          : isScheduled
                              ? const Color(0xFFD97706)
                              : isDone
                                  ? AppColors.brandGreen
                                  : AppColors.textSecondary;
                      final statusBg = statusColor.withValues(alpha: 0.08);
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Iconsax.ticket,
                                size: 15, color: statusColor),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  job.regNo,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tech: ${job.tech} • ${job.timeLabel}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (job.invoiceAmount > 0)
                                Text(
                                  '₹${job.invoiceAmount.toInt()}',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: AppColors.brandGreen,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  job.status.replaceAll('_', ' '),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/admin-service-dispatch'),
                    icon: const Icon(Iconsax.truck_fast, size: 14,
                        color: Colors.white),
                    label: const Text('Dispatch',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/admin-technician-database'),
                    icon: const Icon(Iconsax.receipt_2, size: 14),
                    label: const Text('Invoices',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandGreen,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _AnimatedEmergencyIcon extends StatefulWidget {
  const _AnimatedEmergencyIcon();
  @override
  State<_AnimatedEmergencyIcon> createState() => _AnimatedEmergencyIconState();
}

class _AnimatedEmergencyIconState extends State<_AnimatedEmergencyIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.dangerRed
                .withValues(alpha: 0.1 + (_controller.value * 0.2)),
            shape: BoxShape.circle,
            border: Border.all(
                color: AppColors.dangerRed.withValues(alpha: _controller.value),
                width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.dangerRed
                    .withValues(alpha: 0.3 * _controller.value),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(Icons.error_outline_rounded,
              color: AppColors.dangerRed, size: 24),
        );
      },
    );
  }
}
