import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';
import '../../shared/widgets/glass_card.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

/// Login Screen matching Figma Screen [38]: "Login & Authentication"
/// Hero image, phone/email input, primary CTA, social login, footer
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(); // For Employee
  final _phoneController = TextEditingController(); // For Customer
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isCustomer = true; // Toggle between Customer and Employee

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Iconsax.user, color: AppColors.primaryBlue),
                title: const Text('Customer', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => context.go('/main/home'),
              ),
              ListTile(
                leading: const Icon(Iconsax.car, color: AppColors.accentOrange),
                title: const Text('Driver', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => context.go('/driver-home'),
              ),
              ListTile(
                leading: const Icon(Iconsax.setting_2, color: AppColors.successDark),
                title: const Text('Technician', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => context.go('/tech-tasks'),
              ),
              ListTile(
                leading: const Icon(Iconsax.shield_tick, color: AppColors.deepNavy),
                title: const Text('Admin', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => context.go('/admin-home'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          if (_isCustomer) {
            context.go('/main/home');
          } else {
            _showRoleSelection(); // Employee roles selection
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightAlt,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header area with top bar (matches Figma: 388x64 header)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/onboarding'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bgWhite,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Sign In',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Hero illustration area (matches Figma: 340x295 hero image)
              GlassCard(
                padding: EdgeInsets.zero,
                borderRadius: 32,
                opacity: 0.1,
                blur: 20,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.15),
                        AppColors.primaryBlue.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_car_rounded,
                            size: 44,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'RoAdRoBos',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.1, end: 0, duration: 600.ms),

              const SizedBox(height: 24),

              // Header text (matches Figma: 340x102 header text area)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.welcomeBack,
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.loginSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms)
                  .slideX(begin: -0.05, end: 0, duration: 500.ms),

              const SizedBox(height: 28),

              // Role Toggle (Customer vs Employee)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isCustomer = true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isCustomer ? AppColors.primaryBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Customer',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _isCustomer ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isCustomer = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_isCustomer ? AppColors.primaryBlue : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Employee',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: !_isCustomer ? Colors.white : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 250.ms).fadeIn(),
              ),

              const SizedBox(height: 24),

              // Form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: _isCustomer ? 'Mobile Number' : 'Employee ID / Email',
                        hint: _isCustomer ? 'Enter 10-digit number' : 'Enter employee credentials',
                        prefixIcon: _isCustomer ? Iconsax.mobile : Iconsax.personalcard,
                        controller: _isCustomer ? _phoneController : _emailController,
                        keyboardType: _isCustomer ? TextInputType.phone : TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return _isCustomer ? 'Mobile number is required' : 'Credential is required';
                          }
                          if (_isCustomer) {
                            if (value.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Enter a valid 10-digit number';
                            }
                          } else {
                            if (!value.contains('@') && value.length < 4) {
                              return 'Enter a valid email or ID';
                            }
                          }
                          return null;
                        },
                      )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: AppStrings.password,
                        hint: 'Enter your password',
                        prefixIcon: Iconsax.lock,
                        isPassword: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      )
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => NavHelpers.showSuccess(context, 'Reset password email sent to your inbox!'),
                          child: const Text(
                            AppStrings.forgotPassword,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Login button (matches Figma: 340x, primary action)
                      CustomButton(
                        label: AppStrings.login,
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        backgroundColor: AppColors.primaryBlue,
                      )
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.5))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppStrings.orContinueWith,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.5))),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Google sign-in
                      const GoogleSignInButton()
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.dontHaveAccount,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/auth/register'),
                            child: const Text(
                              AppStrings.signUp,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      // Quick Demo Access
                      const Text(
                        'Quick Demo Access',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildDemoButton(context, 'Customer', Iconsax.user, AppColors.primaryBlue, '/main/home'),
                          _buildDemoButton(context, 'Driver', Iconsax.car, AppColors.accentOrange, '/driver-home'),
                          _buildDemoButton(context, 'Tech', Iconsax.setting_2, AppColors.successDark, '/tech-tasks'),
                          _buildDemoButton(context, 'Admin', Iconsax.shield_tick, AppColors.deepNavy, '/admin-home'),
                        ],
                      ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoButton(BuildContext context, String label, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

