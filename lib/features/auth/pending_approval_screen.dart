import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../profile/user_provider.dart';
import '../../shared/widgets/custom_button.dart';
import '../../navigation/nav_helpers.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    final userState = ref.read(userProvider);
    final user = userState.user;
    if (user == null) return;

    setState(() => _isChecking = true);
    
    try {
      // Force fetch the profile from database to get fresh approval status
      await ref.read(userProvider.notifier).fetchUserProfile(user.id);
      
      final freshState = ref.read(userProvider);
      if (mounted) {
        setState(() => _isChecking = false);
        if (freshState.user != null && freshState.user!.isApproved) {
          NavHelpers.showSuccess(context, 'Account approved! Welcome to the team.');
          // Router handles redirecting to the employee dashboard automatically
        } else {
          NavHelpers.showSnackAction(
            context,
            'Account is still pending approval.',
            icon: Iconsax.info_circle,
            color: AppColors.accentOrange,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
        NavHelpers.showError(context, 'Failed to check status: $e');
      }
    }
  }

  Future<void> _handleLogout() async {
    await ref.read(userProvider.notifier).logout();
    if (mounted) {
      NavHelpers.go(context, '/auth/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final user = userState.user;

    final roleName = user?.role.name.toUpperCase().replaceAll('_', ' ') ?? 'STAFF MEMBER';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Animated Illustration Container
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Pulsing Circle
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1500.ms, curve: Curves.easeInOut),
                    
                    // Center Warning/Pending Icon
                    const Icon(
                      Iconsax.user_tick,
                      color: AppColors.accentOrange,
                      size: 52,
                    ),
                  ],
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),

              const SizedBox(height: 36),

              // Title
              Text(
                'Approval Pending',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Your employee account is awaiting verification by an administrator. You will be granted access once approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.blueGrey.shade500,
                  height: 1.4,
                ),
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 32),

              // Info Box with user details
              if (user != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Name',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          Text(
                            user.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Requested Role',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              roleName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentOrange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0),

              const Spacer(),

              // Status check button
              CustomButton(
                label: 'Check Status',
                onPressed: _checkStatus,
                isLoading: _isChecking,
                backgroundColor: AppColors.accentOrange,
                borderRadius: 24,
              ).animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: 16),

              // Logout / Back to selection
              TextButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Iconsax.logout, size: 18),
                label: const Text('Log Out'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blueGrey.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ).animate(delay: 600.ms).fadeIn(),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
