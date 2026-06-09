import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/auth_service.dart';
import '../profile/user_provider.dart';
import '../../core/utils/app_debugger.dart';

/// Splash Screen - Animated logo reveal with auto-navigation
/// Matches precisely with user-provided image (Light theme, small blue circles)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigationHandled = false;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    // Use postFrameCallback so the widget tree is fully built first
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleNavigation());
  }

  Future<void> _handleNavigation() async {
    // Single unified loop: checks auth + profile state every 150ms.
    // Maximum wait: 10 seconds total, then forced redirect to login.
    const safetyTimeoutMs = 10000;
    const pollMs = 150;
    var elapsed = 0;
    var brandingShown = false;

    while (mounted && elapsed < safetyTimeoutMs) {
      await Future.delayed(const Duration(milliseconds: pollMs));
      elapsed += pollMs;

      if (_navigationHandled || !mounted) return;

      final authState = ref.read(authNotifierProvider);

      // Auth still resolving — keep waiting
      if (authState.isLoading) continue;

      // ── Not logged in ──────────────────────────────────────────────────────
      if (authState.value == null) {
        _navigationHandled = true;
        final localStorage = ref.read(localStorageServiceProvider);
        final isFirstLaunch = await localStorage.isFirstLaunch();

        // Minimum 500ms branding time (HTML splash already shows the logo)
        final remaining = 500 - elapsed;
        if (remaining > 0 && !brandingShown) {
          await Future.delayed(Duration(milliseconds: remaining));
          brandingShown = true;
        }

        if (!mounted) return;
        debugPrint('SplashScreen: Not logged in → ${isFirstLaunch ? "/onboarding" : "/auth/role-selection"}');
        context.go(isFirstLaunch ? '/onboarding' : '/auth/role-selection');
        return;
      }

      // ── Logged in — wait for profile ───────────────────────────────────────
      final userState = ref.read(userProvider);

      if (userState.showSessionMismatchPrompt) {
        // Session mismatch detected — pause loop and wait for user's action
        continue;
      }

      if (userState.user != null) {
        // Profile ready — GoRouter redirect guard handles the dashboard redirect
        debugPrint('SplashScreen: Profile loaded, GoRouter will redirect.');
        return;
      }

      if (userState.error != null && !userState.isLoading) {
        _navigationHandled = true;
        debugPrint('SplashScreen: Profile error → /auth/login');
        if (mounted) context.go('/auth/login');
        return;
      }
      // Profile still loading — continue polling
    }

    // Safety timeout
    if (!mounted || _navigationHandled) return;
    _navigationHandled = true;
    debugPrint('SplashScreen: Timeout → /auth/login');
    if (mounted) context.go('/auth/login');
  }

  void _showSessionMismatchDialog() {
    if (_dialogShowing) return;
    _dialogShowing = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.devices_rounded, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text('Active Session Detected', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Your account is currently active on another device/browser. '
          'Do you want to terminate that session and log in here? '
          'Otherwise, you will be signed out from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _dialogShowing = false;
              ref.read(userProvider.notifier).cancelSessionTakeover();
            },
            child: const Text('Cancel / Keep Old', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _dialogShowing = false;
              ref.read(userProvider.notifier).confirmSessionTakeover();
            },
            child: const Text('Terminate & Continue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserState>(userProvider, (previous, next) {
      if (next.showSessionMismatchPrompt) {
        _showSessionMismatchDialog();
      }
    });

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
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                if (AppDebugger.startupSteps.values.any((status) => status.startsWith('FAILED'))) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Running in fallback mode (some services offline)',
                    style: TextStyle(
                      color: Colors.amber.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            )
                .animate(delay: 800.ms)
                .fadeIn(duration: 500.ms),
          ),
        ],
      ),
    );
  }
}

