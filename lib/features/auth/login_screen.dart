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

/// Login Screen — Re-themed to RoAdRoBo's Forest Green Brand Palette
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isCustomer = true;
  bool _isOtpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
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
              // Handle bar
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
                'Select Your Role',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildRoleTile(context, 'Customer', Iconsax.user, AppColors.brandGreen, '/main/home'),
              _buildRoleTile(context, 'Driver', Iconsax.car, AppColors.accentOrange, '/driver-home'),
              _buildRoleTile(context, 'Technician', Iconsax.setting_2, AppColors.brandGreenMid, '/tech-tasks'),
              _buildRoleTile(context, 'Admin', Iconsax.shield_tick, AppColors.deepNavy, '/admin-home'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleTile(BuildContext context, String label, IconData icon, Color color, String route) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      onTap: () => context.go(route),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() => _isLoading = false);
          if (_isCustomer) {
            if (!_isOtpSent) {
              setState(() => _isOtpSent = true);
              NavHelpers.showSuccess(context, 'OTP sent to ${_phoneController.text}');
            } else {
              context.go('/main/home');
            }
          } else {
            _showRoleSelection();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandGreenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Top Bar ───────────────────────────────────────────────────
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
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandGreen.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: AppColors.brandGreen,
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
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 42), // Balance back button
                  ],
                ),
              ),

              // ── Hero / Brand Showcase ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 28,
                  opacity: 0.08,
                  blur: 20,
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.brandGreen.withValues(alpha: 0.12),
                          AppColors.brandGreenMid.withValues(alpha: 0.06),
                          AppColors.brandGreenLight.withValues(alpha: 0.04),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Decorative circles
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.brandGreen.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          left: -15,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.brandGreenLight.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        // Center content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo image with bright white background and clean glow
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(36),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.brandGreen.withValues(alpha: 0.15),
                                      blurRadius: 30,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: -5,
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.zero,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(36),
                                  child: Image.asset(
                                    'assets/signin_icon.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Brand name
                              Text(
                                'RoAd RoBo\'s',
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.brandGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SebChris Mobility Pvt Ltd',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.brandGreenMid,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.08, end: 0, duration: 600.ms, curve: Curves.easeOut),

              const SizedBox(height: 24),

              // ── Welcome Text ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.welcomeBack,
                      style: GoogleFonts.outfit(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.loginSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 500.ms)
                  .slideX(begin: -0.05, end: 0, duration: 500.ms),

              const SizedBox(height: 24),

              // ── Customer / Employee Toggle ─────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandGreen.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isCustomer = true;
                            _isOtpSent = false;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: _isCustomer ? AppColors.brandGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _isCustomer
                                  ? [
                                      BoxShadow(
                                        color: AppColors.brandGreen.withValues(alpha: 0.30),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
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
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: !_isCustomer ? AppColors.brandGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: !_isCustomer
                                  ? [
                                      BoxShadow(
                                        color: AppColors.brandGreen.withValues(alpha: 0.30),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
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

              // ── Form Fields ───────────────────────────────────────────────
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

                      if (_isCustomer && _isOtpSent)
                        CustomTextField(
                          label: 'Verification Code',
                          hint: 'Enter 4-digit OTP',
                          prefixIcon: Iconsax.password_check,
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'OTP is required';
                            if (value.length != 4) return 'Enter 4-digit code';
                            return null;
                          },
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.1, end: 0),

                      const SizedBox(height: 16),

                      if (!_isCustomer)
                        CustomTextField(
                          label: AppStrings.password,
                          hint: 'Enter your password',
                          prefixIcon: Iconsax.lock,
                          isPassword: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Password is required';
                            if (value.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),

                      if (!_isCustomer)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => NavHelpers.showSuccess(context, 'Reset password email sent!'),
                            child: const Text(
                              AppStrings.forgotPassword,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandGreen,
                              ),
                            ),
                          ),
                        ),

                      if (_isCustomer && _isOtpSent)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => setState(() => _isOtpSent = false),
                            child: const Text(
                              'Change Number?',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.brandGreen,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      // ── CTA Button ──────────────────────────────────────
                      CustomButton(
                        label: _isCustomer
                            ? (_isOtpSent ? 'Verify OTP' : 'Send OTP')
                            : AppStrings.login,
                        onPressed: _handleLogin,
                        isLoading: _isLoading,
                        backgroundColor: AppColors.brandGreen,
                      )
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.6))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              AppStrings.orContinueWith,
                              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.border.withValues(alpha: 0.6))),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Google sign-in
                      _GoogleSignInButton()
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            AppStrings.dontHaveAccount,
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/auth/register'),
                            child: const Text(
                              AppStrings.signUp,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandGreen,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // ── Quick Demo Access ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.brandGreen.withValues(alpha: 0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandGreen.withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.brandGreen,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Quick Demo Access',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildDemoButton(context, 'Customer', Iconsax.user, AppColors.brandGreen, '/main/home'),
                                _buildDemoButton(context, 'Driver', Iconsax.car, AppColors.accentOrange, '/driver-home'),
                                _buildDemoButton(context, 'Tech', Iconsax.setting_2, AppColors.brandGreenMid, '/tech-tasks'),
                                _buildDemoButton(context, 'Admin', Iconsax.shield_tick, AppColors.deepNavy, '/admin-home'),
                              ],
                            ),
                          ],
                        ),
                      ).animate(delay: 700.ms).fadeIn().slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 20),
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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline Google Sign-In button (no external class dependency)
class _GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google G icon rendered via Text
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Text(
                  'G',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4285F4),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Continue with Google',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
