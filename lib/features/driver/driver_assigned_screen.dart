import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/live_map_widget.dart';

/// Driver Assigned Screen matching Figma Screen [9] — Premium Overhaul
class DriverAssignedScreen extends StatefulWidget {
  const DriverAssignedScreen({super.key});

  @override
  State<DriverAssignedScreen> createState() => _DriverAssignedScreenState();
}

class _DriverAssignedScreenState extends State<DriverAssignedScreen> {
  bool _arrived = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Map Background Section
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              captainLocation: const LatLng(12.9716, 77.5946),
            ),
          ),

          // Top Controls (Status Bar Overlay)
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFloatingButton(Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.directions_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('NAVIGATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)),
                        ],
                      ),
                    ).animate().fadeIn().scale(),
                  ],
                ),
              ),
            ),
          ),

          // Sliding Trip Info Sheet
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pull Handle
                  Container(width: 48, height: 6, decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  
                  // Trip Status & Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _arrived ? 'Waiting for passenger...' : 'Picking up passenger',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (_arrived ? AppColors.successGreen : AppColors.primaryBlue).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time_filled_rounded, size: 14, color: _arrived ? AppColors.successGreen : AppColors.primaryBlue),
                                      const SizedBox(width: 6),
                                      Text(
                                        _arrived ? 'Arrived at pickup' : '2 mins away • 800m',
                                        style: TextStyle(
                                          color: _arrived ? AppColors.successGreen : AppColors.primaryBlue,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1),
                        ),
                        child: Icon(_arrived ? Icons.person_pin_circle_rounded : Icons.directions_car_rounded, color: AppColors.primaryBlue, size: 32),
                      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms),
                    ],
                  ),
                  const SizedBox(height: 28),
                  
                  // Destination Preview (Premium touch)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.bgLightGrey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: AppColors.dangerRed, size: 18),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Terminal 3, IGI Airport',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ),
                        Text('DROP OFF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),

                  // Passenger Info
                  Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?u=rahul'), fit: BoxFit.cover),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rahul Sharma', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                                SizedBox(width: 4),
                                Text('4.8 • ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                Text('Wallet Payment', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _buildActionIcon(Iconsax.message, AppColors.primaryBlue, () => {}),
                      const SizedBox(width: 12),
                      _buildActionIcon(Iconsax.call, AppColors.successGreen, () => {}),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Interactive Slider or Premium Button
                  CustomButton(
                    label: _arrived ? 'SLIDE TO START TRIP' : 'I\'VE ARRIVED',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (!_arrived) {
                        setState(() => _arrived = true);
                      } else {
                        context.pop();
                      }
                    },
                    backgroundColor: _arrived ? AppColors.successGreen : AppColors.primaryBlue,
                  ).animate().scale(delay: 500.ms),
                ],
              ),
            ).animate().slideY(begin: 0.5, end: 0, duration: 800.ms, curve: Curves.easeOutQuart),
          )
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) onTap();
      },
      child: Container(
        width: 44, height: 44,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
