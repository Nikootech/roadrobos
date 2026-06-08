import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/local_storage_service.dart';
import '../../shared/widgets/custom_button.dart';
import '../../navigation/nav_helpers.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;

  void _onRoleSelected(String role) {
    setState(() {
      _selectedRole = role;
    });
  }

  Future<void> _handleContinue() async {
    if (_selectedRole == null) return;
    
    // Save selection
    await ref.read(localStorageServiceProvider).setSelectedRole(_selectedRole!);
    
    if (mounted) {
      NavHelpers.go(context, '/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top branding logo / back
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RoAd RoBo\'s',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to RoadRobos',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.2,
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 8),
                    const Text(
                      'Select your profile type to continue. You can change this or add roles later.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 36),

                    // Role Cards
                    _buildRoleCard(
                      role: 'customer',
                      title: 'Customer',
                      description: 'Book immediate/scheduled rides or local vehicle repair and services.',
                      icon: Iconsax.user,
                      activeColor: AppColors.primaryBlue,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0),

                    const SizedBox(height: 18),

                    _buildRoleCard(
                      role: 'driver',
                      title: 'Rider / Driver',
                      description: 'Register as an onboarded driver and earn by accepting trips and rides.',
                      icon: Iconsax.car,
                      activeColor: AppColors.accentOrange,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0),

                    const SizedBox(height: 18),

                    _buildRoleCard(
                      role: 'technician',
                      title: 'Service Partner / Tech',
                      description: 'Fulfill service requests, create job cards, and manage spare parts.',
                      icon: Iconsax.setting_2,
                      activeColor: AppColors.successGreen,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFDCFCE7), Color(0xFFBBF7D0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 500.ms).slideX(begin: 0.1, end: 0),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bottom Continue Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: CustomButton(
                label: 'Continue',
                onPressed: _selectedRole != null ? _handleContinue : null,
                backgroundColor: _selectedRole != null
                    ? (_selectedRole == 'customer'
                        ? AppColors.primaryBlue
                        : (_selectedRole == 'driver'
                            ? AppColors.accentOrange
                            : AppColors.successGreen))
                    : const Color(0xFFCBD5E1),
                borderRadius: 24,
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String description,
    required IconData icon,
    required Color activeColor,
    required Gradient gradient,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _onRoleSelected(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.12),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isSelected ? activeColor : const Color(0xFF475569),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? activeColor : const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? const Color(0xFF334155) : const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            // Radio Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeColor : const Color(0xFFCBD5E1),
                  width: isSelected ? 7 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
