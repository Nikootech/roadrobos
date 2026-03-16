import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';

class ActiveRidesScreen extends StatelessWidget {
  const ActiveRidesScreen({super.key});

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
        title: Text(
          'Active Rides',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
           IconButton(icon: const Icon(Iconsax.filter, color: AppColors.primaryBlue), onPressed: () => NavHelpers.showComingSoon(context, 'Ride filters')),
        ],
      ),
      body: Column(
        children: [
          // Summary bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Active', '42'),
                _buildSummaryItem('In Transit', '28'),
                _buildSummaryItem('Pending', '14'),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildRideCard(index, context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRideCard(int index, BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFF0F4FF), child: Icon(Icons.person, color: AppColors.primaryBlue)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ravi Verma', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('ID: RID-201938', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.successGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: const Text('ON TRIP', style: TextStyle(color: AppColors.successGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildLocationRow(Icons.radio_button_checked, AppColors.primaryBlue, 'Hitech City, Hyderabad'),
          const SizedBox(height: 12),
          _buildLocationRow(Icons.location_on_rounded, AppColors.dangerRed, 'Gachibowli DLF, Hyderabad'),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Maruti Suzuki Swift', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('TS 08 EX 4567', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/live-tracking'),
                child: Text(
                  'View Live',
                  style: GoogleFonts.outfit(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 50.ms * index).slideX(begin: 0.1, end: 0);
  }

  Widget _buildLocationRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
      ],
    );
  }
}

