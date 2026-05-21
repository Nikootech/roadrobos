import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/service_booking_repository.dart';
import 'package:roadrobos/core/services/auth_service.dart';

class ServiceRemindersScreen extends ConsumerWidget {
  const ServiceRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.id;
    final servicesAsync = userId != null 
        ? ref.watch(serviceBookingRepositoryProvider).getPagedCustomerServiceBookings(userId, limit: 50) 
        : Future<List>.value([]);

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
      body: FutureBuilder(
        future: servicesAsync,
        builder: (context, snapshot) {
          final services = snapshot.data as List? ?? [];
          
          // Simple Health Calculation (Just for demo logic)
          double healthScore = 0.50; // Default: Needs attention
          String healthStatus = 'Needs Attention';
          
          if (services.isNotEmpty) {
            final lastServiceDate = services.first.createdAt;
            final daysSinceService = DateTime.now().difference(lastServiceDate).inDays;
            
            if (daysSinceService < 90) {
              healthScore = 0.95;
              healthStatus = 'Excellent Condition';
            } else if (daysSinceService < 180) {
              healthScore = 0.75;
              healthStatus = 'Good Condition';
            } else {
              healthScore = 0.55;
              healthStatus = 'Fair Condition';
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHealthOverhaulCard(healthScore, healthStatus),
              const SizedBox(height: 24),
              _buildSectionHeader('Upcoming Maintenance'),
              const SizedBox(height: 12),
              _buildReminderTile(
                'Oil Change Due',
                'Based on your last service',
                healthScore > 0.8 ? 'Condition: Good' : 'Required Soon',
                Icons.oil_barrel_rounded,
                healthScore > 0.8 ? AppColors.successGreen : AppColors.warningAmber,
              ),
              const SizedBox(height: 12),
              _buildReminderTile(
                'Brake Inspection',
                'Recommended every 6 months',
                'Check Status',
                Icons.settings_input_component_rounded,
                AppColors.primaryBlue,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Subscription & Documents'),
              const SizedBox(height: 12),
              _buildReminderTile(
                'Insurance Expiry',
                'Policy ending soon',
                'Expires in 8 days',
                Icons.shield_rounded,
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
          );
        },
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

  Widget _buildHealthOverhaulCard(double score, String status) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: score > 0.7 
              ? [AppColors.primaryBlue, AppColors.primaryBlueDark] 
              : [AppColors.warningAmber, Colors.deepOrange],
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
              const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            status,
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: score,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(score * 100).toInt()}% Health Score • Stay Safe!',
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
