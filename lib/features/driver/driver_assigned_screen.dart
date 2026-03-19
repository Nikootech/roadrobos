import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/live_map_widget.dart';

/// Driver Assigned Screen matching Figma Screen [9]
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

          // Top Controls (390x100)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFloatingButton(Icons.arrow_back_ios_new_rounded, onTap: () => context.pop()),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                          Icon(Icons.directions, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Navigate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          // Sheet Content (390x362)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(width: 48, height: 6, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  
                  // Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_arrived ? 'Waiting for passenger...' : 'Picking up passenger', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(_arrived ? 'Arrived at pickup' : '2 mins away • 800m', style: TextStyle(color: _arrived ? AppColors.successGreen : AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle),
                        child: Icon(_arrived ? Icons.person_pin_circle_rounded : Icons.directions_car_rounded, color: AppColors.textPrimary),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Passenger Info
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: const Icon(Icons.person, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rahul Sharma', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            SizedBox(height: 2),
                            Text('Payment: Cash', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Iconsax.message, size: 18, color: AppColors.primaryBlue)),
                          const SizedBox(width: 12),
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Iconsax.call, size: 18, color: AppColors.successGreen)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Action Button
                  CustomButton(
                    label: _arrived ? 'START TRIP' : 'I\'VE ARRIVED',
                    onPressed: () {
                      if (!_arrived) {
                        setState(() => _arrived = true);
                      } else {
                        // Enter OTP flow ideally, but we pop back home for flow demo
                        context.pop();
                      }
                    },
                    backgroundColor: _arrived ? AppColors.successGreen : AppColors.primaryBlue,
                  ),
                ],
              ),
            ).animate().slideY(begin: 1.0, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),
          )
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}

