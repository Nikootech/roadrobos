import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class ServiceRemindersScreen extends StatelessWidget {
  const ServiceRemindersScreen({super.key});

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
          'Service Reminders',
          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHealthOverhaulCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Upcoming Maintenance'),
          const SizedBox(height: 12),
          _buildReminderTile(
            'Oil Change Due',
            'Maruti Baleno (MH 01 ZX 9876)',
            'In 450 km or 12 days',
            Iconsax.lamp_charge,
            AppColors.warningAmber,
          ),
          const SizedBox(height: 12),
          _buildReminderTile(
            'Brake Inspection',
            'Maruti Baleno (MH 01 ZX 9876)',
            'Scheduled for Oct 25, 2023',
            Iconsax.mask,
            AppColors.primaryBlue,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Subscription & Documents'),
          const SizedBox(height: 12),
          _buildReminderTile(
            'Insurance Expiry',
            'Policy ending soon',
            'Expired in 8 days',
            Iconsax.shield_tick,
            AppColors.dangerRed,
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Stay on top of your vehicle health to ensure a smooth and safe drive.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildHealthOverhaulCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vehicle Health',
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const Icon(Iconsax.info_circle, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Good Condition',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.85,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '85% Health Score • Next Service: 2,400 km away',
            style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn().scale(duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildReminderTile(String title, String subtitle, String status, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: GoogleFonts.outfit(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }
}
