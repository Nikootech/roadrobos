import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

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
          'Driver Profile',
          style: GoogleFonts.outfit(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit, color: AppColors.primaryBlue),
            onPressed: () {
              // Edit Profile Logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=12'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.successGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rajesh Kumar',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Partner since Jan 2024',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Performance Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('4.8', 'Rating', Icons.star_rounded, AppColors.warningAmber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('1,240', 'Total Rides', Iconsax.car, AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('98%', 'Acceptance', Icons.check_circle_rounded, AppColors.successGreen),
                ),
              ],
            ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Section: Vehicle Info
            _buildSectionHeader('Vehicle Details'),
            const SizedBox(height: 12),
            GlassCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.car, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Swift Dzire (VXI)',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'DL 01 AB 1234 • White',
                          style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 24),

            // Section: Documents
            _buildSectionHeader('Documents & Verification'),
            const SizedBox(height: 12),
            _buildDocumentTile('Driving License', 'Verified', Iconsax.card_pos, true),
            const SizedBox(height: 12),
            _buildDocumentTile('Vehicle Insurance', 'Expiring in 12 days', Iconsax.shield_tick, false),
            const SizedBox(height: 12),
            _buildDocumentTile('Address Proof', 'Verified', Iconsax.location, true),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(fontSize: 10, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTile(String title, String status, IconData icon, bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  status,
                  style: GoogleFonts.outfit(
                    color: isVerified ? AppColors.successGreen : AppColors.dangerRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (isVerified)
            const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 18)
          else
            const Icon(Icons.warning_rounded, color: AppColors.warningAmber, size: 18),
        ],
      ),
    );
  }
}
