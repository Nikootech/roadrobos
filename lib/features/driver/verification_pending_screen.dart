import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'providers/driver_state_provider.dart';

class VerificationPendingScreen extends ConsumerStatefulWidget {
  const VerificationPendingScreen({super.key});

  @override
  ConsumerState<VerificationPendingScreen> createState() => _VerificationPendingScreenState();
}

class _VerificationPendingScreenState extends ConsumerState<VerificationPendingScreen> {
  late Timer _countdownTimer;
  int _secondsRemaining = 24 * 3600; // Simulated 24 hours

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      }
    });

    ref.listenManual(verificationProvider, (previous, next) {
      if (next == VerificationStatus.approved) {
        context.pushReplacement('/driver-home');
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(verificationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () => ref.read(verificationProvider.notifier).refreshStatus(),
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: status == VerificationStatus.rejected ? AppColors.dangerRed : AppColors.primaryBlue, width: 4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: const Icon(Iconsax.shield_tick, size: 60, color: AppColors.primaryBlue)
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(duration: 2.seconds, colors: [AppColors.primaryBlue, Colors.white, AppColors.primaryBlue]),
                    ),
                  ).animate(onPlay: (c) => status == VerificationStatus.pending ? c.repeat() : null).fade(duration: 2.seconds).scale(duration: 2.seconds),
                ),
                
                const SizedBox(height: 40),
                Text(
                  status == VerificationStatus.rejected ? 'Verification Failed' : 'Verification Underway',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our Rapido team is verifying your documents. This usually takes 24-48 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                ),
                
                const SizedBox(height: 40),
                // Status Timeline Cards
                _buildStatusCard('Driving License', 'DL Under Verification ✓', true),
                _buildStatusCard('Vehicle RC', 'RC Approved ✓', true),
                _buildStatusCard('Profile Photo', status == VerificationStatus.rejected ? 'Rejected ❌' : 'Pending ⏳', status != VerificationStatus.rejected, isWarning: status == VerificationStatus.rejected),
                
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.textPrimary, size: 20),
                      const SizedBox(width: 8),
                      Text('Estimated time left: ${_formatTime(_secondsRemaining)}', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepNavy)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                if (status == VerificationStatus.rejected)
                   CustomButton(label: 'RESUBMIT DOCS', onPressed: () => ref.read(verificationProvider.notifier).resubmit(), backgroundColor: AppColors.warningAmber)
                else
                   CustomButton(label: 'CONTACT SUPPORT', onPressed: () => context.push('/chat'), backgroundColor: AppColors.deepNavy),
                
                // Dev simulator
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => ref.read(verificationProvider.notifier).forceApprove(),
                  child: const Text('Simulate Approval (Dev)', style: TextStyle(color: AppColors.primaryBlue)),
                )
              ],
            ),
            
            // Blocking overlay ensuring no main app access
            Positioned(
              top: 40, left: 16,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => context.go('/auth/login'), // Back to start
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String subtitle, bool isGood, {bool isWarning = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.deepNavy)),
          Text(subtitle, style: TextStyle(fontWeight: FontWeight.bold, color: isWarning ? AppColors.dangerRed : (isGood ? AppColors.successGreen : AppColors.warningAmber))),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX();
  }
}
