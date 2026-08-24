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
import '../../shared/widgets/react_switch.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/sos_button.dart';
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
            content: Text(
              'Biometric authentication is not available on this device.',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFE11D48),
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
          value ? 'Biometric login enabled.' : 'Biometric login disabled.',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF006241),
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
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'You will be returned to the login screen. All local preferences are preserved.',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Sign Out',
              style: GoogleFonts.inter(
                color: const Color(0xFFE11D48),
                fontWeight: FontWeight.w800,
              ),
            ),
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
              color: const Color(0xFFE11D48), fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This will flag your account for permanent deletion by an admin. This action cannot be undone once processed.',
          style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Confirm Deletion',
                style: GoogleFonts.inter(
                    color: const Color(0xFFE11D48),
                    fontWeight: FontWeight.w900)),
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        leading: Center(
          child: ScaleOnTap(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'Settings',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Preferences & Account Controls',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: SOSButton.headerPill(
              rideDetails: 'Settings & Security',
            ),
          ),
        ],
      ),
      body: _isLoggingOut
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF006241)))
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // ── Profile Summary Card ───────────────────────────────────
                _buildProfileHeader(userState, roleLabel, roleColor),

                const SizedBox(height: 18),

                // ── Account & Preferences ──────────────────────────────────
                _buildSection('ACCOUNT & PREFERENCES', [
                  _buildTile(
                    icon: Iconsax.personalcard,
                    color: const Color(0xFF0284C7),
                    title: 'Edit Profile',
                    subtitle: userState.name.isNotEmpty
                        ? userState.name
                        : 'Update personal details',
                    onTap: () => context.push('/account-settings'),
                  ),
                  _buildDivider(),
                  if (isCustomer || isDriver || isTechnician) ...[
                    _buildTile(
                      icon: Iconsax.notification,
                      color: const Color(0xFFD97706),
                      title: 'Notification Preferences',
                      subtitle: 'Push, email, SMS, WhatsApp',
                      onTap: () => context.push('/notification-settings'),
                    ),
                    _buildDivider(),
                  ],
                  if (isCustomer) ...[
                    _buildTile(
                      icon: Iconsax.location,
                      color: const Color(0xFF006241),
                      title: 'Saved Locations',
                      subtitle: 'Home, office, and quick access',
                      onTap: () => context.push('/saved-locations'),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Iconsax.car,
                      color: const Color(0xFF0D9488),
                      title: 'My Vehicles',
                      subtitle: 'Vehicle details & documents',
                      onTap: () => context.push('/my-vehicles'),
                    ),
                    _buildDivider(),
                  ],
                  if (isAdmin) ...[
                    _buildTile(
                      icon: Iconsax.notification,
                      color: const Color(0xFFD97706),
                      title: 'Notification Preferences',
                      subtitle: 'Push, email, SMS, WhatsApp',
                      onTap: () => context.push('/notification-settings'),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Iconsax.shield_tick,
                      color: const Color(0xFF006241),
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
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: roleColor,
                          ),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Iconsax.activity,
                      color: const Color(0xFF0284C7),
                      title: 'Audit Logs',
                      subtitle: 'View your admin activity trail',
                      onTap: () => context.push('/admin/audit-logs'),
                    ),
                    _buildDivider(),
                  ],
                  if (isDriver) ...[
                    _buildTile(
                      icon: Iconsax.document_text,
                      color: const Color(0xFF006241),
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
                      color: const Color(0xFF006241),
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
                ]).animate().fadeIn(duration: 250.ms),

                const SizedBox(height: 16),

                // ── Security & Access ──────────────────────────────────────
                _buildSection('SECURITY & ACCESS', [
                  _buildTile(
                    icon: Iconsax.lock,
                    color: const Color(0xFFE11D48),
                    title: 'Change Password',
                    subtitle: 'Update your login credentials',
                    onTap: () => context.push('/account-settings'),
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Iconsax.finger_scan,
                    color: const Color(0xFF0D9488),
                    title: 'Biometric Login',
                    subtitle: 'Fingerprint or Face ID unlock',
                    value: _isBiometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
                ]).animate().fadeIn(duration: 250.ms, delay: 50.ms),

                const SizedBox(height: 16),

                // ── Appearance & Theme ─────────────────────────────────────
                _buildSection('APPEARANCE & THEME', [
                  _buildTile(
                    icon: themeNotifier.currentIcon,
                    color: const Color(0xFF0284C7),
                    title: 'App Theme',
                    subtitle: '${themeNotifier.currentLabel} Mode active',
                    trailing: _ThemeToggleChip(themeMode: themeMode),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      themeNotifier.toggleThemeMode();
                    },
                  ),
                ]).animate().fadeIn(duration: 250.ms, delay: 100.ms),

                const SizedBox(height: 16),

                // ── Support & Compliance ───────────────────────────────────
                _buildSection('SUPPORT & COMPLIANCE', [
                  _buildTile(
                    icon: Iconsax.message_question,
                    color: const Color(0xFF0284C7),
                    title: 'Help & Support',
                    subtitle: 'FAQs, chat, and emergency assist',
                    onTap: () => context.push('/help-center'),
                  ),
                  _buildDivider(),
                  _buildTile(
                    icon: Iconsax.security_safe,
                    color: const Color(0xFF006241),
                    title: 'Privacy Policy',
                    subtitle: 'How we protect your telemetry',
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  _buildDivider(),
                  _buildTile(
                    icon: Iconsax.document,
                    color: const Color(0xFFD97706),
                    title: 'Terms of Service',
                    subtitle: 'Operational terms & conditions',
                    onTap: () => context.push('/terms-of-service'),
                  ),
                  _buildDivider(),
                  _buildTile(
                    icon: Iconsax.info_circle,
                    color: const Color(0xFF64748B),
                    title: 'App Version',
                    subtitle: 'RoadRobos v2.4.1 (Build 241)',
                  ),
                ]).animate().fadeIn(duration: 250.ms, delay: 150.ms),

                const SizedBox(height: 24),

                // ── Sign Out ───────────────────────────────────────────────
                _buildSignOutButton()
                    .animate()
                    .fadeIn(duration: 250.ms, delay: 200.ms),

                const SizedBox(height: 8),

                // ── Delete Account ─────────────────────────────────────────
                Center(
                  child: TextButton(
                    onPressed: _requestDeleteAccount,
                    child: Text(
                      'Delete Account',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 250.ms, delay: 250.ms),
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
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF006241), Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF006241).withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: state.profileImageUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      state.profileImageUrl,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Text(
                      state.name.isNotEmpty ? state.name[0].toUpperCase() : 'U',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.name.isNotEmpty ? state.name : 'Authenticated User',
                  style: GoogleFonts.outfit(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.phone.isNotEmpty ? state.phone : state.email,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    roleLabel,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ScaleOnTap(
            onTap: () => context.push('/account-settings'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Iconsax.edit_2,
                  size: 16, color: Color(0xFF0F172A)),
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
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
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
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
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
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: Color(0xFF94A3B8))
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
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
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ReactSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 68),
      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
    );
  }

  Widget _buildSignOutButton() {
    return ScaleOnTap(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.logout, size: 18, color: Color(0xFFE11D48)),
            const SizedBox(width: 8),
            Text(
              'Sign Out',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE11D48),
                letterSpacing: 0.2,
              ),
            ),
          ],
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
    if (role.isAdmin) return const Color(0xFF006241);
    if (role == UserRole.driver) return const Color(0xFF0284C7);
    if (role == UserRole.technician) return const Color(0xFFD97706);
    return const Color(0xFF006241);
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
      ThemeMode.light => const Color(0xFFD97706),
      ThemeMode.dark => const Color(0xFF0F172A),
      ThemeMode.system => const Color(0xFF0284C7),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Container(
        key: ValueKey(label),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ),
    );
  }
}
