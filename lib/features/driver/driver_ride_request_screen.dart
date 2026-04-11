import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

/// Driver Ride Request Screen — Premium "Incoming Call" Style Overhaul
class DriverRideRequestScreen extends StatefulWidget {
  const DriverRideRequestScreen({super.key});

  @override
  State<DriverRideRequestScreen> createState() => _DriverRideRequestScreenState();
}

class _DriverRideRequestScreenState extends State<DriverRideRequestScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: 15.seconds)
      ..forward().then((value) {
        if (mounted) context.pop(); // Auto-decline after timeout
      });
    
    // Simulate haptic feedback on arrival of request
    Future.delayed(500.ms, () {
      HapticFeedback.vibrate();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Stack(
        children: [
          // Background Gradient/Blur effect
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [AppColors.primaryBlue.withOpacity(0.2), Colors.black],
                ),
              ),
            ),
          ),
          
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryBlue.withOpacity(0.3), blurRadius: 40, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('NEW RIDE REQUEST', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 1.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(8)),
                        child: const Text('PREMIUM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Map Preview with Pulse
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.bgLightGrey,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Icon(Iconsax.map_1, color: AppColors.primaryBlue.withOpacity(0.3), size: 60),
                        ),
                      ),
                      const Icon(Icons.circle, color: AppColors.primaryBlue, size: 12)
                          .animate(onPlay: (c) => c.repeat())
                          .scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(3, 3))
                          .fadeOut(),
                    ],
                  ),
                  const SizedBox(height: 28),
                  
                  _buildPremiumLocation(Icons.radio_button_checked_rounded, AppColors.primaryBlue, 'PICKUP', 'Huda City Centre, Gurgaon'),
                  const SizedBox(height: 8),
                  Container(width: 2, height: 16, color: AppColors.bgLightGrey, margin: const EdgeInsets.only(left: 9)),
                  const SizedBox(height: 8),
                  _buildPremiumLocation(Icons.location_on_rounded, AppColors.dangerRed, 'DROP OFF', 'DLF Cyber Hub, Tower 8'),
                  
                  const SizedBox(height: 28),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRequestStat('DISTANCE', '4.2 km'),
                      _buildRequestStat('TIME', '12 min'),
                      _buildRequestStat('FARE', '₹185', isMain: true),
                    ],
                  ),
                  
                  const SizedBox(height: 36),
                  
                  // Progress Timer Bar (Thin & High-end)
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return Column(
                        children: [
                          LinearProgressIndicator(
                            value: 1 - _progressController.value,
                            backgroundColor: AppColors.bgLightGrey,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 8),
                          Text('Accept within ${(15 - (_progressController.value * 15)).toInt()}s', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Accept/Decline Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            context.pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Decline', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          label: 'ACCEPT',
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            context.pushReplacement('/driver-assigned');
                          },
                          backgroundColor: AppColors.successGreen,
                        ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(delay: 1.seconds),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().scale(begin: const Offset(0.85, 0.85), duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildPremiumLocation(IconData icon, Color color, String label, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              Text(address, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequestStat(String label, String value, {bool isMain = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: isMain ? 24 : 16, fontWeight: FontWeight.w900, color: isMain ? AppColors.deepNavy : AppColors.textPrimary)),
      ],
    );
  }
}
