import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../navigation/nav_helpers.dart';
import 'rental_providers.dart';

class DeliveryLogisticsScreen extends ConsumerWidget {
  const DeliveryLogisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final vehicleName = selectedVehicle?['name'] ?? 'Your Vehicle';
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => NavHelpers.pop(context),
        ),
        title: const Text('Delivery Status', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             // Map Preview - REAL MAP
             Container(
               height: 180,
               width: double.infinity,
               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
               clipBehavior: Clip.antiAlias,
               child: const LiveMapWidget(height: 180, showLiveIndicator: false),
             ),
             
             const SizedBox(height: 32),
             _buildStatusStep('$vehicleName Prepared', 'Your vehicle has been sanitized and checked.', true, true),
             _buildStatusStep('Delivery in Progress', 'Our pilot is on the way to your location.', true, false),
             _buildStatusStep('Verification', 'E-KYC and signature on arrival.', false, false),
             
             const SizedBox(height: 32),
             // Pilot Details
             Container(
               padding: const EdgeInsets.all(20),
               decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
               child: Row(
                 children: [
                   const CircleAvatar(radius: 24, backgroundColor: Color(0xFFE8F1FF), child: Icon(Icons.person, color: AppColors.primaryBlue)),
                   const SizedBox(width: 16),
                   const Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('Akash Sharma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                         Text('Delivery Pilot', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                       ],
                     ),
                   ),
                   IconButton(icon: const Icon(Iconsax.call, color: AppColors.successGreen), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling delivery partner...'), behavior: SnackBarBehavior.floating))),
                   IconButton(icon: const Icon(Iconsax.message_text, color: AppColors.primaryBlue), onPressed: () => context.push('/chat')),
                 ],
               ),
             ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/main/home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Return to Home', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep(String title, String desc, bool isDone, bool isFirst) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: isDone ? AppColors.primaryBlue : AppColors.border, shape: BoxShape.circle),
            ),
            if(!isFirst) Container(width: 2, height: 40, color: isDone ? AppColors.primaryBlue : AppColors.border),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? AppColors.textPrimary : AppColors.textMuted)),
              Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms);
  }
}
