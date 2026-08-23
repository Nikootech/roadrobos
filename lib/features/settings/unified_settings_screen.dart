import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/models/user_role.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/services/biometric_service.dart';
import '../../core/theme/app_colors.dart';
import '../profile/user_provider.dart';

/// Unified Settings Screen — works for all user roles:
/// Customer, Driver, Technician, Admin (and all admin variants).
class UnifiedSettingsScreen extends ConsumerStatefulWidget {
  const UnifiedSettingsScreen({super.key});

  @override
  ConsumerState<UnifiedSettingsScreen> createState() =>
      _UnifiedSettingsScreenState();
}

class _UnifiedSettingsScreenState extends ConsumerState<UnifiedSettingsScreen> {
  bool _isBiometricEnabled = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _isBiometricEnabled = prefs.getBool('biometric_enabled') ?? false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final messenger = ScaffoldMessenger.of(context);
    final biometricService = ref.read(biometricServiceProvider);

    if (value) {
      final available = await biometricService.isAvailable();
      if (!available) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text(
                'Biometric authentication is not available on this device.'),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool('biometric_enabled', value);
    setState(() => _isBiometricEnabled = value);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
            value ? 'Biometric login enabled.' : 'Biometric login disabled.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out?',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
        ),
        content: const Text(
            'You will be returned to the login screen. All local preferences are preserved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out',
                style: TextStyle(
                    color: AppColors.dangerRed, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _isLoggingOut = true);
      await ref.read(userProvider.notifier).logout();
    }
  }

  Future<void> _requestDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Request Account Deletion?',
          style: GoogleFonts.outfit(
              color: AppColors.dangerRed, fontWeight: FontWeight.w800),
        ),
        content: const Text(
            'This will flag your account for permanent deletion by an admin. This action cannot be undone once processed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Deletion',
                style: TextStyle(
                    color: AppColors.dangerRed, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(userProvider.notifier).deleteAccountRequest();
      if (mounted) GoRouter.of(context).go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.user;
    final role = user?.role ?? UserRole.customer;
    final themeMode = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);

    final isAdmin = role.isAdmin;
    final isDriver = role == UserRole.driver;
    final isTechnician = role == UserRole.technician;
    final isCustomer = role == UserRole.customer;

    // Role display info
    final roleLabel = _roleLabel(role);
    final roleColor = _roleColor(role);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 15, color: AppColors.textPrimary),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.outfit(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: _isLoggingOut
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [
                // ── Profile Header ─────────────────────────────────────────
                _buildProfileHeader(userState, roleLabel, roleColor)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.06, end: 0),

                const SizedBox(height: 20),

                // ── Account ────────────────────────────────────────────────
                _buildSection('ACCOUNT', [
                  _buildTile(
                    icon: Iconsax.personalcard,
                    color: const Color(0xFF3B82F6),
                    title: 'Edit Profile',
                    subtitle: userState.name,
                    onTap: () => context.push('/account-settings'),
                  ),
                  _buildDivider(),
                  if (isCustomer || isDriver || isTechnician) ...[
                    _buildTile(
                      icon: Iconsax.notification,
                      color: const Color(0xFFF59E0B),
                      title: 'Notification Preferences',
                      subtitle: 'Push, email, SMS, WhatsApp',
                      onTap: () => context.push('/notification-settings'),
                    ),
                    _buildDivider(),
                  ],
                  if (isCustomer) ...[
                    _buildTile(
                      icon: Iconsax.location,
                      color: const Color(0xFF10B981),
                      title: 'Saved Locations',
                      subtitle: 'Home, office, and more',
                      onTap: () => context.push('/saved-locations'),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Iconsax.car,
                      color: const Color(0xFF8B5CF6),
                      title: 'My Vehicles',
                      subtitle: 'Vehicle details and RC documents',
                      onTap: () => context.push('/my-vehicles'),
                    ),
                    _buildDivider(),
                  ],
                  if (isAdmin) ...[
                    _buildTile(
                      icon: Iconsax.notification,
                      color: const Color(0xFFF59E0B),
                      title: 'Notification Preferences',
                      subtitle: 'Push, email, SMS, WhatsApp',
                      onTap: () => context.push('/notification-settings'),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Iconsax.shield_tick,
                      color: const Color(0xFF6366F1),
                      title: 'Admin Permissions',
                      subtitle: 'Role — $roleLabel',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          roleLabel,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Iconsax.activity,
                      color: const Color(0xFF0EA5E9),
                      title: 'Audit Logs',
                      subtitle: 'View your admin activity trail',
                      onTap: () => context.push('/admin/audit-logs'),
                    ),
                    _buildDivider(),
                  ],
                  if (isDriver) ...[
                    _buildTile(
                      icon: Iconsax.document_text,
                      color: const Color(0xFF10B981),
                      title: 'My Documents',
                      subtitle: 'License, RC book, and KYC uploads',
                      onTap: () => context.push('/driver-profile'),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Iconsax.wallet_money,
                      color: const Color(0xFFD97706),
                      title: 'Earnings & Wallet',
                      subtitle: 'Payouts, history, and withdrawals',
                      onTap: () => context.push('/driver-earnings'),
                    ),
                    _buildDivider(),
                  ],
                  if (isTechnician) ...[
                    _buildTile(
                      icon: Iconsax.document_text,
                      color: const Color(0xFF10B981),
                      title: 'My Certifications',
                      subtitle: 'Upload training and skill docs',
                      onTap: () => context.push('/tech-profile'),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Iconsax.wallet_money,
                      color: const Color(0xFFD97706),
                      title: 'Earnings',
                      subtitle: 'Payouts, history, and withdrawals',
                      onTap: () => context.push('/tech-earnings'),
                    ),
                    _buildDivider(),
                  ],
                ]).animate().fadeIn(duration: 300.ms, delay: 60.ms),

                const SizedBox(height: 16),

                // ── Security ───────────────────────────────────────────────
                _buildSection('SECURITY', [
                  _buildTile(
                    icon: Iconsax.lock,
                    color: const Color(0xFFEF4444),
                    title: 'Change Password',
                    subtitle: 'Update your login credentials',
                    onTap: () => context.push('/account-settings'),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Iconsax.finger_scan,
                    color: const Color(0xFF8B5CF6),
                    title: 'Biometric Login',
                    subtitle: 'Fingerprint or Face ID unlock',
                    value: _isBiometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
                  _buildDivider(),
                  _buildTile(
                    icon: Iconsax.shield,
                    color: const Color(0xFF0EA5E9),
                    title: 'Two-Factor Authentication',
                    subtitle: userState.mfaEnabled
                        ? 'Active — extra login protection'
                        : 'Add an extra security layer',
                    trailing: userState.mfaEnabled
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.brandGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ON',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.brandGreen,
                              ),
                            ),
                          )
                        : null,
                    onTap: () => context.push('/account-settings'),
                  ),
                ]).animate().fadeIn(duration: 300.ms, delay: 120.ms),

                const SizedBox(height: 16),

                // ── Appearance ─────────────────────────────────────────────
                _buildSection('APPEARANCE', [
                  _buildTile(
                    icon: themeNotifier.currentIcon,
                    color: const Color(0xFF6366F1),
                    title: 'App Theme',
                    subtitle: '${themeNotifier.currentLabel} Mode',
                    trailing: _ThemeToggleChip(themeMode: themeMode),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      themeNotifier.toggleThemeMode();
                    },
                  ),
                ]).animate().fadeIn(duration: 300.ms, delay: 180.ms),

                const SizedBox(height: 16),

                // ── Support ────────────────────────────────────────────────
                _buildSection('SUPPORT & LEGAL', [
                  _buildTile(
                    icon: Iconsax.message_question,
                    color: const Color(0xFF0EA5E9),
                    title: 'Help & Support',
                    subtitle: 'FAQs, chat, and contact us',
                    onTap: () => context.push('/help-center'),
                  ),
                  _buildDivider(),
                  _buildTile(
                    icon: Iconsax.security_safe,
                    color: const Color(0xFF10B981),
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  _buildDivider(),
                  _buildTile(
                    icon: Iconsax.document,
                    color: const Color(0xFFF59E0B),
                    title: 'Terms of Service',
                    subtitle: 'Read our terms and conditions',
                    onTap: () => context.push('/terms-of-service'),
                  ),
                  _buildDivider(),
                  _buildTile(
                    icon: Iconsax.info_circle,
                    color: const Color(0xFF94A3B8),
                    title: 'App Version',
                    subtitle: 'RoadRobos v2.4.1 (Build 241)',
                  ),
                ]).animate().fadeIn(duration: 300.ms, delay: 240.ms),

                const SizedBox(height: 24),

                // ── Sign Out ───────────────────────────────────────────────
                _buildSignOutButton()
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 300.ms),

                const SizedBox(height: 8),

                // ── Delete Account ─────────────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: _requestDeleteAccount,
                    child: Text(
                      'Delete Account',
                      style: TextStyle(
                        color: AppColors.dangerRed.withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: 360.ms),
              ],
            ),
    );
  }

  // ── Helper Widgets ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader(
      UserState state, String roleLabel, Color roleColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.brandGreen.withValues(alpha: 0.1),
            backgroundImage: state.profileImageUrl.isNotEmpty
                ? NetworkImage(state.profileImageUrl)
                : null,
            child: state.profileImageUrl.isEmpty
                ? Text(
                    state.name.isNotEmpty ? state.name[0].toUpperCase() : 'U',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandGreen,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.name,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.email.isNotEmpty ? state.email : state.phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: roleColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              roleLabel,
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.025),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.textMuted)
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.brandGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 66),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Iconsax.logout, size: 18),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dangerRed,
          side: BorderSide(color: AppColors.dangerRed.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.founderAdmin:
        return 'Founder';
      case UserRole.opsHead:
        return 'Ops Head';
      case UserRole.cityManager:
        return 'City Manager';
      case UserRole.areaManager:
        return 'Area Manager';
      case UserRole.financeManager:
        return 'Finance Manager';
      case UserRole.supportManager:
        return 'Support Manager';
      case UserRole.marketingAdmin:
        return 'Marketing Admin';
      case UserRole.auditor:
        return 'Auditor';
      case UserRole.analyst:
        return 'Analyst';
      case UserRole.admin:
        return 'Admin';
      case UserRole.driver:
        return 'Driver';
      case UserRole.technician:
        return 'Technician';
      case UserRole.customer:
        return 'Customer';
    }
  }

  Color _roleColor(UserRole role) {
    if (role.isAdmin) return const Color(0xFF6366F1);
    if (role == UserRole.driver) return const Color(0xFF0EA5E9);
    if (role == UserRole.technician) return const Color(0xFFF59E0B);
    return AppColors.brandGreen;
  }
}

/// Small animated theme mode chip shown in the Appearance tile.
class _ThemeToggleChip extends StatelessWidget {
  final ThemeMode themeMode;

  const _ThemeToggleChip({required this.themeMode});

  @override
  Widget build(BuildContext context) {
    final label = switch (themeMode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      ThemeMode.system => 'System',
    };
    final color = switch (themeMode) {
      ThemeMode.light => const Color(0xFFF59E0B),
      ThemeMode.dark => const Color(0xFF6366F1),
      ThemeMode.system => const Color(0xFF0EA5E9),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
