import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class ManpowerSupplyScreen extends StatelessWidget {
  const ManpowerSupplyScreen({super.key});

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
        title: const Text('Manpower Allocation', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Technician Status
            _buildStatusHeader(),
            const SizedBox(height: 32),
            
            _buildSectionHeader('Technicians by Hub'),
            const SizedBox(height: 16),
            _buildAllocationCard('Hyderabad Central', '12 Active', '4 On Leave', 0.75),
            const SizedBox(height: 12),
            _buildAllocationCard('Bangalore East', '18 Active', '2 On Leave', 0.90),
            const SizedBox(height: 12),
            _buildAllocationCard('Mumbai Hub', '9 Active', '6 On Leave', 0.60),
            
            const SizedBox(height: 32),
            _buildSectionHeader('Urgent Requirements'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.dangerRed.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.dangerRed.withOpacity(0.3))),
              child: const Row(
                children: [
                  Icon(Iconsax.warning_2, color: AppColors.dangerRed),
                  SizedBox(width: 16),
                  Expanded(child: Text('Delhi Hub reports 40% manpower shortage for tomorrow\'s morning shift.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.dangerRed))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      children: [
        _buildStatBox('Total Techs', '142', AppColors.primaryBlue),
        const SizedBox(width: 12),
        _buildStatBox('On Duty', '118', AppColors.successGreen),
        const SizedBox(width: 12),
        _buildStatBox('Available', '24', Colors.amber),
      ],
    );
  }

  Widget _buildStatBox(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const Icon(Iconsax.filter_search, size: 18, color: AppColors.textMuted),
      ],
    );
  }

  Widget _buildAllocationCard(String hub, String active, String leave, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(hub, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(active, style: const TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.bgLightGrey,
            color: AppColors.primaryBlue,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Capacity: 92%', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text(leave, style: const TextStyle(fontSize: 10, color: AppColors.dangerRed, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}

