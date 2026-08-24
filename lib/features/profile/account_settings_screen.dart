import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import 'user_provider.dart';
import '../../core/providers/favorites_provider.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/react_switch.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _isEditingProfile = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phone);
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
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
          const SnackBar(
            content: Text(
                'Biometric authentication is not available on this device.'),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (!mounted) return;
      final String? password = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          final controller = TextEditingController();
          final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              'Confirm Password',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please enter your RoadRobos account password to enable biometric login.',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textOnDarkMuted
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: true,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: AppColors.primaryBlue),
                    hintText: 'Enter password',
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF252B3B)
                        : AppColors.bgLightGrey,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('CANCEL',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, controller.text),
                child: const Text('CONFIRM',
                    style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );

      if (password == null || password.isEmpty) {
        return;
      }

      if (!mounted) return;
      unawaited(showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      ));

      try {
        final authService = ref.read(authServiceProvider);
        final user = ref.read(userProvider).user;
        if (user == null) throw Exception('No user profile loaded');
        final email = user.email;
        if (email == null || email.isEmpty) {
          throw Exception('No email associated with this profile');
        }

        await authService.reauthenticate(email, password);

        if (mounted) Navigator.pop(context); // Dismiss loading spinner

        final authenticated = await biometricService.authenticate(
          localizedReason: 'Confirm biometric login setup',
        );

        if (authenticated) {
          final prefs = ref.read(sharedPreferencesProvider);
          await prefs.setBool('biometric_enabled', true);
          const storage = FlutterSecureStorage();
          await storage.write(key: 'email', value: email);
          await storage.write(key: 'password', value: password);

          setState(() => _isBiometricEnabled = true);
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Biometric login enabled successfully!'),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Biometric authentication failed.'),
              backgroundColor: AppColors.dangerRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Dismiss loading spinner
        String errorMsg = e.toString();
        // Make error messages user-friendly
        if (errorMsg.contains('Invalid login credentials') ||
            errorMsg.contains('invalid_credentials') ||
            errorMsg.contains('Incorrect password')) {
          errorMsg =
              'Incorrect password. Please enter your RoadRobos account password, not your device PIN.';
        }
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('biometric_enabled', false);
      const storage = FlutterSecureStorage();
      await storage.delete(key: 'email');
      await storage.delete(key: 'password');

      setState(() => _isBiometricEnabled = false);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Biometric login disabled.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Real-time Change Password dialog ─────────────────────────────────────────

  Future<void> _showChangePasswordDialog() async {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    bool isLoading = false;
    String? errorMsg;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    final userEmail = ref.read(userProvider).user?.email ?? '';

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDS) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD97706)
                                    .withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(Iconsax.lock,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Change Password',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        ScaleOnTap(
                          onTap:
                              isLoading ? null : () => Navigator.pop(dialogCtx),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(Icons.close_rounded,
                                size: 16, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Enter your current credentials to set a new password.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Current password ───────────────────────────────────────────
                    _buildPwField(
                      controller: currentPwController,
                      label: 'Current Password',
                      obscure: obscureCurrent,
                      onToggle: () =>
                          setDS(() => obscureCurrent = !obscureCurrent),
                    ),
                    const SizedBox(height: 14),

                    // ── New password ───────────────────────────────────────────────
                    _buildPwField(
                      controller: newPwController,
                      label: 'New Password (min 8 chars)',
                      obscure: obscureNew,
                      onToggle: () => setDS(() => obscureNew = !obscureNew),
                    ),
                    const SizedBox(height: 14),

                    // ── Confirm new password ──────────────────────────────────────
                    _buildPwField(
                      controller: confirmPwController,
                      label: 'Confirm New Password',
                      obscure: obscureConfirm,
                      onToggle: () =>
                          setDS(() => obscureConfirm = !obscureConfirm),
                    ),

                    if (errorMsg != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: Color(0xFFE11D48), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMsg!,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFFE11D48),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.pop(dialogCtx),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ScaleOnTap(
                            onTap: isLoading
                                ? null
                                : () async {
                                    final currentPw =
                                        currentPwController.text.trim();
                                    final newPw = newPwController.text.trim();
                                    final confirmPw =
                                        confirmPwController.text.trim();

                                    if (currentPw.isEmpty ||
                                        newPw.isEmpty ||
                                        confirmPw.isEmpty) {
                                      setDS(() => errorMsg =
                                          'All fields are required.');
                                      return;
                                    }
                                    if (newPw.length < 8) {
                                      setDS(() => errorMsg =
                                          'New password must be at least 8 characters.');
                                      return;
                                    }
                                    if (newPw != confirmPw) {
                                      setDS(() => errorMsg =
                                          'New passwords do not match.');
                                      return;
                                    }
                                    if (newPw == currentPw) {
                                      setDS(() => errorMsg =
                                          'New password must differ from current password.');
                                      return;
                                    }

                                    setDS(() {
                                      isLoading = true;
                                      errorMsg = null;
                                    });

                                    try {
                                      final authService =
                                          ref.read(authServiceProvider);
                                      await authService.signInWithEmail(
                                          userEmail, currentPw);
                                      await authService.updatePassword(newPw);

                                      if (!dialogCtx.mounted) return;
                                      Navigator.pop(dialogCtx);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Password updated successfully! ✓',
                                            style: GoogleFonts.inter(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          backgroundColor:
                                              const Color(0xFF006241),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    } catch (e) {
                                      String msg = e.toString();
                                      if (msg.contains(
                                              'Invalid login credentials') ||
                                          msg.contains('invalid_credentials')) {
                                        msg = 'Current password is incorrect.';
                                      } else if (msg
                                          .contains('Password should be')) {
                                        msg =
                                            'New password is too weak. Use at least 8 characters.';
                                      } else if (msg
                                          .contains('same_password')) {
                                        msg =
                                            'New password must be different from current password.';
                                      }
                                      setDS(() {
                                        isLoading = false;
                                        errorMsg = msg;
                                      });
                                    }
                                  },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF006241),
                                    Color(0xFF10B981)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF006241)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.2),
                                      )
                                    : Text(
                                        'UPDATE PASSWORD',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12.5,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    currentPwController.dispose();
    newPwController.dispose();
    confirmPwController.dispose();
  }

  /// Reusable password field for Change Password dialog
  Widget _buildPwField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: GoogleFonts.inter(
            color: const Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF006241), width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final messenger = ScaffoldMessenger.of(context);

      await ref.read(userProvider.notifier).updateProfile(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
          );

      final userState = ref.read(userProvider);
      if (userState.error != null) {
        // Failure State
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${userState.error}'),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Success State
        setState(() => _isEditingProfile = false);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _updateProfilePhoto() async {
    // ignore: unawaited_futures
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change Profile Photo',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.deepNavy)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(Icons.camera_alt_rounded, 'Camera',
                    () async {
                  Navigator.pop(context);
                  await ref
                      .read(userProvider.notifier)
                      .pickAndUploadProfilePicture(ImageSource.camera);
                }),
                _buildPickerOption(Icons.photo_library_rounded, 'Gallery',
                    () async {
                  Navigator.pop(context);
                  await ref
                      .read(userProvider.notifier)
                      .pickAndUploadProfilePicture();
                }),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryBlue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditingProfile ? 'Edit Profile' : 'Account Settings',
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 18),
        ),
        actions: [
          if (_isEditingProfile)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: userState.isLoading ? null : _saveProfile,
                child: userState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Color(0xFF006241), strokeWidth: 2))
                    : Text(
                        'SAVE',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF006241),
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _isEditingProfile
            ? _buildEditProfileForm(userState)
            : _buildSettingsList(userState),
      ),
    );
  }

  Widget _buildSettingsList(UserState user) {
    return Column(
      children: [
        _buildSettingsGroup('Personal Information', [
          _buildSettingsTile(
            Iconsax.user_edit,
            'Edit Profile',
            '${user.name} • ${user.email}',
            gradient: const [Color(0xFF006241), Color(0xFF10B981)],
            onTap: () => setState(() => _isEditingProfile = true),
          ),
          _buildSettingsTile(
            Iconsax.location,
            'Saved Locations',
            'Manage home and office addresses',
            gradient: const [Color(0xFF0284C7), Color(0xFF38BDF8)],
            onTap: () => context.push('/saved-locations'),
          ),
          _buildSettingsTile(
            Iconsax.car,
            'My Vehicles',
            'Vehicle details and RC docs',
            gradient: const [Color(0xFF0D9488), Color(0xFF14B8A6)],
            onTap: () => context.push('/my-vehicles'),
          ),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Security', [
          _buildSettingsTile(
            Iconsax.lock,
            'Change Password',
            'Update your security credentials',
            gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
            onTap: _showChangePasswordDialog,
          ),
          _buildSettingsTile(
            Iconsax.finger_scan,
            'Biometric Login',
            'Enable Fingerprint/FaceID for login',
            gradient: const [Color(0xFF0F172A), Color(0xFF334155)],
            trailing: ReactSwitch(
              value: _isBiometricEnabled,
              onChanged: (val) => _toggleBiometric(val),
            ),
          ),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Legal', [
          _buildSettingsTile(
            Iconsax.shield_security,
            'Privacy Policy',
            'How we collect, use, and protect your data',
            gradient: const [Color(0xFF0F172A), Color(0xFF1E293B)],
            onTap: () => context.push('/privacy-policy'),
          ),
          _buildSettingsTile(
            Iconsax.document_text,
            'Terms of Service',
            'Read our terms and conditions',
            gradient: const [Color(0xFF334155), Color(0xFF64748B)],
            onTap: () => context.push('/terms-of-service'),
          ),
        ]),
        const SizedBox(height: 36),
        ScaleOnTap(
          onTap: () => ref.read(userProvider.notifier).logout(),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFFECDD3), width: 1.2),
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.logout,
                      color: Color(0xFFE11D48), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'LOGOUT',
                    style: GoogleFonts.inter(
                      color: const Color(0xFFE11D48),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) {
                final isDark =
                    Theme.of(dialogContext).brightness == Brightness.dark;
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  title: const Text('Request Account Deletion?',
                      style: TextStyle(
                          color: AppColors.dangerRed,
                          fontWeight: FontWeight.w900)),
                  content: Text(
                    'This will flag your account for permanent deletion. This action cannot be undone once processed by admin.',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.textOnDarkMuted
                            : AppColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('CANCEL',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.bold))),
                    TextButton(
                      onPressed: () async {
                        final router = GoRouter.of(context);
                        await ref
                            .read(userProvider.notifier)
                            .deleteAccountRequest();
                        router.go('/auth/login');
                      },
                      child: const Text('CONFIRM DELETION',
                          style: TextStyle(
                              color: AppColors.dangerRed,
                              fontWeight: FontWeight.w900)),
                    ),
                  ],
                );
              },
            );
          },
          child: Text(
            'DELETE ACCOUNT',
            style: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileForm(UserState user) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF006241).withValues(alpha: 0.2),
                          width: 2)),
                  child: Hero(
                    tag: 'profile_pic',
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: const Color(0xFFF1F5F9),
                      backgroundImage: user.profileImageUrl.isNotEmpty
                          ? NetworkImage(user.profileImageUrl)
                          : null,
                      child: user.isLoading
                          ? Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle),
                              child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white)),
                            )
                          : (user.profileImageUrl.isEmpty
                              ? const Icon(Iconsax.user,
                                  size: 48, color: Color(0xFF94A3B8))
                              : null),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: ScaleOnTap(
                    onTap: user.isLoading ? null : _updateProfilePhoto,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF006241),
                      child:
                          Icon(Iconsax.camera, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField('Full Name', _nameController, Iconsax.user),
          const SizedBox(height: 20),
          _buildTextField('Email Address', _emailController, Iconsax.sms),
          const SizedBox(height: 20),
          _buildTextField('Phone Number', _phoneController, Iconsax.call),
          const SizedBox(height: 36),
          ScaleOnTap(
            onTap: user.isLoading ? null : _saveProfile,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF006241), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF006241).withValues(alpha: 0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: user.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'SAVE CHANGES',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isEditingProfile = false),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Container(
              margin: const EdgeInsets.only(left: 12, right: 12),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF006241), size: 18),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide:
                  const BorderSide(color: Color(0xFF006241), width: 1.5),
            ),
            hintText: 'Enter $label',
            hintStyle: GoogleFonts.inter(
              color: const Color(0xFF94A3B8),
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }

  Widget _buildSettingsGroup(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF64748B),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle, {
    required List<Color> gradient,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF1F5F9)),
          ),
        ),
        child: Row(
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
                    color: gradient.first.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
