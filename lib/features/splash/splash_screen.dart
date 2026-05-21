import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/local_storage_service.dart';

/// Splash Screen - Animated logo reveal with auto-navigation
/// Matches precisely with user-provided image (Light theme, small blue circles)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    final localStorage = ref.read(localStorageServiceProvider);
    final isFirstLaunch = await localStorage.isFirstLaunch();
    
    // Maintain splash for at least 1500ms for branding
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      if (isFirstLaunch) {
        context.go('/onboarding');
      } else {
        context.go('/auth/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top-left decorative circles (Precisely matched sizes and positions)
          Positioned(
            top: -size.width * 0.1,
            left: -size.width * 0.1,
            child: Container(
              width: size.width * 0.5,
              height: size.width * 0.5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0F9FF), // Extremely pale blue
              ),
            ),
          ).animate().fadeIn(duration: 800.ms),
          
          Positioned(
            top: size.height * 0.05,
            left: -size.width * 0.2,
            child: Container(
              width: size.width * 0.45,
              height: size.width * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE0F2FE).withValues(alpha: 0.6), // Soft sky blue
              ),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 800.ms),

          // Bottom-right decorative circle (Precisely matched)
          Positioned(
            bottom: size.height * 0.15,
            right: -size.width * 0.1,
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF0F9FF), // Extremely pale blue
              ),
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 800.ms),

          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Icon Card
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.directions_car_rounded,
                      size: 64,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      duration: 800.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 64), // Significant spacing as per image

                // App name (Navy-black, precise weight)
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B), // Navy-black matched to image
                    letterSpacing: -1.2,
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.1, end: 0, duration: 600.ms),
              ],
            ),
          ),

          // Bottom loading indicator
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 1.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlue.withValues(alpha: 0.4),
                  ),
                ),
              ),
            )
                .animate(delay: 800.ms)
                .fadeIn(duration: 500.ms),
          ),
        ],
      ),
    );
  }
}

