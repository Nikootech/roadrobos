import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

/// Screen Gallery — lets you jump to ANY screen in the app.
/// Accessible from the Home screen for demo/testing.
class ScreenGalleryScreen extends StatelessWidget {
  const ScreenGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgWhite,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.go('/main/home'),
        ),
        title: const Text('All Screens',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('A', 'Splash & Onboarding',
              Icons.auto_awesome_rounded, const Color(0xFF8B5CF6)),
          _buildScreenTile(context, 'Splash Screen', 'Animated logo reveal',
              Iconsax.flash_1, '/splash'),
          _buildScreenTile(context, 'Onboarding', '3-page swipeable intro',
              Iconsax.document, '/onboarding'),
          _buildSectionHeader('B', 'Authentication', Icons.lock_rounded,
              const Color(0xFF3B82F6)),
          _buildScreenTile(context, 'Login Screen',
              'Email/password + Demo mode', Iconsax.login, '/auth/login'),
          _buildScreenTile(context, 'Register Screen', 'Create new account',
              Iconsax.user_add, '/auth/register'),
          _buildSectionHeader('C', 'Main App (Tabs)', Icons.apps_rounded,
              const Color(0xFF22C55E)),
          _buildScreenTile(context, 'Home', 'Dashboard, services, carousel',
              Iconsax.home_25, '/main/home'),
          _buildScreenTile(context, 'Bookings', 'Service booking history',
              Iconsax.calendar, '/main/bookings'),
          _buildScreenTile(context, 'Explore', 'Service categories grid',
              Iconsax.search_normal, '/main/explore'),
          _buildScreenTile(context, 'Profile', 'User profile & settings',
              Iconsax.user, '/main/profile'),
          _buildSectionHeader('D', 'Customer Sub-screens',
              Icons.directions_car_rounded, const Color(0xFFF97316)),
          _buildScreenTile(context, 'Detail / Job Card',
              'Service checklist & pricing', Iconsax.document_text, '/detail'),
          _buildScreenTile(context, 'Add Vehicle', 'Vehicle intake form',
              Iconsax.add_circle, '/add-vehicle'),
          _buildScreenTile(context, 'Service Feedback',
              'Star ratings & analytics', Iconsax.star, '/service-feedback'),
          _buildScreenTile(context, 'Book a Ride',
              'Location pick + vehicle select', Iconsax.car, '/book-ride'),
          _buildScreenTile(context, 'Live Tracking', 'Map + driver info + SOS',
              Iconsax.location, '/live-tracking'),
          _buildScreenTile(context, 'Wallet', 'Balance, top-up, transactions',
              Iconsax.wallet_1, '/wallet'),
          _buildScreenTile(context, 'Vehicle Rentals', 'Filter & rent vehicles',
              Iconsax.driving, '/rentals'),
          _buildScreenTile(context, 'Ride History',
              'Past rides & services tabs', Iconsax.clock, '/ride-history'),
          _buildScreenTile(context, 'Referral', 'Invite friends, earn rewards',
              Iconsax.gift, '/referral'),
          _buildScreenTile(context, 'Chat / Support', 'In-app messaging',
              Iconsax.message, '/chat'),
          _buildSectionHeader('E', 'Driver & Technician', Icons.build_rounded,
              const Color(0xFFEF4444)),
          _buildScreenTile(
              context,
              'Driver Home',
              'Online/Offline toggle, earnings',
              Iconsax.driving,
              '/driver-home'),
          _buildScreenTile(context, 'Driver Assigned',
              'Active trip map + passenger', Iconsax.map, '/driver-assigned'),
          _buildScreenTile(context, 'Driver Earnings',
              'Charts & payout history', Iconsax.chart_2, '/driver-earnings'),
          _buildScreenTile(context, 'Technician Tasks',
              'Kanban board (Pending/Done)', Iconsax.task, '/tech-tasks'),
          _buildScreenTile(context, 'Tech Job Card', 'Interactive checklist',
              Iconsax.clipboard_tick, '/tech-job-card'),
          _buildSectionHeader('F', 'Admin Console', Icons.shield_rounded,
              const Color(0xFF6366F1)),
          _buildScreenTile(
              context,
              'Admin Dashboard',
              'Stats, quick actions, alerts',
              Iconsax.chart_square,
              '/admin-home'),
          _buildScreenTile(context, 'Revenue Analytics',
              'Line chart & breakdown', Iconsax.chart_1, '/admin-revenue'),
          _buildScreenTile(context, 'KYC Approval', 'Document review & approve',
              Iconsax.document_1, '/admin-kyc'),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      String letter, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(letter,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          Icon(icon, size: 18, color: color),
        ],
      ),
    );
  }

  Widget _buildScreenTile(BuildContext context, String title, String subtitle,
      IconData icon, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        onTap: () => context.push(route),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        subtitle: Text(subtitle,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.textMuted),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.03, end: 0);
  }
}
