import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import 'user_provider.dart';
import '../../core/providers/favorites_provider.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/two_factor_auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  bool _isEditingProfile = false;
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isBiometricEnabled = false;

  // ── 2FA dialog state ──────────────────────────────────────────────────────
  bool _is2FADialogLoading = false;
  String? _twoFaQrUri;
  String? _twoFaSecret;
  String? _twoFaFactorId;
  String? _twoFaError;
  int _twoFaStep = 0; // 0=loading/QR, 1=verify code, 2=success
  final _totpCodeController = TextEditingController();

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
            content: Text('Biometric authentication is not available on this device.'),
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
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Confirm Password', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please enter your password to enable biometric login.', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.primaryBlue),
                    hintText: 'Enter password',
                    filled: true,
                    fillColor: AppColors.bgLightGrey,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, controller.text),
                child: const Text('CONFIRM', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
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
        if (email == null || email.isEmpty) throw Exception('No email associated with this profile');
        
        await authService.signInWithEmail(email, password);
        
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
        messenger.showSnackBar(
          SnackBar(
            content: Text('Incorrect password or verification failed: $e'),
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
    _totpCodeController.dispose();
    super.dispose();
  }

  // ── Real 2FA dialog ──────────────────────────────────────────────────────────

  Future<void> _showTwoFactorDialog() async {
    final userState = ref.read(userProvider);

    // If already enabled → offer to disable
    if (userState.mfaEnabled) {
      await _showDisable2FADialog();
      return;
    }

    // Reset dialog state
    setState(() {
      _is2FADialogLoading = true;
      _twoFaStep = 0;
      _twoFaQrUri = null;
      _twoFaSecret = null;
      _twoFaFactorId = null;
      _twoFaError = null;
      _totpCodeController.clear();
    });

    // Show dialog immediately (spinner while enrolling)
    if (!mounted) return;
    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => _build2FADialog(dialogCtx, setDialogState),
      ),
    ));

    // Start TOTP enrollment in background
    try {
      final svc = ref.read(twoFactorAuthServiceProvider);
      final result = await svc.enrollTOTP();
      if (!mounted) return;
      setState(() {
        _twoFaQrUri = result.qrCodeUri;
        _twoFaSecret = result.secret;
        _twoFaFactorId = result.factorId;
        _is2FADialogLoading = false;
        _twoFaStep = 0;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _twoFaError = e.toString();
        _is2FADialogLoading = false;
      });
    }
  }

  Widget _build2FADialog(BuildContext dialogCtx, StateSetter setDialogState) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_user_rounded, color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Two-Factor Authentication',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
        ],
      ),
      content: _twoFaError != null
          ? _build2FAErrorContent(dialogCtx)
          : _twoFaStep == 2
              ? _build2FASuccessContent(dialogCtx)
              : _twoFaStep == 1
                  ? _build2FAVerifyContent(dialogCtx, setDialogState)
                  : _build2FAQrContent(dialogCtx),
    );
  }

  /// Step 0 — QR code display
  Widget _build2FAQrContent(BuildContext dialogCtx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Scan this QR code with your Authenticator app (Google Authenticator, Authy, etc.)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFB0B8D1), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        _is2FADialogLoading
            ? const SizedBox(
                height: 180,
                child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: _twoFaQrUri ?? '',
                  size: 180,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF1A1F2E),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
              ),
        if (!_is2FADialogLoading && _twoFaSecret != null) ...[
          const SizedBox(height: 16),
          const Text(
            'Or enter this code manually:',
            style: TextStyle(color: Color(0xFF8892A4), fontSize: 11),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF252B3B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
            ),
            child: SelectableText(
              _twoFaSecret!,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontFamily: 'monospace',
                fontSize: 13,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('CANCEL', style: TextStyle(color: Color(0xFF8892A4), fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _is2FADialogLoading ? null : () {
                  setState(() => _twoFaStep = 1);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('NEXT →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Step 1 — Enter TOTP code for verification
  Widget _build2FAVerifyContent(BuildContext dialogCtx, StateSetter setDialogState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.phonelink_lock_rounded, color: AppColors.primaryBlue, size: 36),
        ),
        const SizedBox(height: 16),
        const Text(
          'Enter the 6-digit code from your Authenticator app to confirm setup.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFB0B8D1), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _totpCodeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 10,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: '······',
            hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 28, letterSpacing: 10),
            filled: true,
            fillColor: const Color(0xFF252B3B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            errorText: _twoFaError,
            errorStyle: const TextStyle(color: Color(0xFFFF5252), fontSize: 12),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => setState(() {
                  _twoFaStep = 0;
                  _twoFaError = null;
                  _totpCodeController.clear();
                }),
                child: const Text('← BACK', style: TextStyle(color: Color(0xFF8892A4), fontWeight: FontWeight.bold)),
              ),
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: _is2FADialogLoading ? null : () async {
                  final code = _totpCodeController.text.trim();
                  if (code.length != 6) {
                    setState(() => _twoFaError = 'Please enter a 6-digit code.');
                    return;
                  }
                  setState(() {
                    _is2FADialogLoading = true;
                    _twoFaError = null;
                  });
                  try {
                    final svc = ref.read(twoFactorAuthServiceProvider);
                    await svc.challengeAndVerify(
                      factorId: _twoFaFactorId!,
                      totpCode: code,
                    );
                    // Persist to DB + update provider state
                    await ref.read(userProvider.notifier).enable2FA();
                    if (mounted) {
                      setState(() {
                        _twoFaStep = 2;
                        _is2FADialogLoading = false;
                      });
                    }
                  } catch (e) {
                    if (mounted) {
                      setState(() {
                        _twoFaError = 'Invalid code. Please try again.';
                        _is2FADialogLoading = false;
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _is2FADialogLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('VERIFY & ENABLE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Step 2 — Success
  Widget _build2FASuccessContent(BuildContext dialogCtx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (ctx, val, child) => Transform.scale(scale: val, child: child),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1A3A2A),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: Color(0xFF4CAF50), size: 48),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '2FA is now Active!',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your account is now protected with Two-Factor Authentication. You will be asked for a code on future logins.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFB0B8D1), fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('DONE ✓', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }

  /// Error state inside dialog
  Widget _build2FAErrorContent(BuildContext dialogCtx) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFFF5252), size: 48),
        const SizedBox(height: 16),
        Text(
          _twoFaError ?? 'An error occurred.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFB0B8D1), fontSize: 13),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('CLOSE', style: TextStyle(color: Color(0xFF8892A4), fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  /// Shown when 2FA is already enabled — offers to disable it
  Future<void> _showDisable2FADialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Disable 2FA?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        content: const Text(
          'Removing Two-Factor Authentication will make your account less secure. Are you sure?',
          style: TextStyle(color: Color(0xFFB0B8D1), fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('CANCEL', style: TextStyle(color: Color(0xFF8892A4), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('DISABLE', style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final svc = ref.read(twoFactorAuthServiceProvider);
      final factor = await svc.getVerifiedTotpFactor();
      if (factor != null) await svc.unenroll(factor.id);
      await ref.read(userProvider.notifier).disable2FA();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Two-Factor Authentication disabled.'),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to disable 2FA: $e'),
          backgroundColor: AppColors.dangerRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Change Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepNavy)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPickerOption(
                  Icons.camera_alt_rounded, 
                  'Camera', 
                  () async {
                    Navigator.pop(context);
                    await ref.read(userProvider.notifier).pickAndUploadProfilePicture(ImageSource.camera);
                  }
                ),
                _buildPickerOption(
                  Icons.photo_library_rounded, 
                  'Gallery', 
                  () async {
                    Navigator.pop(context);
                    await ref.read(userProvider.notifier).pickAndUploadProfilePicture();
                  }
                ),
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
            decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryBlue, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditingProfile ? 'Edit Profile' : 'Account Settings',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          if (_isEditingProfile)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: userState.isLoading ? null : _saveProfile,
                child: userState.isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('SAVE', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _isEditingProfile ? _buildEditProfileForm(userState) : _buildSettingsList(userState),
      ),
    );
  }

  Widget _buildSettingsList(UserState user) {
    return Column(
      children: [
        _buildSettingsGroup('Personal Information', [
          _buildSettingsTile(
            Icons.person_outline_rounded, 
            'Edit Profile', 
            '${user.name} • ${user.email}',
            onTap: () => setState(() => _isEditingProfile = true),
          ),
          _buildSettingsTile(Icons.add_location_alt_outlined, 'Saved Locations', 'Manage home and office addresses', onTap: () => context.push('/saved-locations')),
          _buildSettingsTile(Icons.directions_car_filled_rounded, 'My Vehicles', 'Vehicle details and RC docs', onTap: () => context.push('/my-vehicles')),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Security', [
          _buildSettingsTile(
            Icons.lock_outline_rounded, 
            'Change Password', 
            'Update your security credentials',
            onTap: () async {
              final user = ref.read(userProvider).user;
              if (user != null && user.email != null && user.email!.isNotEmpty) {
                try {
                  await ref.read(authServiceProvider).resetPassword(user.email!);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your email!'),
                      backgroundColor: AppColors.successGreen,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send reset link: $e'),
                      backgroundColor: AppColors.dangerRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No email address associated with your profile.'),
                    backgroundColor: AppColors.dangerRed,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          _buildSettingsTile(
            Icons.fingerprint_rounded, 
            'Biometric Login', 
            'Enable Fingerprint/FaceID for login',
            trailing: Switch(
              value: _isBiometricEnabled,
              onChanged: (val) => _toggleBiometric(val),
              activeThumbColor: AppColors.primaryBlue,
            ),
          ),
          _buildSettingsTile(
            Icons.verified_user_outlined, 
            'Two-Factor Authentication', 
            user.mfaEnabled ? 'Enabled ✓ — Tap to disable' : 'Add extra layer of security',
            onTap: _showTwoFactorDialog,
            trailing: user.mfaEnabled
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A2A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'ON',
                      style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  )
                : const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Preferences', [
          _buildSettingsTile(Icons.notifications_none_rounded, 'Notification Settings', 'Manage push and email alerts', onTap: () => context.push('/notification-settings')),
          _buildSettingsTile(Icons.language_rounded, 'Language', 'Choose your preferred language', onTap: () => context.push('/language')),
        ]),
        const SizedBox(height: 24),
        _buildSettingsGroup('Legal', [
          _buildSettingsTile(
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'How we collect, use, and protect your data',
            onTap: () => launchUrl(
              Uri.parse('https://roadrobos.com/privacy'),
              mode: LaunchMode.externalApplication,
            ),
          ),
          _buildSettingsTile(
            Icons.description_outlined,
            'Terms of Service',
            'Read our terms and conditions',
            onTap: () => launchUrl(
              Uri.parse('https://roadrobos.com/terms'),
              mode: LaunchMode.externalApplication,
            ),
          ),
        ]),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => ref.read(userProvider.notifier).logout(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: AppColors.dangerRed.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('LOGOUT', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Text('Request Account Deletion?', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w900)),
                content: const Text('This will flag your account for permanent deletion. This action cannot be undone once processed by admin.', style: TextStyle(color: AppColors.textSecondary)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold))),
                  TextButton(
                    onPressed: () async {
                      final router = GoRouter.of(context);
                      await ref.read(userProvider.notifier).deleteAccountRequest();
                      router.go('/auth/login');
                    }, 
                    child: const Text('CONFIRM DELETION', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            );
          },
          child: Text(
            'DELETE ACCOUNT', 
            style: TextStyle(
              color: AppColors.dangerRed.withValues(alpha: 0.5), 
              fontSize: 12, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 1,
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
                   decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 2)),
                   child: Hero(
                     tag: 'profile_pic',
                     child: CircleAvatar(
                      radius: 54,
                      backgroundColor: AppColors.bgLightGrey,
                      backgroundImage: user.profileImageUrl.isNotEmpty ? NetworkImage(user.profileImageUrl) : null,
                      child: user.isLoading 
                        ? Container(
                            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), shape: BoxShape.circle),
                            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                          )
                        : (user.profileImageUrl.isEmpty ? const Icon(Icons.person, size: 54, color: AppColors.textMuted) : null),
                    ),
                   ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: InkWell(
                    onTap: user.isLoading ? null : _updateProfilePhoto,
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryBlue,
                      child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField('Full Name', _nameController, Icons.person_outline_rounded),
          const SizedBox(height: 20),
          _buildTextField('Email Address', _emailController, Icons.mail_outline_rounded),
          const SizedBox(height: 20),
          _buildTextField('Phone Number', _phoneController, Icons.phone_outlined),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: user.isLoading ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: user.isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'SAVE CHANGES',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => setState(() => _isEditingProfile = false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            hintText: 'Enter $label',
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.normal),
          ),
          validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
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
          child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black12.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, {VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: AppColors.primaryBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
