import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

/// Admin Dashboard Overview matching Figma Screen [87]
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: AppColors.deepNavy, shape: BoxShape.circle),
              child: const Icon(Icons.shield_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Console', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const Text('Super Admin Level', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Iconsax.notification, color: AppColors.textPrimary),
                Positioned(right: 2, top: 2, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.dangerRed, shape: BoxShape.circle)))
              ],
            ),
            onPressed: () => context.push('/notifications'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Overview', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                  child: const Row(
                    children: [
                      Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 16)
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // Stat Cards Grid
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Revenue', '₹84,500', Iconsax.wallet_1, AppColors.successGreen, '+12%')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Active Rides', '124', Icons.local_taxi_rounded, AppColors.primaryBlue, '+5%')),
              ],
            ).animate().slideY(begin: 0.1, end: 0).fadeIn(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Services Pending', '32', Icons.build_rounded, AppColors.warningAmber, '-2%')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('KYC Approvals', '18', Icons.document_scanner_rounded, AppColors.dangerRed, '+8%')),
              ],
            ).animate(delay: 100.ms).slideY(begin: 0.1, end: 0).fadeIn(),

            const SizedBox(height: 32),
            Text('Quick Access', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // Quick Actions List
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                children: [
                  _buildListTile('Revenue & Referrals', 'Leaderboards & growth', Iconsax.chart_21, AppColors.successGreen, () => context.push('/admin-revenue-referral')),
                  const Divider(height: 1, indent: 64),
                  _buildListTile('Active Rides Map', 'Real-time logistics', Icons.map_rounded, AppColors.primaryBlue, () => context.push('/admin-active-rides')),
                  const Divider(height: 1, indent: 64),
                  _buildListTile('Fleet Logistics', 'Hub & zone performance', Iconsax.house_2, AppColors.deepNavy, () => context.push('/admin-logistics-hub')),
                  const Divider(height: 1, indent: 64),
                  _buildListTile('Admin Management', 'Roles and permissions', Iconsax.security_user, AppColors.primaryBlue, () => context.push('/admin-management')),
                  const Divider(height: 1, indent: 64),
                  _buildListTile('Customer Database', 'Profiles and engagement', Iconsax.user_square, AppColors.warningAmber, () => context.push('/admin-customer-database')),
                  const Divider(height: 1, indent: 64),
                  _buildListTile('Feedback Analytics', 'Sentiment and reviews', Icons.rate_review_rounded, AppColors.successGreen, () => context.push('/admin-feedback-analytics')),
                  const Divider(height: 1, indent: 64),
                  _buildListTile('Offers & Coupons', 'Manage promotions', Iconsax.discount_shape, AppColors.warningAmber, () => context.push('/admin-manage-offers')),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 32),
            // Minimal Alert Component
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Iconsax.warning_2, color: AppColors.dangerRed),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('System Alert', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.dangerRed)),
                        Text('High booking failure rate detected in Bandra zone.', style: TextStyle(fontSize: 12, color: AppColors.dangerRed)),
                      ],
                    ),
                  )
                ],
              ),
            ).animate(delay: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String trend) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: trend.startsWith('+') ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(trend, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: trend.startsWith('+') ? AppColors.successGreen : AppColors.dangerRed))),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, Color bgIconColor, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgIconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: bgIconColor),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
    );
  }
}

