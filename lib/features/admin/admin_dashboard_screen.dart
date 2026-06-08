import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/shimmer_loading.dart';
import 'admin_providers.dart';
import '../../core/repositories/admin_ops_repository.dart';

/// Admin Dashboard Overview matching Figma Screen [87]
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {


  void _showSystemAlertDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.dangerRed.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.info_outline_rounded, color: AppColors.dangerRed),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('High Failure Rate Detected', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const Text('Bandra - Santa Cruz Zone', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            _buildDetailRow('Root Cause', 'Potential network congestion or app version mismatch detected among 42 active drivers.', Icons.search_rounded),
            const SizedBox(height: 16),
            _buildDetailRow('Impact', 'Estimated 15% revenue loss in last 30 minutes. Customer wait times increased by 8 mins.', Icons.flash_on_rounded),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deepNavy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Acknowledge & Notify Team', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String desc, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgLightGrey,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE6D5), // Soft peach for avatar
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Center(
                  child: Image.network(
                    'https://i.pravatar.cc/150?img=12', // Placeholder avatar
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.orange),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Good Morning, Alex', // Static for now as per design
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 28),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Alerts Section (Phase 3/4)
            ref.watch(emergencyAlertsProvider).when(
              data: (alerts) {
                if (alerts.isEmpty) return const SizedBox.shrink();
                final latest = alerts.first;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: InkWell(
                    onTap: () {
                       // Logic to view details
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.dangerRed.withValues(alpha: 0.1), Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.dangerRed, width: 2),
                      ),
                      child: Row(
                        children: [
                          const _AnimatedEmergencyIcon(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('🚨 SOS EMERGENCY', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.dangerRed, fontSize: 16)),
                                    Text('${latest.timestamp.hour}:${latest.timestamp.minute}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('User: ${latest.userId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(latest.message, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.dangerRed),
                        ],
                      ),
                    ),
                  ),
                ).animate().shimmer(duration: 2.seconds, color: Colors.white24).shake(offset: const Offset(2, 0));
              },
              loading: () => const SizedBox.shrink(),
              error: (e, s) => const SizedBox.shrink(),
            ),

            // System Health Card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.battery_charging_full_rounded, color: AppColors.successDark, size: 24),
                          const SizedBox(width: 12),
                          Text('System Health', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: AppColors.successDark, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text('Live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.92,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.successDark),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('92% Active', style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      Text('All systems operational.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1, end: 0).fadeIn(),
            const SizedBox(height: 16),

            // Stat Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                _buildStatCard('Total Revenue', '₹84.5k'),
                _buildStatCard('Active Rides', '124'),
                _buildStatCard('Pending Services', '32'),
                InkWell(
                  onTap: () => context.push('/admin-approvals'),
                  child: _buildStatCard('KYC Approvals', '18'),
                ),
              ],
            ).animate(delay: 100.ms).slideY(begin: 0.1, end: 0).fadeIn(),

            const SizedBox(height: 24),
            const _AdminOpsThreeCardSection(),
            const SizedBox(height: 24),

            Text('Quick Access', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // Redesigned Quick Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _QuickActionCard(
                  title: 'Revenue',
                  subtitle: 'Analytics',
                  icon: Icons.bar_chart_rounded,
                  onTap: () => context.push('/admin-revenue-referral'),
                ),
                _QuickActionCard(
                  title: 'Rides Map',
                  subtitle: 'Real-time',
                  icon: Icons.map_rounded,
                  onTap: () => context.push('/admin-active-rides'),
                ),
                _QuickActionCard(
                  title: 'Logistics',
                  subtitle: 'Hub Mgmt',
                  icon: Icons.warehouse_rounded,
                  onTap: () => context.push('/admin-logistics-hub'),
                ),
                 _QuickActionCard(
                  title: 'Permissions',
                  subtitle: 'Manage Roles',
                  icon: Icons.admin_panel_settings_rounded,
                  onTap: () => context.push('/admin-management'),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _QuickActionCard(
                  title: 'Approvals',
                  subtitle: 'Maker Checker',
                  icon: Icons.check_circle_outline_rounded,
                  onTap: () => context.push('/admin-approvals'),
                ),
                _QuickActionCard(
                  title: 'Feedback',
                  subtitle: 'Sentiments',
                  icon: Icons.rate_review_rounded,
                  onTap: () => context.push('/admin-feedback-analytics'),
                ),
                _QuickActionCard(
                  title: 'Offers',
                  subtitle: 'Coupons',
                  icon: Icons.local_offer_rounded,
                  onTap: () => context.push('/admin-manage-offers'),
                ),
                _QuickActionCard(
                  title: 'Audit Logs',
                  subtitle: 'Activity Trail',
                  icon: Icons.history_rounded,
                  onTap: () => context.push('/admin/audit-logs'),
                ),
              ],
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),
            // Minimal Alert Component
            InkWell(
              onTap: _showSystemAlertDetails,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.dangerRed.withValues(alpha: 0.05), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppColors.dangerRed, shape: BoxShape.circle),
                      child: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('System Alert', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.dangerRed)),
                          Text('High booking failure rate in Bandra', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.dangerRed)
                  ],
                ),
              ),
            ).animate(delay: 400.ms).fadeIn(),
          ],
        ),
      ),
    );
  }



  Widget _buildStatCard(String title, String value) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const Spacer(),
          const Text('Updated just now', style: TextStyle(fontSize: 11, color: AppColors.successDark)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.successDark.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.successDark, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
        final bool isWide = constraints.maxWidth > 900;
        final double cardWidth = isWide ? (constraints.maxWidth / 3) - 16 : constraints.maxWidth;
        
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
                              onPressed: () => ref.read(adminOpsRepositoryProvider).approveDriver(driver.id),
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

class _AnimatedEmergencyIcon extends StatefulWidget {
  const _AnimatedEmergencyIcon();
  @override
  State<_AnimatedEmergencyIcon> createState() => _AnimatedEmergencyIconState();
}

class _AnimatedEmergencyIconState extends State<_AnimatedEmergencyIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.dangerRed.withValues(alpha: 0.1 + (_controller.value * 0.2)),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.dangerRed.withValues(alpha: _controller.value), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.dangerRed.withValues(alpha: 0.3 * _controller.value),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Icon(Icons.error_outline_rounded, color: AppColors.dangerRed, size: 24),
        );
      },
    );
  }
}

