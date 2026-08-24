import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

    // ── Fast-path: attempt cached route immediately on auth confirm ───────────
    // Preload from SharedPreferences in parallel while waiting for auth stream.
    final localStorage = ref.read(localStorageServiceProvider);
    final cachedRouteFuture = localStorage.getLastHomeRoute();

    while (mounted && elapsed < safetyTimeoutMs) {
      await Future.delayed(const Duration(milliseconds: pollMs));
      elapsed += pollMs;

      if (_navigationHandled || !mounted) return;

      final authState = ref.read(authNotifierProvider);

      // Auth still resolving — keep waiting
      if (authState.isLoading) continue;

      // ── Enforce pending role re-login ──────────────────────────────────────
      final isRoleReloginPending =
          await localStorage.isPendingRoleReloginRequired();
      if (isRoleReloginPending) {
        _navigationHandled = true;
        await localStorage.clearPendingRoleReloginRequired();
        await localStorage.clearSelectedRole();
        await localStorage.clearLastHomeRoute();
        await ref.read(userProvider.notifier).logout();
        if (!mounted) return;
        debugPrint(
            'SplashScreen: Pending role change re-login enforced → /auth/login');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Your account role was updated by an Administrator. Please log in again to enter your new workspace.'),
            backgroundColor: Color(0xFF006241),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/auth/login');
        return;
      }

      // ── Not logged in ──────────────────────────────────────────────────────
      if (authState.value == null) {
        // If there is an active code exchange in the URL, wait for it
        final hasCode = Uri.base.queryParameters.containsKey('code');
        if (hasCode && elapsed < 4000) {
          continue; // Keep waiting for token exchange
        }

        _navigationHandled = true;
        final isFirstLaunch = await localStorage.isFirstLaunch();

        // Minimum 500ms branding time (HTML splash already shows the logo)
        final remaining = 500 - elapsed;
        if (remaining > 0 && !brandingShown) {
          await Future.delayed(Duration(milliseconds: remaining));
          brandingShown = true;
        }

        if (!mounted) return;
        debugPrint(
            'SplashScreen: Not logged in → ${isFirstLaunch ? "/onboarding" : "/auth/role-selection"}');
        context.go(isFirstLaunch ? '/onboarding' : '/auth/role-selection');
        return;
      }

      // ── Logged in ──────────────────────────────────────────────────────────
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

      // ── Instant redirect: profile still loading but we have a cached route ─
      // On web, the Supabase profile fetch takes 200-800ms after OAuth redirect.
      // Instead of freezing on splash, redirect immediately using the last known
      // home route (saved after every successful profile load). Profile finishes
      // loading in the background and the router/provider will update the UI.
      // We wait 300ms minimum to avoid a flash when the profile loads quickly.
      if (elapsed >= 300 && userState.isLoading) {
        final cachedRoute = await cachedRouteFuture;
        if (cachedRoute != null && mounted && !_navigationHandled) {
          _navigationHandled = true;
          debugPrint(
              'SplashScreen: Profile loading → instant redirect via cache: $cachedRoute');
          context.go(cachedRoute);
          return;
        }
      }

      // Profile still loading, no cache yet — continue polling
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
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF1E222B)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.4
                        : 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.devices_rounded,
                      color: AppColors.brandGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Active Session Detected',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Your account is currently active on another device/browser. Do you want to terminate that session and log in here? Otherwise, you will be signed out from this device.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _dialogShowing = false;
                  ref.read(userProvider.notifier).confirmSessionTakeover();
                },
                child: Text(
                  'Terminate & Continue',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.7)
                          : AppColors.textSecondary,
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.border,
                  ),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  _dialogShowing = false;
                  ref.read(userProvider.notifier).cancelSessionTakeover();
                },
                child: Text(
                  'Cancel / Keep Old',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ambient background radial glow
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandGreenLight.withValues(alpha: 0.08),
                    AppColors.brandGreen.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1.25, 1.25),
                  duration: 2600.ms,
                  curve: Curves.easeInOut,
                ),
          ),

          // Expanding Pulse Rings behind the logo
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.brandGreenMid.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1.4, 1.4),
                        duration: 2800.ms,
                        curve: Curves.easeOut,
                      )
                      .fadeOut(duration: 2800.ms),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            AppColors.brandGreenLight.withValues(alpha: 0.18),
                        width: 1.5,
                      ),
                    ),
                  )
                      .animate(delay: 900.ms, onPlay: (c) => c.repeat())
                      .scale(
                        begin: const Offset(0.85, 0.85),
                        end: const Offset(1.4, 1.4),
                        duration: 2800.ms,
                        curve: Curves.easeOut,
                      )
                      .fadeOut(duration: 2800.ms),
                ],
              ),
            ),
          ),

          // Center Breathing Logo Stage
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Transparent Breathing Logo
                Image.asset(
                  'assets/app_icon.png',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/signin_icon.png',
                    width: 160,
                    height: 160,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.local_shipping_rounded,
                      size: 80,
                      color: AppColors.brandGreen,
                    ),
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(0.96, 0.96),
                      end: const Offset(1.08, 1.08),
                      duration: 1200.ms,
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 36),

                // Branded App Title
                Text(
                  AppStrings.appName,
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: const Color(0xFF12231A),
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.1, end: 0, duration: 500.ms),

                const SizedBox(height: 6),

                // Tagline / Mobility subtitle
                Text(
                  'Smart Mobility & Vehicle Assistance',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                    color: AppColors.brandGreenMid,
                  ),
                ).animate(delay: 450.ms).fadeIn(duration: 500.ms),
              ],
            ),
          ),

          // Bottom loading indicator
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brandGreen,
                    ),
                    backgroundColor:
                        AppColors.brandGreen.withValues(alpha: 0.12),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Loading experience...',
                  style: GoogleFonts.inter(
                    color: AppColors.brandGreen.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                if (AppDebugger.startupSteps.values
                    .any((status) => status.startsWith('FAILED'))) ...[
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
            ).animate(delay: 600.ms).fadeIn(duration: 500.ms),
          ),
        ],
      ),
    );
  }
}
