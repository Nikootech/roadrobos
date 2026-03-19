import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'dart:async';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'providers/driver_state_provider.dart';

/// Verification Pending Screen — Premium Overhaul
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
        context.pushReplacement('/driver-verification-success');
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.go('/auth/login'),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          return ref.read(verificationProvider.notifier).refreshStatus();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
                  
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.1), blurRadius: 30)],
                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 2),
                    ),
                    child: Icon(
                      status == VerificationStatus.rejected ? Iconsax.shield_cross : Iconsax.shield_search,
                      size: 44,
                      color: status == VerificationStatus.rejected ? AppColors.dangerRed : AppColors.primaryBlue
                    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 3.seconds),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            Text(
              status == VerificationStatus.rejected ? 'Action Required' : 'Reviewing Application',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.deepNavy, letterSpacing: -0.5),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                status == VerificationStatus.rejected 
                  ? 'One or more documents were rejected. Please check the details below and resubmit.'
                  : 'We are currently verifying your professional documents. You\'ll be notified as soon as you\'re ready to ride.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: AppColors.textSecondary, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ),
            
            const SizedBox(height: 48),
            const SizedBox(height: 48),
            _buildSectionLabel('APPLICATION STATUS'),
            const SizedBox(height: 20),
            _buildPremiumStatusCard('Driving License', 'In Review', Iconsax.document_text, AppColors.primaryBlue),
            _buildPremiumStatusCard('Vehicle Registration', 'Approved', Iconsax.tick_circle, AppColors.successGreen),
            _buildPremiumStatusCard('Identity Verification', status == VerificationStatus.rejected ? 'Rejected' : 'Approved', Iconsax.personalcard, status == VerificationStatus.rejected ? AppColors.dangerRed : AppColors.successGreen),
            _buildPremiumStatusCard('Profile Photo', 'Approved', Iconsax.user, AppColors.successGreen),
            
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.bgLightGrey.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Text('ESTIMATED VERIFICATION TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  Text(
                    _formatTime(_secondsRemaining), 
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.deepNavy, letterSpacing: -0.5, fontFeatures: [FontFeature.tabularFigures()])
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
            
            const SizedBox(height: 40),
            if (status == VerificationStatus.rejected)
               CustomButton(label: 'RESUBMIT DOCUMENTS', onPressed: () => ref.read(verificationProvider.notifier).resubmit(), backgroundColor: AppColors.dangerRed)
            else
               CustomButton(label: 'SUPPORT CENTER', onPressed: () => context.push('/help-center'), backgroundColor: AppColors.deepNavy),
            
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => ref.read(verificationProvider.notifier).forceApprove(),
                child: const Text('Simulate Approval (Debug Mode)', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.5));
  }

  Widget _buildPremiumStatusCard(String title, String status, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15))),
          Text(status, style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 12)),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
