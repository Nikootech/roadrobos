import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class SelectServiceTypeScreen extends StatelessWidget {
  const SelectServiceTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Select Service',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Professional Services\nfor your Vehicle',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),
              _buildServiceCategoryCard(
                context,
                'EV Bike Service',
                'Electric vehicle specialized maintenance',
                Icons.bolt_rounded,
                AppColors.primaryBlue,
                '/ev-bike-service-booking',
              ),
              const SizedBox(height: 16),
              _buildServiceCategoryCard(
                context,
                'Bike Service',
                'Comprehensive packages for all bike models',
                Icons.pedal_bike_rounded,
                AppColors.primaryBlue,
                '/bike-service-booking',
              ),
              const SizedBox(height: 16),
              _buildServiceCategoryCard(
                context,
                'Car Service',
                'Premium care and repairs for your car',
                Icons.directions_car_rounded,
                AppColors.accentOrange,
                '/car-service-booking',
              ),
              const SizedBox(height: 16),
              _buildServiceCategoryCard(
                context,
                'Emergency Help',
                'Roadside assistance 24/7',
                Icons.emergency_rounded,
                AppColors.dangerRed,
                '/live-tracking',
              ),
              const SizedBox(height: 32),
              const Text(
                'Recent Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),
              _buildRecentServiceTile('General Service', '12 Jan 2024', 'Completed'),
              _buildRecentServiceTile('Oil Change', '05 Dec 2023', 'Completed'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCategoryCard(BuildContext context, String title, String desc, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgSkyLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted.withValues(alpha: 0.5)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildRecentServiceTile(String name, String date, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.bgLightGrey,
            child: Icon(Icons.history, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.successGreen)),
        ],
      ),
    );
  }
}

