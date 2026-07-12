import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_card.dart';

class LogisticsHubScreen extends StatelessWidget {
  const LogisticsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Logistics Hub',
          style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fleet distribution
            Text('Fleet Distribution',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildFleetCard('2-Wheelers', '1,240', Icons.directions_bike),
                const SizedBox(width: 12),
                _buildFleetCard('4-Wheelers', '840', Icons.directions_car),
              ],
            ),

            const SizedBox(height: 32),
            Text('Zone Performance',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _buildZoneCard(
                'Zone A (Central)', '92% Utilization', 'High Demand'),
            _buildZoneCard('Zone B (North)', '74% Utilization', 'Normal'),
            _buildZoneCard('Zone C (South)', '88% Utilization', 'High Demand'),

            const SizedBox(height: 32),
            Text('Hub Status',
                style: GoogleFonts.outfit(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  _buildHubDetailRow(
                      'Main Hub S-017', 'Online', AppColors.successGreen),
                  const Divider(height: 32),
                  _buildHubDetailRow(
                      'Satellite Hub N-102', 'Online', AppColors.successGreen),
                  const Divider(height: 32),
                  _buildHubDetailRow(
                      'Satellite Hub W-044', 'Maintenance', Colors.amber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFleetCard(String label, String count, IconData icon) {
    return Expanded(
      child: GlassCard(
        blur: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 28),
            const SizedBox(height: 16),
            Text(count,
                style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildZoneCard(String zone, String stats, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(zone, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(stats,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: (status == 'Normal'
                        ? AppColors.primaryBlue
                        : AppColors.dangerRed)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Text(status,
                style: TextStyle(
                    color: status == 'Normal'
                        ? AppColors.primaryBlue
                        : AppColors.dangerRed,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }

  Widget _buildHubDetailRow(String name, String status, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 16),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        const Spacer(),
        Text(status,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
