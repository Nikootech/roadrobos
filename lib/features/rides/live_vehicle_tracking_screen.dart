import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

/// Live Vehicle Tracking Screen matching Figma Screen [67]: "Live Vehicle Tracking"
/// Shows precise vehicle location, battery/fuel status, and speed.
class LiveVehicleTrackingScreen extends StatelessWidget {
  const LiveVehicleTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      body: Stack(
        children: [
          // Detailed Map Background
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF1F5F9), // Lighter map base
              child: Stack(
                children: [
                   // Simulated Route
                  Center(
                    child: CustomPaint(
                      size: const Size(double.infinity, double.infinity),
                      painter: _RoutePainter(),
                    ),
                  ),
                  // Vehicle Marker with Pulse
                  Positioned(
                    top: 300,
                    left: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 2000.ms).fadeOut(),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.directions_car, color: Colors.white, size: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Header (390x100)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildNavButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Iconsax.info_circle, color: AppColors.primaryBlue, size: 18),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Hyundai Creta', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                Text('MH 02 AB 1234', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildNavButton(icon: Iconsax.settings),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Stats Sheet
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(Iconsax.flash_1, '82%', 'Battery', AppColors.successGreen),
                      Container(width: 1, height: 40, color: AppColors.border),
                      _buildStatItem(Iconsax.speedometer, '45 km/h', 'Speed', AppColors.primaryBlue),
                      Container(width: 1, height: 40, color: AppColors.border),
                      _buildStatItem(Iconsax.location, '2.4 km', 'Distance', AppColors.warningAmber),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Icon(Iconsax.map_1, color: AppColors.textSecondary, size: 18),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sector 45, Gurgaon, Haryana 122003',
                          style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuart).fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.2)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(100, 500)
      ..lineTo(180, 320)
      ..lineTo(300, 250);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

