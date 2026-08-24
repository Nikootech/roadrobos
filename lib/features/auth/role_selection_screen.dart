import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/local_storage_service.dart';
import '../../navigation/nav_helpers.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
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
    final hasSelection = _selectedRole != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFCFB),
      body: SafeArea(
        child: Column(
          children: [
            // Top branding bar with actual RoadRobos logo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/app_icon.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/signin_icon.png',
                      width: 36,
                      height: 36,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.local_shipping_rounded,
                        color: AppColors.brandGreen,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'RoadRobos',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Choose Your Experience',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.8,
                        height: 1.15,
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.15, end: 0),
                    const SizedBox(height: 6),
                    Text(
                      'Select your profile type to continue. You can seamlessly switch or add roles anytime.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    )
                        .animate(delay: 80.ms)
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.15, end: 0),

                    const SizedBox(height: 24),

                    // 1. Customer (Emerald & Mint Theme)
                    _buildPremiumRoleCard(
                      role: 'customer',
                      tag: 'RIDES & SERVICES',
                      title: 'Customer',
                      description:
                          'Book on-demand rides, doorstep vehicle maintenance, and 24/7 emergency roadside rescue.',
                      mainIcon: Iconsax.user,
                      miniIcon: Icons.location_on_rounded,
                      primaryColor: const Color(0xFF006241),
                      secondaryColor: const Color(0xFF10B981),
                      bgTint: const Color(0xFFF0FDF4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006241), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                        .animate(delay: 150.ms)
                        .fadeIn(duration: 450.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 14),

                    // 2. Rider / Driver (Vibrant Sunset Amber & Tangerine)
                    _buildPremiumRoleCard(
                      role: 'driver',
                      tag: 'DRIVE & EARN',
                      title: 'Driver / Pilot',
                      description:
                          'Drive with RoadRobos, accept immediate trip requests, and receive instant daily payouts.',
                      mainIcon: Iconsax.car,
                      miniIcon: Icons.trending_up_rounded,
                      primaryColor: const Color(0xFFEA580C),
                      secondaryColor: const Color(0xFFF59E0B),
                      bgTint: const Color(0xFFFFF7ED),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                        .animate(delay: 250.ms)
                        .fadeIn(duration: 450.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 14),

                    // 3. Service Partner / Tech (Electric Cyan & Deep Teal)
                    _buildPremiumRoleCard(
                      role: 'technician',
                      tag: 'PRO WORKSHOP',
                      title: 'Service Partner / Tech',
                      description:
                          'Receive repair job cards, perform smart diagnostics, and manage verified genuine spare parts.',
                      mainIcon: Iconsax.setting_2,
                      miniIcon: Icons.verified_rounded,
                      primaryColor: const Color(0xFF0D9488),
                      secondaryColor: const Color(0xFF06B6D4),
                      bgTint: const Color(0xFFF0FDFA),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                        .animate(delay: 350.ms)
                        .fadeIn(duration: 450.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 14),

                    // 4. Core Team (Royal Slate & Steel Blue)
                    _buildPremiumRoleCard(
                      role: 'admin',
                      tag: 'ENTERPRISE OPS',
                      title: 'Core Team',
                      description:
                          'Fleet telemetry, area manager console, technician dispatch, and platform analytics.',
                      mainIcon: Iconsax.briefcase,
                      miniIcon: Icons.shield_rounded,
                      primaryColor: const Color(0xFF1E293B),
                      secondaryColor: const Color(0xFF3B82F6),
                      bgTint: const Color(0xFFF8FAFC),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    )
                        .animate(delay: 450.ms)
                        .fadeIn(duration: 450.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Bottom Continue CTA with interactive animation
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: GestureDetector(
                onTap: hasSelection ? _handleContinue : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: hasSelection
                        ? LinearGradient(
                            colors: _getRoleGradient(_selectedRole!),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: hasSelection ? null : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: hasSelection
                        ? [
                            BoxShadow(
                              color: _getRolePrimaryColor(_selectedRole!)
                                  .withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue as ${_getRoleTitle(_selectedRole)}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: hasSelection
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                            letterSpacing: 0.2,
                          ),
                        ),
                        if (hasSelection) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumRoleCard({
    required String role,
    required String tag,
    required String title,
    required String description,
    required IconData mainIcon,
    required IconData miniIcon,
    required Color primaryColor,
    required Color secondaryColor,
    required Color bgTint,
    required Gradient gradient,
  }) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _onRoleSelected(role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
            width: isSelected ? 2.2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.16),
                    blurRadius: 22,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Multi-layered 3D-effect Visual Emblem
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Glowing background squircle
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(
                            alpha: isSelected ? 0.35 : 0.2),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      mainIcon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                // Floating Specular Mini Badge
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        miniIcon,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // Content & Typography
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Tag Chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor.withValues(alpha: 0.1)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tag,
                          style: GoogleFonts.inter(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: isSelected
                                ? primaryColor
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF1E293B),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Description
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: isSelected
                          ? const Color(0xFF334155)
                          : const Color(0xFF64748B),
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Selection Radio / Check Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryColor : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryColor : const Color(0xFFCBD5E1),
                  width: isSelected ? 0 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getRoleGradient(String role) {
    switch (role) {
      case 'customer':
        return [const Color(0xFF006241), const Color(0xFF10B981)];
      case 'driver':
        return [const Color(0xFFEA580C), const Color(0xFFF59E0B)];
      case 'technician':
        return [const Color(0xFF0D9488), const Color(0xFF06B6D4)];
      case 'admin':
      default:
        return [const Color(0xFF1E293B), const Color(0xFF3B82F6)];
    }
  }

  Color _getRolePrimaryColor(String role) {
    switch (role) {
      case 'customer':
        return const Color(0xFF006241);
      case 'driver':
        return const Color(0xFFEA580C);
      case 'technician':
        return const Color(0xFF0D9488);
      case 'admin':
      default:
        return const Color(0xFF1E293B);
    }
  }

  String _getRoleTitle(String? role) {
    switch (role) {
      case 'customer':
        return 'Customer';
      case 'driver':
        return 'Driver';
      case 'technician':
        return 'Technician';
      case 'admin':
        return 'Core Team';
      default:
        return '...';
    }
  }
}
