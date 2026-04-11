import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class MyVehiclesScreen extends StatelessWidget {
  const MyVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('My Vehicles', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
           Expanded(
             child: ListView.separated(
               padding: const EdgeInsets.all(24),
               itemCount: 2,
               separatorBuilder: (_, __) => const SizedBox(height: 16),
               itemBuilder: (context, index) {
                 return _buildVehicleCard(index);
               },
             ),
           ),
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
             child: ElevatedButton.icon(
               onPressed: () => context.push('/add-vehicle'),
               icon: const Icon(Iconsax.add_circle, size: 20),
               label: const Text('ADD NEW VEHICLE'),
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppColors.primaryBlue,
                 foregroundColor: Colors.white,
                 minimumSize: const Size(double.infinity, 56),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
               ),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(int index) {
    final v = index == 0 ? 'Maruti Baleno' : 'Bajaj Pulsar 220';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: AppColors.primaryBlue.withOpacity(0.1), child: Icon(index == 0 ? Icons.directions_car : Icons.directions_bike, color: AppColors.primaryBlue)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('TS 08 EX 4567', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Iconsax.edit, size: 18, color: AppColors.textMuted),
            ],
          ),
          const Divider(height: 32),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Service Due', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text('In 45 Days', style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

