import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../navigation/nav_helpers.dart';
import '../../core/constants/app_strings.dart';
import '../profile/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/biometric_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    try {
      await ref.read(authServiceProvider).signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      await _promptBiometricSetup();
      
      // userProvider listens to auth changes and will fetch the profile automatically
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      NavHelpers.showError(context, 'Login Failed: $e');
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
          content: const Text('Would you like to use Face ID / Fingerprint for faster logins next time?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No thanks')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Enable')),
          ],
        ),
      );

      if (enable == true) {
        final authenticated = await biometricService.authenticate(localizedReason: 'Authenticate to enable biometrics');
        if (authenticated) {
          await prefs.setBool('biometric_enabled', true);
          const storage = FlutterSecureStorage();
          await storage.write(key: 'email', value: _emailController.text.trim());
          await storage.write(key: 'password', value: _passwordController.text.trim());
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
        // Create initial profile for the email user
        await ref.read(userProvider.notifier).fetchUserProfile(response.user!.id);
        
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
          const SnackBar(content: Text('Biometric setup required. Please login with email first.')),
        );
      }
      return;
    }

    final biometricService = ref.read(biometricServiceProvider);
    if (!await biometricService.isAvailable()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication not available on this device')),
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
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            NavHelpers.showError(context, 'Biometric Login Failed: $e');
          }
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          NavHelpers.showError(context, 'No credentials found for Biometric Login');
        }
      }
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final success = await ref.read(authServiceProvider).signInWithGoogle();
      if (!success) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Google Sign-In failed: $e');
      }
    }
  }







  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        if (_isLoading) setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Profile error: ${next.error}');
      } else if (!next.isLoading && _isLoading) {
        setState(() => _isLoading = false);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.brandGreenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/onboarding'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bgWhite,
                          border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.brandGreen),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Sign In',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 42), // Keep spacing symmetrical without the info icon
                  ],
                ),
              ),

              _buildHeroSection(),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)?.titleWelcomeBack ?? AppStrings.welcomeBack,
                      style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)?.lblLoginSubtitle ?? AppStrings.loginSubtitle,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),



              // Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Email Address',
                        hint: 'Enter your email',
                        prefixIcon: Iconsax.sms,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required';
                          if (!value.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      CustomTextField(
                        label: 'Password',
                        hint: _isSigningUp ? 'Create a password' : 'Enter your password',
                        prefixIcon: Iconsax.lock,
                        isPassword: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Password is required';
                          if (_isSigningUp && value.length < 6) return 'Mini 6 characters';
                          return null;
                        },
                      ),

                      // Forgot Password Link
                      if (!_isSigningUp)
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 4),
                            child: GestureDetector(
                              onTap: _handleForgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),



                      const SizedBox(height: 8),

                      CustomButton(
                        label: _isSigningUp ? 'Join RoAd RoBo\'s' : 'Sign In with Email',
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        backgroundColor: AppColors.brandGreen,
                      ),

                      const SizedBox(height: 20),

                      // Social Login
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.6))),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(AppLocalizations.of(context)?.lblOrContinueWith ?? AppStrings.orContinueWith, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          ),
                          Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.6))),
                        ],
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: _handleGoogleSignIn,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Text(
                                    'G',
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      foreground: Paint()
                                        ..shader = const LinearGradient(
                                          colors: [
                                            Color(0xFF4285F4), // Blue
                                            Color(0xFF34A853), // Green
                                            Color(0xFFFBBC05), // Yellow
                                            Color(0xFFEA4335), // Red
                                          ],
                                        ).createShader(const Rect.fromLTWH(0, 0, 24, 24)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text('Continue with Google', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          ],
                        ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Biometric Login Button
                      GestureDetector(
                        onTap: _handleBiometricLogin,
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.finger_scan, color: Colors.white, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Login with Biometrics', 
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isSigningUp ? 'Already have an account?' : (AppLocalizations.of(context)?.lblDontHaveAccount ?? AppStrings.dontHaveAccount), 
                            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _isSigningUp = !_isSigningUp);
                            },
                            child: Text(
                              _isSigningUp ? ' Sign In' : ' Sign Up Free', 
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brandGreen)
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(32)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset('assets/signin_icon.png', fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 12),
            Text('RoAd RoBo\'s', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.brandGreen)),
          ],
        ),
      ),
    );
  }




}
