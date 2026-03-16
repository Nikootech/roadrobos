import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';

class JobCardDetailsScreen extends StatelessWidget {
  const JobCardDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Job Details', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Iconsax.export, color: AppColors.primaryBlue), onPressed: () => NavHelpers.showSuccess(context, 'Job card exported!')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('JOB-004', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                    Text('Completed Oct 15, 2023', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('COMPLETED', style: TextStyle(color: AppColors.successGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            _buildSection(
              title: 'Vehicle Details',
              child: const Row(
                children: [
                  Icon(Icons.directions_car_filled_rounded, color: AppColors.primaryBlue),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Maruti Baleno', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('MH 01 ZX 9876 • Petrol', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            _buildSection(
              title: 'Service Summary',
              child: Column(
                children: [
                  _buildSummaryRow('Service Type', 'General Service'),
                  _buildSummaryRow('Technician', 'Rajesh Kumar'),
                  _buildSummaryRow('Total Tasks', '6/6 Completed'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Parts Used', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildPartRow('Engine Oil (Synthetic)', '₹1,500'),
                  _buildPartRow('Oil Filter', '₹350'),
                  _buildPartRow('Air Filter', '₹450'),
                  const Divider(),
                  _buildPartRow('Total Parts', '₹2,300', isTotal: true),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Documentation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildPhotoThumb(),
                const SizedBox(width: 12),
                _buildPhotoThumb(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5)),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildPartRow(String label, String price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isTotal ? 14 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(price, style: TextStyle(fontSize: isTotal ? 14 : 13, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildPhotoThumb() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.white),
    );
  }
}

