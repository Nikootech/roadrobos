import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../core/theme/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/local_storage_service.dart';

/// Onboarding Screen - Modern 3-slide PageView with real-time app hero illustrations:
/// Slide 1: Secure & Easy Payments (3D Smart Card & Security Badges)
/// Slide 2: Ease of Booking (Mobility Hub & Booking Pill Badges)
/// Slide 3: Live Telemetry & GPS Tracking (Radar Navigation & Live ETA Pin)
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      title: 'Secure & Easy\nPayments',
      description:
          'Seamless cashless payments with UPI, instant digital wallets, and encrypted 256-bit bank cards.',
      primaryColor: Color(0xFF006241),
      secondaryColor: Color(0xFF10B981),
      gradientColors: [Color(0xFF006241), Color(0xFF10B981)],
      type: _IllustrationType.payment,
    ),
    _OnboardingData(
      title: 'Effortless Rides &\nDoorstep Care',
      description:
          'Book on-demand cab rides or schedule doorstep car repairs & diagnostics with trusted certified mechanics.',
      primaryColor: Color(0xFFEA580C),
      secondaryColor: Color(0xFFF59E0B),
      gradientColors: [Color(0xFFEA580C), Color(0xFFF59E0B)],
      type: _IllustrationType.booking,
    ),
    _OnboardingData(
      title: 'Real-Time Telemetry\n& Live Tracking',
      description:
          'Monitor your vehicle’s journey in real-time with accurate live GPS radar, instant ETA, and driver alerts.',
      primaryColor: Color(0xFF0D9488),
      secondaryColor: Color(0xFF06B6D4),
      gradientColors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
      type: _IllustrationType.tracking,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() async {
    if (_currentPage < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      final router = GoRouter.of(context);
      await ref.read(localStorageServiceProvider).setOnboardingComplete();
      router.go('/auth/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeData = _pages[_currentPage];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Brand Mark
                  Row(
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
                      Text(
                        'RoadRobos',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  // Skip Button
                  GestureDetector(
                    onTap: () async {
                      final router = GoRouter.of(context);
                      await ref
                          .read(localStorageServiceProvider)
                          .setOnboardingComplete();
                      router.go('/auth/role-selection');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFFF1F5F9),
                      ),
                      child: Text(
                        AppStrings.skip,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // Bottom section with dynamic indicator + themed CTA button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                children: [
                  // Dot indicator with active slide's primary color
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      dotHeight: 7,
                      dotWidth: 7,
                      activeDotColor: activeData.primaryColor,
                      dotColor: const Color(0xFFE2E8F0),
                      spacing: 6,
                      expansionFactor: 3.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action button with dynamic gradient and glow
                  GestureDetector(
                    onTap: _onNext,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: activeData.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color:
                                activeData.primaryColor.withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentPage == 2
                                  ? AppStrings.getStarted
                                  : AppStrings.next,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _IllustrationType { payment, booking, tracking }

class _OnboardingData {
  final String title;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final List<Color> gradientColors;
  final _IllustrationType type;

  const _OnboardingData({
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.gradientColors,
    required this.type,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Hero Illustration Area (Rich 3D-styled Multi-Layered Composition)
          Expanded(
            flex: 5,
            child: Center(
              child: _buildHeroIllustration(data),
            ),
          ),

          // Typography Area
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.6,
                      height: 1.18,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.15, end: 0),
                  const SizedBox(height: 12),
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                      height: 1.45,
                    ),
                  )
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.15, end: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroIllustration(_OnboardingData data) {
    switch (data.type) {
      case _IllustrationType.payment:
        return _buildPaymentHero(data);
      case _IllustrationType.booking:
        return _buildBookingHero(data);
      case _IllustrationType.tracking:
        return _buildTrackingHero(data);
    }
  }

  // ── 1. SECURE & EASY PAYMENTS ──
  Widget _buildPaymentHero(_OnboardingData data) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Glow Ripple Ring
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  data.primaryColor.withValues(alpha: 0.14),
                  data.secondaryColor.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Secondary Background Circle Ring
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: data.primaryColor.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
          ),

          // Central Floating 3D Gradient Smart Card
          Transform.rotate(
            angle: -0.05,
            child: Container(
              width: 210,
              height: 130,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF006241),
                    Color(0xFF0A7C52),
                    Color(0xFF10B981)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: data.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Card Row: EMV Chip & Contactless Wave
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 30,
                        height: 22,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCD34D),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.contactless_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),

                  // Card Number Mask
                  Text(
                    '••••  ••••  ••••  8824',
                    style: GoogleFonts.sourceCodePro(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),

                  // Bottom Card Row: Expiry & Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'EXP 12/29',
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'RoadRobos Pay',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
              begin: -6, end: 6, duration: 2200.ms, curve: Curves.easeInOut),

          // Floating Top-Right 100% Secure Shield Badge
          Positioned(
            top: 40,
            right: 25,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF006241),
                    size: 18,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Verified Safe',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                begin: 5, end: -5, duration: 1900.ms, curve: Curves.easeInOut),
          ),

          // Floating Bottom-Left Instant UPI Transfer Badge
          Positioned(
            bottom: 45,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFFF59E0B),
                    size: 17,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Instant UPI & Cards',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                begin: -4, end: 4, duration: 2100.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  // ── 2. EASE OF BOOKING & MULTI-SERVICE ──
  Widget _buildBookingHero(_OnboardingData data) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Warm Glow
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  data.primaryColor.withValues(alpha: 0.14),
                  data.secondaryColor.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Secondary Warm Outer Ring
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: data.primaryColor.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
          ),

          // Central Floating Mobility Showcase Card
          Container(
            width: 190,
            height: 140,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFEA580C),
                  Color(0xFFF97316),
                  Color(0xFFF59E0B)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: data.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Vehicle & Service Dual Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.car,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Iconsax.setting_2,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Rides & Repairs',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '1-Tap Quick Booking',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
              begin: -6, end: 6, duration: 2200.ms, curve: Curves.easeInOut),

          // Floating Top-Right Schedule Pill
          Positioned(
            top: 42,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFFEA580C),
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Schedule or Instant',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                begin: 5, end: -5, duration: 2000.ms, curve: Curves.easeInOut),
          ),

          // Floating Bottom-Left Doorstep Service Badge
          Positioned(
            bottom: 40,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home_repair_service_rounded,
                    color: Color(0xFFEA580C),
                    size: 16,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Doorstep Mechanic',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                begin: -5, end: 5, duration: 1900.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }

  // ── 3. REAL-TIME LIVE TELEMETRY & GPS TRACKING ──
  Widget _buildTrackingHero(_OnboardingData data) {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Cyan Glow
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  data.primaryColor.withValues(alpha: 0.16),
                  data.secondaryColor.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Radar Concentric Grid Ring 1
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: data.primaryColor.withValues(alpha: 0.12),
                width: 1.5,
              ),
            ),
          ),

          // Radar Concentric Grid Ring 2
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: data.secondaryColor.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
          ),

          // Central GPS Radar Beacon Disc
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: data.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.near_me_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
              begin: const Offset(0.96, 0.96),
              end: const Offset(1.05, 1.05),
              duration: 1800.ms),

          // Floating Top Live ETA Pill Badge
          Positioned(
            top: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.3, 1.3),
                      duration: 800.ms),
                  const SizedBox(width: 6),
                  const Text(
                    'Driver Arriving in 4 mins',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                begin: -4, end: 4, duration: 2000.ms, curve: Curves.easeInOut),
          ),

          // Floating Bottom Location Route Pin Badge
          Positioned(
            bottom: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF0D9488),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Live GPS Radar',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(
                begin: 4, end: -4, duration: 1900.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}
