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
      backgroundColor: AppColors.brandGreenBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/auth/login'),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.bgWhite,
                          border: Border.all(
                              color:
                                  AppColors.brandGreen.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 16, color: AppColors.brandGreen),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Create Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 42),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.createAccount,
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.registerSubtitle,
                      style: TextStyle(
                          fontSize: 15,
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideX(begin: -0.05),

              const SizedBox(height: 32),

              // Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.bgWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<UserRole>(
                            value: _selectedRole,
                            isExpanded: true,
                            icon: const Icon(Iconsax.arrow_down_1,
                                color: AppColors.textSecondary),
                            items: const [
                              DropdownMenuItem(
                                  value: UserRole.customer,
                                  child: Text('I am a Customer')),
                              DropdownMenuItem(
                                  value: UserRole.driver,
                                  child: Text('I am a Rider/Driver')),
                              DropdownMenuItem(
                                  value: UserRole.technician,
                                  child: Text('I am a Technician')),
                            ],
                            onChanged: (UserRole? value) {
                              if (value != null) {
                                setState(() => _selectedRole = value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
