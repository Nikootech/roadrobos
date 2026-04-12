import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _isCustomer = true;
  bool _isOtpSent = false;
  String? _verificationId;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isCustomer) {
        if (!_isOtpSent) {
          _sendOtp();
        } else {
          _verifyOtp();
        }
      } else {
        final email = _emailController.text.trim();
        final pass = _passwordController.text.trim();
        
        bool isValid = (email == 'admin@roadrobos.com' && pass == 'admin123') ||
                      (email == 'superadmin@roadrobos.com' && pass == 'admin123') ||
                      (email == 'tech@roadrobos.com' && pass == 'tech123') ||
                      (email == 'driver@roadrobos.com' && pass == 'driver123');
        
        if (isValid) {
          _showRoleSelection();
        } else {
          NavHelpers.showError(context, 'Invalid Employee ID or Password');
        }
      }
    }
  }

  void _sendOtp() async {
    setState(() => _isLoading = true);
    try {
      final phone = '+91${_phoneController.text.trim()}';
      await ref.read(authServiceProvider).verifyPhone(
        phoneNumber: phone,
        onCodeSent: (verificationId, resendToken) {
          setState(() {
            _isLoading = false;
            _isOtpSent = true;
            _verificationId = verificationId;
          });
          NavHelpers.showSuccess(context, 'OTP sent to ${_phoneController.text}');
        },
        onVerificationFailed: (e) {
          setState(() => _isLoading = false);
          NavHelpers.showError(context, 'Verification failed: ${e.message}');
        },
        onVerificationCompleted: (credential) {
          _signInWithCredential(credential);
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      NavHelpers.showError(context, 'Error: $e');
    }
  }

  void _verifyOtp() async {
    if (_verificationId == null) {
      NavHelpers.showError(context, 'Session expired. Please request a new OTP.');
      setState(() => _isOtpSent = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithOtp(
        _verificationId!, 
        _otpController.text.trim(),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      NavHelpers.showError(context, 'Invalid OTP or network error');
    }
  }

  void _signInWithCredential(AuthCredential credential) async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      setState(() => _isLoading = false);
      NavHelpers.showError(context, 'Auto-sign in failed');
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final cred = await ref.read(authServiceProvider).signInWithGoogle();
      if (cred == null) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      NavHelpers.showError(context, 'Google Sign-In failed');
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
                    _buildDemoTile('Standard Customer', '9876543210', 'Any 6-digit OTP', true),
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
                  _isOtpSent = false;
                  _verificationId = null;
                  if (isCustomer) {
                    _phoneController.text = identifier;
                  } else {
                    _emailController.text = identifier;
                    _passwordController.text = secret;
                  }
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
        setState(() => _isLoading = true);
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userId = user.uid;
          await ref.read(userRepositoryProvider).updateField(userId, 'role', role.name);
          await ref.read(userProvider.notifier).fetchUserProfile(userId);
        }
        
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          NavHelpers.showSuccess(context, 'Logged in as $label');
        }
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
                      if (!_isOtpSent)
                        CustomTextField(
                          label: _isCustomer ? 'Mobile Number' : 'Employee ID / Email',
                          hint: _isCustomer ? 'Enter 10-digit number' : 'Enter employee credentials',
                          prefixIcon: _isCustomer ? Iconsax.mobile : Iconsax.personalcard,
                          controller: _isCustomer ? _phoneController : _emailController,
                          keyboardType: _isCustomer ? TextInputType.phone : TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (_isCustomer && value.length != 10) return 'Enter valid 10-digit number';
                            return null;
                          },
                        ),

                      if (_isCustomer && _isOtpSent)
                        CustomTextField(
                          label: 'Verification Code',
                          hint: 'Enter 6-digit OTP',
                          prefixIcon: Iconsax.password_check,
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'OTP is required';
                            if (value.length != 6) return 'Enter 6-digit code';
                            return null;
                          },
                        ),

                      const SizedBox(height: 16),

                      if (!_isCustomer)
                        CustomTextField(
                          label: AppStrings.password,
                          hint: 'Enter your password',
                          prefixIcon: Iconsax.lock,
                          isPassword: true,
                          controller: _passwordController,
                        ),

                      const SizedBox(height: 8),

                      CustomButton(
                        label: _isCustomer ? (_isOtpSent ? 'Verify OTP' : 'Send OTP') : AppStrings.login,
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
                              Image.network('https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png', width: 24, errorBuilder: (_,__,___) => const Icon(Icons.g_mobiledata)),
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
                          const Text(AppStrings.dontHaveAccount, style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => context.go('/auth/register'),
                            child: const Text(' Sign Up', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brandGreen)),
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
          Expanded(child: _toggleItem('Customer', _isCustomer, () => setState(() => _isCustomer = true))),
          Expanded(child: _toggleItem('Employee', !_isCustomer, () => setState(() => _isCustomer = false))),
        ],
      ),
    );
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
}
