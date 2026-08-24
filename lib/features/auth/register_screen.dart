import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/user_role.dart';
import '../../core/repositories/user_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../navigation/nav_helpers.dart';
import '../../core/config/app_config.dart';
import '../../core/services/local_storage_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.customer;

  @override
  void initState() {
    super.initState();
    _loadSelectedRole();
  }

  Future<void> _loadSelectedRole() async {
    final savedRoleName =
        await ref.read(localStorageServiceProvider).getSelectedRole();
    if (savedRoleName != null) {
      final role = UserRole.values.firstWhere(
        (e) => e.name == savedRoleName,
        orElse: () => UserRole.customer,
      );
      setState(() {
        _selectedRole = role;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final response = await ref.read(authServiceProvider).signUpWithEmail(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );

        final user = response.user;
        if (user != null) {
          // 2. Save Profile to Supabase
          final appUser = AppUser(
            id: user.id,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            role: _selectedRole,
            isApproved: _selectedRole != UserRole.technician,
            createdAt: DateTime.now(),
          );
          await ref.read(userRepositoryProvider).saveUser(appUser);

          // 3. If Driver, create driver record for auto-approval
          if (_selectedRole == UserRole.driver) {
            await ref.read(driverRepositoryProvider).registerDriver(
                  uid: user.id,
                  name: _nameController.text.trim(),
                  phone: _phoneController.text.trim(),
                  vehicleModel: 'Pending Update',
                  chassisNumber: 'Pending Update',
                  licenseNumber: 'Pending Update',
                );
          }

          if (!mounted) return;
          NavHelpers.showSuccess(context, 'Account created successfully!');
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        NavHelpers.showError(context, 'Registration failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top bar with transparent logo & back button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/auth/login'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/app_icon.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                              'assets/signin_icon.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.local_shipping_rounded,
                                color: AppColors.brandGreen,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.createAccount,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      AppStrings.registerSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideX(begin: -0.05),

              const SizedBox(height: 20),

              // Modern Visual Role Selector matching RoleSelectionScreen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'I am registering as:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF475569),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleSelectChip(
                            role: UserRole.customer,
                            label: 'Customer',
                            icon: Iconsax.user,
                            gradient: const [
                              Color(0xFF006241),
                              Color(0xFF10B981)
                            ],
                            activeColor: const Color(0xFF006241),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildRoleSelectChip(
                            role: UserRole.driver,
                            label: 'Driver',
                            icon: Iconsax.car,
                            gradient: const [
                              Color(0xFFEA580C),
                              Color(0xFFF59E0B)
                            ],
                            activeColor: const Color(0xFFEA580C),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildRoleSelectChip(
                            role: UserRole.technician,
                            label: 'Tech',
                            icon: Iconsax.setting_2,
                            gradient: const [
                              Color(0xFF0D9488),
                              Color(0xFF06B6D4)
                            ],
                            activeColor: const Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: AppStrings.fullName,
                        hint: 'Enter your full name',
                        prefixIcon: Iconsax.user,
                        controller: _nameController,
                        forceLightMode: true,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: AppStrings.email,
                        hint: 'Enter your email',
                        prefixIcon: Iconsax.sms,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        forceLightMode: true,
                        validator: (value) =>
                            value == null || !value.contains('@')
                                ? 'Invalid email'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: AppStrings.phoneNumber,
                        hint: 'Enter 10-digit phone number',
                        prefixIcon: Iconsax.call,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        forceLightMode: true,
                        validator: (value) =>
                            value == null || value.length != 10
                                ? 'Invalid phone'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: AppStrings.password,
                        hint: 'Create a password',
                        prefixIcon: Iconsax.lock,
                        isPassword: true,
                        controller: _passwordController,
                        forceLightMode: true,
                        validator: (value) => value == null || value.length < 6
                            ? 'Too short'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: AppStrings.confirmPassword,
                        hint: 'Confirm your password',
                        prefixIcon: Iconsax.lock,
                        isPassword: true,
                        controller: _confirmPasswordController,
                        forceLightMode: true,
                        validator: (value) => value != _passwordController.text
                            ? 'Not match'
                            : null,
                      ),
                      const SizedBox(height: 28),
                      CustomButton(
                        label: AppStrings.signUp,
                        onPressed: _handleRegister,
                        isLoading: _isLoading,
                        backgroundColor: AppColors.brandGreen,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(AppStrings.alreadyHaveAccount,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => context.go('/auth/login'),
                            child: const Text(' Sign In',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.brandGreen)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (AppConfig.showDebugFeatures) ...[
                        const Text('Quick Demo Access',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildDemoButton(context, 'Customer', Iconsax.user,
                                AppColors.brandGreen, '/main/home'),
                            _buildDemoButton(context, 'Driver', Iconsax.car,
                                AppColors.accentOrange, '/driver-home'),
                            _buildDemoButton(context, 'Tech', Iconsax.setting_2,
                                AppColors.brandGreenMid, '/tech-dashboard'),
                            _buildDemoButton(
                                context,
                                'Admin',
                                Iconsax.shield_tick,
                                AppColors.deepNavy,
                                '/admin-home'),
                          ],
                        ),
                      ],
                      const SizedBox(height: 48),
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

  Widget _buildRoleSelectChip({
    required UserRole role,
    required String label,
    required IconData icon,
    required List<Color> gradient,
    required Color activeColor,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? gradient
                      : [const Color(0xFFE2E8F0), const Color(0xFFCBD5E1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(BuildContext context, String label, IconData icon,
      Color color, String route) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
