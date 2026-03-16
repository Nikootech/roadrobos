import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

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
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('New Ride Request', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              // Map Preview (Simulated)
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.bgLightGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Iconsax.map_1, color: AppColors.primaryBlue, size: 40),
              ),
              const SizedBox(height: 24),
              
              _buildLocationRow(Icons.radio_button_checked_rounded, AppColors.primaryBlue, 'Pick up', 'Huda City Centre, Gurgaon'),
              const SizedBox(height: 16),
              _buildLocationRow(Icons.location_on_rounded, AppColors.dangerRed, 'Drop off', 'DLF Cyber Hub, Tower 8'),
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFareStat('Distance', '4.2 km'),
                  _buildFareStat('Estimated', '12 min'),
                  _buildFareStat('Fare', '₹185', isMain: true),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Accept/Decline Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Decline', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      label: 'Accept',
                      onPressed: () {
                        context.pop();
                        // Navigate to active trip in a real app
                      },
                      backgroundColor: AppColors.successGreen,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Progress Timer Bar
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: 1 - _progressController.value,
                    backgroundColor: AppColors.bgLightGrey,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                    minHeight: 4,
                  );
                },
              ),
            ],
          ),
        ),
      ).animate().scale(begin: const Offset(0.9, 0.9), duration: 400.ms, curve: Curves.easeOutBack).fadeIn(),
    );
  }

  Widget _buildLocationRow(IconData icon, Color color, String label, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFareStat(String label, String value, {bool isMain = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: isMain ? 20 : 16, fontWeight: FontWeight.bold, color: isMain ? AppColors.successGreen : AppColors.textPrimary)),
      ],
    );
  }
}
