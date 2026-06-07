import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import 'glass_card.dart';
import 'custom_button.dart';

class RentalCompletionDialog extends StatelessWidget {
  final String vehicleName;
  final VoidCallback onCompletePayment;
  final VoidCallback onReschedule;

  const RentalCompletionDialog({
    super.key,
    required this.vehicleName,
    required this.onCompletePayment,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Iconsax.timer_1, size: 40, color: AppColors.primaryBlue),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 24),
              const Text(
                'Rental Time Completed!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'Your rental period for $vehicleName has ended. Would you like to complete the payment now or reschedule the drop-off time?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
              ),
              
              const SizedBox(height: 32),
              CustomButton(
                label: 'COMPLETE PAYMENT',
                onPressed: onCompletePayment,
                backgroundColor: AppColors.successGreen,
                height: 52,
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'RESCHEDULE DROP-OFF',
                onPressed: onReschedule,
                backgroundColor: AppColors.deepNavy,
                height: 52,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Dismiss', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
