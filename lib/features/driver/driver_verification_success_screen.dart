import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

/// Driver Verification Success Screen — Premium Overhaul
class DriverVerificationSuccessScreen extends StatelessWidget {
  const DriverVerificationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Play a haptic burst for celebration
    Future.delayed(300.ms, () => HapticFeedback.heavyImpact());

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background "Confetti" dots (Simulated)
          ...List.generate(6, (index) => Positioned(
            top: 200 + (index * 60),
            left: 50 + (index * 40),
            child: Icon(Icons.circle, size: 8, color: AppColors.primaryBlue.withValues(alpha: 0.1))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: 20, duration: (1 + index * 0.2).seconds)
                .fadeIn(),
          )),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 160, height: 160,
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                      
                      Container(
                        width: 100, height: 100,
                        decoration: const BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.successGreen, blurRadius: 20, spreadRadius: -5)],
                        ),
                        child: const Icon(Iconsax.tick_circle, size: 60, color: Colors.white),
                      ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                    ],
                  ),
                  
                  const SizedBox(height: 56),
                  Text(
                    'Verification Successful!',
                    style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.deepNavy, letterSpacing: -1),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 16),
                  const Text(
                    'Congratulations Captain! Your profile is verified. You are now authorized to accept ride requests.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.6, fontWeight: FontWeight.w500),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                  
                  const SizedBox(height: 72),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      label: 'START EARNING',
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        context.go('/driver-home');
                      },
                      backgroundColor: AppColors.deepNavy,
                    ).animate().scale(delay: 800.ms).fadeIn(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
