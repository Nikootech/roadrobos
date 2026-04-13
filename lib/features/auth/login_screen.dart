import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';
import '../../core/constants/app_strings.dart';
import '../profile/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user_role.dart';
import '../../core/repositories/user_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../core/services/biometric_service.dart';
import '../../core/services/secure_storage_service.dart';

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
  bool _isCustomer = true;
  bool _isSigningUp = false; // Toggle for register vs login

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isDemoMode = false;

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isCustomer) {
        if (_isSigningUp) {
          _handleEmailSignUp();
        } else {
          _handleEmailLogin();
        }
      } else {
        final email = _emailController.text.trim();
        final pass = _passwordController.text.trim();
        
        bool isValid = (email == 'admin@roadrobos.com' && pass == 'admin123') ||
                      (email == 'superadmin@roadrobos.com' && pass == 'admin123') ||
                      (email == 'tech@roadrobos.com' && pass == 'tech123') ||
                      (email == 'driver@roadrobos.com' && pass == 'driver123');
        
        if (isValid) {
          // Auto-detect role from email
          if (email == 'superadmin@roadrobos.com') {
            _performEmployeeLogin(UserRole.superAdmin, 'Super Admin');
          } else if (email == 'admin@roadrobos.com') {
            _performEmployeeLogin(UserRole.admin, 'Admin');
          } else {
            _showRoleSelection();
          }
        } else {
          NavHelpers.showError(context, 'Invalid Employee ID or Password');
        }
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
      // userProvider listens to auth changes and will fetch the profile automatically
    } catch (e) {
      setState(() => _isLoading = false);
      NavHelpers.showError(context, 'Login Failed: $e');
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
        // Router will handle navigation automatically upon profile load
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Signup Failed: $e');
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
      // On Web, signInWithOAuth will redirect the page, so we don't need manual navigation here.
      // On Mobile/Desktop, you might need to handle the deep link.
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Google Sign-In failed: $e');
      }
    }
  }

  void _handleBiometricLogin() async {
    final biometricService = ref.read(biometricServiceProvider);
    final isAvailable = await biometricService.isAvailable();
    
    if (!isAvailable) {
      NavHelpers.showError(context, 'Biometrics not available or not set up on this device');
      return;
    }

    final authenticated = await biometricService.authenticate(
      localizedReason: 'Authenticate to login to RoadRobos',
    );

    if (authenticated) {
      setState(() => _isLoading = true);
      try {
        NavHelpers.showSuccess(context, 'Biometric Authentication Successful');
        
        final secureStorage = ref.read(secureStorageServiceProvider);
        final savedUid = await secureStorage.read('last_logged_in_uid');
        
        if (savedUid != null) {
           NavHelpers.showSuccess(context, 'Logging in as last user...');
        } else {
           NavHelpers.showSuccess(context, 'Bio-Auth passed. Please login once to link biometrics.');
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Direct login for admin/superAdmin roles (no role selection needed)
  Future<void> _performEmployeeLogin(UserRole role, [String? label]) async {
    setState(() => _isLoading = true);
    try {
      final roleStr = role.toString().split('.').last.toLowerCase();
      final demoId = 'demo_${roleStr}_001';
      
      await ref.read(userProvider.notifier).loginDemo(demoId, role: role);
      // Router will handle navigation automatically upon demo profile load
    } catch (e) {
      if (mounted) NavHelpers.showError(context, 'Login failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showRoleSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Select Your Employee Role',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),
              _buildRoleTile(context, 'Driver', Iconsax.car, AppColors.accentOrange, UserRole.driver),
              _buildRoleTile(context, 'Technician', Iconsax.setting_2, AppColors.brandGreenMid, UserRole.technician),
            ],
          ),
        );
      },
    );
  }

  void _showDemoCredentials() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.bgWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Demo Credentials', 
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context), 
                    icon: const Icon(Icons.close, color: AppColors.textMuted)
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Use these accounts for testing and demonstration.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDemoTile('Standard Customer', 'customer@roadrobos.com', 'customer123', true),
                    _buildDemoTile('System Admin', 'admin@roadrobos.com', 'admin123', false),
                    _buildDemoTile('Field Technician', 'tech@roadrobos.com', 'tech123', false),
                    _buildDemoTile('Professional Driver', 'driver@roadrobos.com', 'driver123', false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoTile(String title, String identifier, String secret, bool isCustomer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandGreenBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandGreen.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCustomer ? Iconsax.user : Iconsax.briefcase, 
                size: 18, 
                color: AppColors.brandGreen
              ),
              const SizedBox(width: 8),
              Text(
                title, 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('ID', identifier),
          const SizedBox(height: 4),
          _buildInfoRow('Secret', secret),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isCustomer = isCustomer;
                  _emailController.text = identifier;
                  _passwordController.text = secret;
                });
                Navigator.pop(context);
                NavHelpers.showSuccess(context, 'Credentials loaded for $title');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Auto-Fill & Select', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const Spacer(),
        GestureDetector(
          onTap: () {
             Clipboard.setData(ClipboardData(text: value));
             NavHelpers.showSuccess(context, '$label copied');
          },
          child: const Icon(Iconsax.copy, size: 14, color: AppColors.brandGreen),
        ),
      ],
    );
  }

  Widget _buildRoleTile(BuildContext context, String label, IconData icon, Color color, UserRole role) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      onTap: () async {
        Navigator.pop(context);
        _performEmployeeLogin(role, label);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                          border: Border.all(color: AppColors.brandGreen.withOpacity(0.2)),
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
                    GestureDetector(
                      onTap: _showDemoCredentials,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bgWhite,
                          border: Border.all(color: AppColors.accentOrange.withOpacity(0.2)),
                        ),
                        child: const Icon(Iconsax.info_circle, size: 20, color: AppColors.accentOrange),
                      ),
                    ),
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
                      AppStrings.welcomeBack,
                      style: GoogleFonts.outfit(fontSize: 30, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.loginSubtitle,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildToggle(),
              ),

              const SizedBox(height: 24),

              // Form Fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isCustomer)
                          Column(
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
                              const SizedBox(height: 16),
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
                            ],
                          ),


                      const SizedBox(height: 16),

                      if (!_isCustomer) ...[
                        CustomTextField(
                          label: 'Employee ID / Email',
                          hint: 'Enter employee credentials',
                          prefixIcon: Iconsax.personalcard,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: AppStrings.password,
                          hint: 'Enter your password',
                          prefixIcon: Iconsax.lock,
                          isPassword: true,
                          controller: _passwordController,
                        ),
                      ],

                      const SizedBox(height: 8),

                      CustomButton(
                        label: _isCustomer 
                          ? (_isSigningUp ? 'Join RoAd RoBo\'s' : 'Sign In with Email')
                          : AppStrings.login,
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        backgroundColor: AppColors.brandGreen,
                      ),

                      const SizedBox(height: 20),

                      // Social Login
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.border.withOpacity(0.6))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(AppStrings.orContinueWith, style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          ),
                          Expanded(child: Divider(color: AppColors.border.withOpacity(0.6))),
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
                                color: AppColors.primaryBlue.withOpacity(0.3),
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
                            _isSigningUp ? 'Already have an account?' : AppStrings.dontHaveAccount, 
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

  Widget _buildToggle() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandGreen.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Expanded(child: _toggleItem('Customer', _isCustomer, () {
            if (!_isCustomer) _resetLoginState(true);
          })),
          Expanded(child: _toggleItem('Employee', !_isCustomer, () {
            if (_isCustomer) _resetLoginState(false);
          })),
        ],
      ),
    );
  }

  void _resetLoginState(bool isCustomer) {
    setState(() {
      _isCustomer = isCustomer;
      _isSigningUp = false;
      _isDemoMode = false;
      _emailController.clear();
      _passwordController.clear();
    });
  }

  Widget _toggleItem(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: active ? AppColors.brandGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildAuthModeItem(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.brandGreen.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.brandGreen : AppColors.border),
        ),
        child: Text(
          label, 
          style: TextStyle(
            fontSize: 12, 
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            color: active ? AppColors.brandGreen : AppColors.textSecondary
          )
        ),
      ),
    );
  }
}
