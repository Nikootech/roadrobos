import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/shimmer_loading.dart';
import 'admin_providers.dart';

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

            const SizedBox(height: 24),
            const _AdminOpsThreeCardSection(),
            const SizedBox(height: 24),

            Text('Quick Access', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // Redesigned Quick Actions Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                final crossAxisCount = isWide ? 3 : 2;
                
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isWide ? 1.5 : 1.1,
                  children: [
                    _QuickActionCard(
                      title: 'Revenue',
                      subtitle: 'Analytics',
                      icon: Iconsax.chart_21,
                      color: AppColors.successGreen,
                      onTap: () => context.push('/admin-revenue-referral'),
                      badge: 'Live',
                    ),
                    _QuickActionCard(
                      title: 'Rides Map',
                      subtitle: 'Real-time',
                      icon: Icons.map_rounded,
                      color: AppColors.primaryBlue,
                      onTap: () => context.push('/admin-active-rides'),
                      badge: 'Track',
                    ),
                    _QuickActionCard(
                      title: 'Logistics',
                      subtitle: 'Hub Mgmt',
                      icon: Iconsax.house_2,
                      color: AppColors.deepNavy,
                      onTap: () => context.push('/admin-logistics-hub'),
                    ),
                    _QuickActionCard(
                      title: 'Permissions',
                      subtitle: 'Manage Roles',
                      icon: Iconsax.security_user,
                      color: AppColors.primaryBlue,
                      onTap: () => context.push('/admin-management'),
                    ),
                    _QuickActionCard(
                      title: 'Feedback',
                      subtitle: 'Sentiments',
                      icon: Icons.rate_review_rounded,
                      color: AppColors.successGreen,
                      onTap: () => context.push('/admin-feedback-analytics'),
                      badge: '4.8 ⭐',
                    ),
                    _QuickActionCard(
                      title: 'Offers',
                      subtitle: 'Coupons',
                      icon: Iconsax.discount_shape,
                      color: AppColors.warningAmber,
                      onTap: () => context.push('/admin-manage-offers'),
                      badge: 'Active',
                    ),
                  ],
                );
              },
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),
            // Minimal Alert Component
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.dangerRed.withValues(alpha: 0.05), 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.dangerRed.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Iconsax.warning_2, color: AppColors.dangerRed, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('System Alert', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: AppColors.dangerRed, fontSize: 14)),
                        const Text('High booking failure rate detected in Bandra zone.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.dangerRed),
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
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      blur: 10,
      opacity: 0.2,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(badge!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
              ),
            ),
        ],
      ),
    );
  }
}

class _AdminOpsThreeCardSection extends StatelessWidget {
  const _AdminOpsThreeCardSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 900;
        double cardWidth = isWide ? (constraints.maxWidth / 3) - 16 : constraints.maxWidth;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(width: cardWidth, child: const _CustomerOperationsCard()),
            SizedBox(width: cardWidth, child: const _DriverManagementCard()),
            SizedBox(width: cardWidth, child: const _TechnicianServicesCard()),
          ],
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// 1. CUSTOMER OPERATIONS CARD
// -----------------------------------------------------------------------------
class _CustomerOperationsCard extends ConsumerWidget {
  const _CustomerOperationsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(customersOpProvider);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      blur: 20,
      opacity: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Customers', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          asyncData.when(
            loading: () => const ShimmerListPlaceholder(itemCount: 1),
            error: (e, s) => const Text('Error loading customer ops', style: TextStyle(color: Colors.red)),
            data: (data) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric('Active', data.activeBookings.toString(), AppColors.primaryBlue),
                    _buildMetric('Rentals', data.activeRentals.toString(), AppColors.successGreen),
                    _buildMetric('Services', data.activeServices.toString(), AppColors.warningAmber),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.recentRides.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final ride = data.recentRides[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${ride.id} - ${ride.customer}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${ride.vehicle} • ${ride.time}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: ride.status == 'Active' ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(ride.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: ride.status == 'Active' ? AppColors.successGreen : AppColors.primaryBlue)),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(label: 'View All', height: 40, isOutlined: true, onPressed: () => context.push('/admin-customer-database')),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 2. DRIVER MANAGEMENT CARD
// -----------------------------------------------------------------------------
class _DriverManagementCard extends ConsumerWidget {
  const _DriverManagementCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(driversOpProvider);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      blur: 20,
      opacity: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚗', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Drivers', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          asyncData.when(
            loading: () => const ShimmerListPlaceholder(itemCount: 1),
            error: (e, s) => const Text('Error loading driver ops', style: TextStyle(color: Colors.red)),
            data: (data) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric('Online', data.online.toString(), AppColors.successGreen),
                    _buildMetric('Pending', data.pending.toString(), AppColors.warningAmber),
                    _buildMetric('Total', data.total.toString(), AppColors.deepNavy),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                if (data.topPending.isEmpty)
                  const Padding(padding: EdgeInsets.all(16), child: Text('No pending approvals', style: TextStyle(color: AppColors.textMuted)))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.topPending.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final driver = data.topPending[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(driver.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('Docs: ${driver.docsCount}/4 • ${driver.uploadDate}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, minimumSize: const Size(60, 28), padding: const EdgeInsets.symmetric(horizontal: 10)),
                              onPressed: () => ref.read(driversOpProvider.notifier).approve(driver.id),
                              child: const Text('Approve', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(label: 'Verify Docs', height: 40, backgroundColor: AppColors.deepNavy, onPressed: () => context.push('/admin-driver-database')),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// 3. TECHNICIAN SERVICES CARD
// -----------------------------------------------------------------------------
class _TechnicianServicesCard extends ConsumerWidget {
  const _TechnicianServicesCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(techOpProvider);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      blur: 20,
      opacity: 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔧', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text('Technician', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          asyncData.when(
            loading: () => const ShimmerListPlaceholder(itemCount: 1),
            error: (e, s) => const Text('Error loading tech ops', style: TextStyle(color: Colors.red)),
            data: (data) => Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetric('In Service', data.inService.toString(), AppColors.warningAmber),
                    _buildMetric('Progress', data.progress.toString(), AppColors.primaryBlue),
                    _buildMetric('Completed', data.completed.toString(), AppColors.successGreen),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.recentServices.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final job = data.recentServices[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job.regNo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('Tech: ${job.tech}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₹${job.invoiceAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.successGreen)),
                              Text(job.status, style: TextStyle(fontSize: 10, color: job.status == 'Completed' ? AppColors.textSecondary : AppColors.primaryBlue)),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(label: 'View Invoices', height: 40, isOutlined: true, onPressed: () => context.push('/admin-technician-database')),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}

