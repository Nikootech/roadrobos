import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';
import '../profile/user_provider.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../core/models/user_role.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/repositories/user_repository.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isSigningUp = false; // Toggle for register vs login
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Check for multi-device logout
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final wasMultiDeviceLogout = await ref
          .read(localStorageServiceProvider)
          .checkAndClearMultiDeviceLogout();
      if (wasMultiDeviceLogout && mounted) {
        unawaited(showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.warning_rounded, color: AppColors.accentOrange),
                SizedBox(width: 8),
                Text('Session Ended',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
                'Your account was logged in on another device. For security, you have been signed out of this device.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue)),
              ),
            ],
          ),
        ));
      } else {
        final prefs = await SharedPreferences.getInstance();
        final isEnabled = prefs.getBool('biometric_enabled') ?? false;
        if (isEnabled && mounted) {
          await _handleBiometricLogin();
        }
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      NavHelpers.showError(context, 'Please enter your email address first');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).resetPassword(email);
      if (mounted) {
        setState(() => _isLoading = false);
        NavHelpers.showSuccess(context, 'Password reset link sent to $email');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Failed to send reset email: $e');
      }
    }
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isSigningUp) {
        _handleEmailSignUp();
      } else {
        _handleEmailLogin();
      }
    }
  }

  void _handleEmailLogin() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    try {
      await ref.read(authServiceProvider).signInWithEmail(
            email,
            password,
          );

      unawaited(Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Login succeeded',
          category: 'auth',
          data: const {'method': 'email'},
        ),
      ));

      await _promptBiometricSetup();

      // userProvider listens to auth changes and will fetch the profile automatically
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final authService = ref.read(authServiceProvider);
      final isRegistered = await authService.isEmailRegistered(email);

      if (!mounted) return;

      if (isRegistered) {
        // Show custom dialog helping the user resolve Google vs Email login
        unawaited(showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue),
                SizedBox(width: 8),
                Text('Sign In Help',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            content: Text(
              'We found a RoadRobos account linked to "$email".\n\n'
              'If you originally signed up using Google, please tap "Continue with Google" to log in.\n\n'
              'If you would like to set a password to log in with email directly, tap "Set Password" to receive a reset link.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleForgotPassword();
                },
                child: const Text('Set Password',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue)),
              ),
            ],
          ),
        ));
      } else {
        unawaited(Sentry.addBreadcrumb(
          Breadcrumb(
            message: 'Login failed',
            category: 'auth',
            level: SentryLevel.warning,
            data: {'method': 'email', 'error': e.toString()},
          ),
        ));
        NavHelpers.showError(context, 'Login Failed: $e');
      }
    }
  }

  Future<void> _promptBiometricSetup() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('biometric_enabled') ?? false;
    if (isEnabled) return;

    final biometricService = ref.read(biometricServiceProvider);
    if (await biometricService.isAvailable()) {
      if (!mounted) return;
      final bool? enable = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Biometric Login'),
          content: const Text(
              'Would you like to use Face ID / Fingerprint for faster logins next time?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No thanks')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Enable')),
          ],
        ),
      );

      if (enable == true) {
        final authenticated = await biometricService.authenticate(
            localizedReason: 'Authenticate to enable biometrics');
        if (authenticated) {
          await prefs.setBool('biometric_enabled', true);
          const storage = FlutterSecureStorage();
          await storage.write(
              key: 'email', value: _emailController.text.trim());
          await storage.write(
              key: 'password', value: _passwordController.text.trim());
        }
      }
    }
  }

  void _handleEmailSignUp() async {
    setState(() => _isLoading = true);
    try {
      final response = await ref.read(authServiceProvider).signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );

      if (response.user != null) {
        // Save initial profile with selected role and current device ID
        final savedRoleName =
            await ref.read(localStorageServiceProvider).getSelectedRole();
        final selectedRole = UserRole.values.firstWhere(
          (e) => e.name == savedRoleName,
          orElse: () => UserRole.customer,
        );
        final deviceId =
            await ref.read(localStorageServiceProvider).getLocalDeviceId();

        final newUser = AppUser(
          id: response.user!.id,
          name: 'New User',
          phone: '',
          email: _emailController.text.trim(),
          role: selectedRole,
          currentDeviceId: deviceId,
          createdAt: DateTime.now(),
        );
        await ref.read(userRepositoryProvider).saveUser(newUser);

        await ref
            .read(userProvider.notifier)
            .fetchUserProfile(response.user!.id);

        final error = ref.read(userProvider).error;
        if (mounted && error != null) {
          setState(() => _isLoading = false);
          NavHelpers.showError(context, 'Profile setup failed: $error');
        }
        // Router will handle navigation automatically upon successful profile load
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Signup Failed: $e');
      }
    }
  }

  Future<void> _handleBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('biometric_enabled') ?? false;

    if (!isEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Biometric setup required. Please login with email first.')),
        );
      }
      return;
    }

    final biometricService = ref.read(biometricServiceProvider);
    if (!await biometricService.isAvailable()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Biometric authentication not available on this device')),
        );
      }
      return;
    }

    final bool didAuthenticate = await biometricService.authenticate(
      localizedReason: 'Please authenticate to sign in to RoadRobos',
    );

    if (didAuthenticate && mounted) {
      setState(() => _isLoading = true);
      const storage = FlutterSecureStorage();
      final email = await storage.read(key: 'email');
      final password = await storage.read(key: 'password');

      if (email != null && password != null) {
        try {
          await ref.read(authServiceProvider).signInWithEmail(email, password);
          unawaited(Sentry.addBreadcrumb(
            Breadcrumb(
              message: 'Login succeeded',
              category: 'auth',
              data: const {'method': 'biometric'},
            ),
          ));
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            unawaited(Sentry.addBreadcrumb(
              Breadcrumb(
                message: 'Login failed',
                category: 'auth',
                level: SentryLevel.warning,
                data: {'method': 'biometric', 'error': e.toString()},
              ),
            ));
            NavHelpers.showError(context, 'Biometric Login Failed: $e');
          }
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          unawaited(Sentry.addBreadcrumb(
            Breadcrumb(
              message: 'Login failed',
              category: 'auth',
              level: SentryLevel.warning,
              data: const {
                'method': 'biometric',
                'error': 'No credentials found'
              },
            ),
          ));
          NavHelpers.showError(
              context, 'No credentials found for Biometric Login');
        }
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(authServiceProvider).signInWithGoogle();
      if (success) {
        unawaited(Sentry.addBreadcrumb(
          Breadcrumb(
            message: 'Login succeeded',
            category: 'auth',
            data: const {'method': 'google'},
          ),
        ));
        // Router will automatically navigate once authNotifierProvider updates.
        // Clear loading state here as a safety fallback.
        if (mounted) setState(() => _isLoading = false);
      } else {
        // User cancelled
        if (mounted) setState(() => _isLoading = false);
        unawaited(Sentry.addBreadcrumb(
          Breadcrumb(
            message: 'Login failed',
            category: 'auth',
            level: SentryLevel.warning,
            data: const {'method': 'google', 'error': 'Cancelled or failed'},
          ),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        unawaited(Sentry.addBreadcrumb(
          Breadcrumb(
            message: 'Login failed',
            category: 'auth',
            level: SentryLevel.warning,
            data: {'method': 'google', 'error': e.toString()},
          ),
        ));
        NavHelpers.showError(context, 'Google Sign-In failed: $e');
      }
    }
  }

  void _showSessionMismatchDialog() {
    if (_dialogShowing) return;
    _dialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E222B)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.4
                        : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.devices_rounded,
                      color: AppColors.brandGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Active Session Detected',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Your account is currently active on another device/browser. Do you want to terminate that session and log in here? Otherwise, you will be signed out from this device.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _dialogShowing = false;
                  ref.read(userProvider.notifier).confirmSessionTakeover();
                },
                child: Text(
                  'Terminate & Continue',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.border,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _dialogShowing = false;
                  ref.read(userProvider.notifier).cancelSessionTakeover();
                },
                child: Text(
                  'Cancel / Keep Old',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userProvider, (previous, next) {
      if (next.showSessionMismatchPrompt) {
        if (_isLoading) setState(() => _isLoading = false);
        _showSessionMismatchDialog();
        return;
      }
      if (next.error != null && next.error != previous?.error) {
        if (_isLoading) setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Profile error: ${next.error}');
      } else if (!next.isLoading && _isLoading) {
        setState(() => _isLoading = false);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Top Navigation Bar ──
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/onboarding'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF8FAFC),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 15,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF86EFAC).withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            size: 13,
                            color: Color(0xFF006241),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Secure Access',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF006241),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Centered Hero Brand Stage ──
              _buildHeroSection(),

              const SizedBox(height: 16),

              // ── Header Typography ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isSigningUp ? 'Create Account' : 'Welcome Back',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isSigningUp
                          ? 'Join RoadRobos to book services, rides, and track in real-time.'
                          : 'Enter your credentials to access your account and services.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.08, end: 0),

              const SizedBox(height: 24),

              // ── Form Section ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        label: 'Email Address',
                        hint: 'name@example.com',
                        prefixIcon: Iconsax.sms,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        forceLightMode: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Password',
                        hint: _isSigningUp
                            ? 'Create a secure password'
                            : 'Enter your password',
                        prefixIcon: Iconsax.lock,
                        isPassword: true,
                        controller: _passwordController,
                        forceLightMode: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (_isSigningUp && value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),

                      // Forgot Password Link
                      if (!_isSigningUp) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _handleForgotPassword,
                            child: Text(
                              'Forgot password?',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF006241),
                              ),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // ── Primary Action Button ──
                      GestureDetector(
                        onTap: _isLoading ? null : _handleLogin,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF006241),
                                Color(0xFF0D7E54),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF006241)
                                    .withValues(alpha: 0.28),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _isSigningUp
                                            ? 'Create Account'
                                            : 'Sign In with Email',
                                        style: GoogleFonts.inter(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Iconsax.arrow_right_1,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Divider ──
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'Or continue with',
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ── Google Sign-In Button ──
                      GestureDetector(
                        onTap: _handleGoogleSignIn,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'G',
                                    style: GoogleFonts.outfit(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: [
                                            Color(0xFF4285F4),
                                            Color(0xFF34A853),
                                            Color(0xFFFBBC05),
                                            Color(0xFFEA4335),
                                          ],
                                        ).createShader(
                                            const Rect.fromLTWH(0, 0, 22, 22)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ── Biometric Login Button ──
                      GestureDetector(
                        onTap: _handleBiometricLogin,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF86EFAC)
                                  .withValues(alpha: 0.8),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.finger_scan,
                                color: Color(0xFF006241),
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Sign In with Biometrics',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: const Color(0xFF006241),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Bottom Mode Switcher ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSigningUp
                                ? 'Already have an account?'
                                : "Don't have an account?",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (!_isSigningUp) {
                                context.go('/auth/role-selection');
                              } else {
                                setState(() => _isSigningUp = false);
                              }
                            },
                            child: Text(
                              _isSigningUp ? ' Sign In' : ' Sign Up Free',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF006241),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ── Security Guarantee ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            size: 13,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '256-bit SSL Encrypted • Fast & Secure',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF006241).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Image.asset(
              'assets/app_icon.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/signin_icon.png',
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
