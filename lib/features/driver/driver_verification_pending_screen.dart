import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

class DriverVerificationPendingScreen extends StatelessWidget {
  const DriverVerificationPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lottie Animation (using a placeholder icon container since actual lottie file may not exist)
              Container(
                 width: 200,
                 height: 200,
                 decoration: BoxDecoration(
                   color: AppColors.primaryBlue.withValues(alpha: 0.05),
                   shape: BoxShape.circle,
                 ),
                 child: const Icon(Icons.history_rounded, size: 100, color: AppColors.primaryBlue),
              ).animate(onPlay: (c) => c.repeat()).rotate(duration: 10.seconds),
              const SizedBox(height: 48),
              const Text(
                'Verification Pending',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your documents have been submitted successfully. Our team is currently reviewing them.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 40),
              
              // Progress Stepper
              _buildStep('Documents Received', true, true),
              _buildStep('Identity Verification', true, false),
              _buildStep('Final Approval', false, false),
              
              const SizedBox(height: 64),
              const Text(
                'Estimated time: 24-48 hours',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Back to Login',
                onPressed: () => context.go('/auth/login'),
                backgroundColor: AppColors.deepNavy,
              ),
              // Developer shortcut for success
              TextButton(
                onPressed: () => context.push('/driver-verification-success'),
                child: const Text('Simulate Success (Dev Only)', style: TextStyle(color: AppColors.primaryBlue)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String title, bool isCompleted, bool isCurrent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.successGreen : (isCurrent ? AppColors.primaryBlue : AppColors.bgLightGrey),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : (isCurrent ? Icons.more_horiz : Icons.circle),
              size: 14,
              color: isCompleted || isCurrent ? Colors.white : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
              color: isCurrent ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1, end: 0);
  }
}

