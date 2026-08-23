import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/admin_bottom_nav_bar.dart';

// --- TECHNICIAN MODEL ---
class AdminTechnician {
  final String id;
  final String uid;
  final String name;
  final String phone;
  final String specialization;
  final String joinDate;
  final int booked;
  final int undergoing;
  final int completed;
  final double rating;
  final List<TechJob> jobs;

  AdminTechnician({
    required this.id,
    required this.uid,
    required this.name,
    required this.phone,
    required this.specialization,
    required this.joinDate,
    required this.booked,
    required this.undergoing,
    required this.completed,
    required this.rating,
    required this.jobs,
  });
}

class TechJob {
  final String regNo;
  final String vehicleType;
  final String status;
  final double invoice;
  final String date;
  TechJob(this.regNo, this.vehicleType, this.status, this.invoice, this.date);
}

final adminTechProvider = StreamProvider<List<AdminTechnician>>((ref) async* {
  final repo = ref.read(adminOpsRepositoryProvider);
  final techs = await repo.getAllTechnicians();

  yield techs.map((map) {
    final realId = map['id']?.toString() ?? '';
    final id = realId.length > 8 ? realId.substring(0, 8).toUpperCase() : (realId.isNotEmpty ? realId.toUpperCase() : 'TECH-NEW');
    final name = map['name'] ?? map['full_name'] ?? 'Master Technician';
    final phone = map['phone'] ?? '+91 98200 44556';
    final specialization = map['specialization'] ?? 'EV & Auto Specialist';
    final createdAt = map['created_at'] != null
        ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
        : DateTime.now();

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dateStr = '${months[createdAt.month - 1]} ${createdAt.year}';

    final sampleJobs = [
      TechJob('MH-02-CB-1904', 'Honda City • Periodic Service', 'In Progress', 4200.0, 'Today, 11:00 AM'),
      TechJob('MH-04-AX-8812', 'Hyundai Creta • Brake Overhaul', 'Completed', 6800.0, 'Yesterday'),
    ];

    return AdminTechnician(
      id: id,
      uid: realId,
      name: name,
      phone: phone,
      specialization: specialization,
      joinDate: dateStr,
      booked: (map['booked_jobs'] as int?) ?? 2,
      undergoing: (map['ongoing_jobs'] as int?) ?? 1,
      completed: (map['completed_jobs'] as int?) ?? 38,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      jobs: sampleJobs,
    );
  }).toList();
});

final techSearchProvider = StateProvider<String>((ref) => '');
final techFilterProvider = StateProvider<String>((ref) => 'All');

// --- SCREEN ---
class TechnicianDatabaseScreen extends ConsumerWidget {
  const TechnicianDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(techSearchProvider);
    final activeFilter = ref.watch(techFilterProvider);
    final techsAsync = ref.watch(adminTechProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 65,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.textPrimary),
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technician Roster & Dispatch',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Master engineers, job assignment & workloads',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brandGreenBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Iconsax.refresh,
                  size: 18, color: AppColors.brandGreen),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(adminTechProvider);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: [
                // Modern Search Field
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Iconsax.search_normal_1,
                          size: 18, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) =>
                              ref.read(techSearchProvider.notifier).state = val,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search by technician name, skill, or ID...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted.withValues(alpha: 0.9),
                            ),
                            filled: false,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (search.isNotEmpty)
                        GestureDetector(
                          onTap: () =>
                              ref.read(techSearchProvider.notifier).state = '',
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(Icons.close_rounded,
                                size: 18, color: AppColors.textMuted),
                          ),
                        )
                      else
                        const SizedBox(width: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Tabs Bar
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(ref, 'All', activeFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(ref, 'Active On-Site', activeFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(ref, 'Available for Dispatch', activeFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(ref, 'Top Rated', activeFilter),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: techsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.brandGreen),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.warning_2, size: 40, color: AppColors.dangerRed),
                    const SizedBox(height: 12),
                    Text('Failed to load technician database',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandGreen),
                      onPressed: () => ref.invalidate(adminTechProvider),
                      child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
              data: (techs) {
                final filtered = techs.where((t) {
                  final matchesSearch = t.name.toLowerCase().contains(search.toLowerCase()) ||
                      t.id.toLowerCase().contains(search.toLowerCase()) ||
                      t.specialization.toLowerCase().contains(search.toLowerCase());
                  if (!matchesSearch) return false;

                  if (activeFilter == 'Active On-Site') return t.undergoing > 0;
                  if (activeFilter == 'Available for Dispatch') return t.booked == 0;
                  if (activeFilter == 'Top Rated') return t.rating >= 4.8;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFEF3C7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Iconsax.setting_4, size: 48, color: Color(0xFFD97706)),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            search.isNotEmpty ? 'No technicians matching "$search"' : 'No technicians in this filter',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            search.isNotEmpty ? 'Try searching with another name or skill.' : 'Try changing your filter.',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () {
                              ref.read(techSearchProvider.notifier).state = '';
                              ref.read(techFilterProvider.notifier).state = 'All';
                            },
                            icon: const Icon(Icons.restart_alt_rounded, size: 16),
                            label: const Text('Reset Search & Filters'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brandGreen,
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: filtered.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final totalActive = techs.fold<int>(0, (sum, t) => sum + t.undergoing);
                      final totalCompleted = techs.fold<int>(0, (sum, t) => sum + t.completed);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem('Total Engineers', '${techs.length}', Colors.white),
                              Container(width: 1, height: 28, color: Colors.white24),
                              _buildSummaryItem('Live On-Site', '$totalActive', const Color(0xFF38BDF8)),
                              Container(width: 1, height: 28, color: Colors.white24),
                              _buildSummaryItem('Completed Services', '$totalCompleted', const Color(0xFF34D399)),
                            ],
                          ),
                        ),
                      );
                    }

                    final tech = filtered[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildTechCard(context, ref, tech)
                          .animate()
                          .fadeIn(delay: (index * 40).ms)
                          .slideY(begin: 0.08, end: 0),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String current) {
    final isSelected = label == current;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(techFilterProvider.notifier).state = label;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.brandGreen : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showAssignBookingDialog(
      BuildContext context, WidgetRef ref, AdminTechnician technician) async {
    final repo = ref.read(adminOpsRepositoryProvider);

    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.brandGreen)),
    ));

    List<Map<String, dynamic>> unassignedBookings = [];
    try {
      unassignedBookings = await repo.getUnassignedServiceBookings();
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading bookings: $e'), behavior: SnackBarBehavior.floating));
      }
      return;
    }

    if (unassignedBookings.isEmpty) {
      if (context.mounted) {
        unawaited(showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text('No Pending Bookings', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            content: const Text('All customer service bookings are currently assigned to active technicians.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Understood', style: TextStyle(color: AppColors.brandGreen, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ));
      }
      return;
    }

    if (context.mounted) {
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Dispatch Service to ${technician.name}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: unassignedBookings.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFFF1F5F9)),
              itemBuilder: (context, index) {
                final booking = unassignedBookings[index];
                final bookingId = booking['id'].toString();
                final packageName = booking['package_name'] ?? 'Periodic Service';
                final vehicle = booking['vehicle_name'] ?? 'Vehicle';
                final date = booking['booking_date'] ?? 'Today';
                final cost = booking['total_cost'] ?? '0';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(packageName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('$vehicle • $date\nID: #${bookingId.length > 8 ? bookingId.substring(0, 8).toUpperCase() : bookingId}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  trailing: Text('₹$cost', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.brandGreen, fontSize: 14)),
                  onTap: () async {
                    Navigator.pop(context);
                    unawaited(showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.brandGreen)),
                    ));

                    try {
                      await repo.assignTechnicianToBooking(bookingId, technician.uid);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Technician assigned & dispatched successfully!'), behavior: SnackBarBehavior.floating),
                        );
                        ref.invalidate(adminTechProvider);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Assignment failed: $e'), behavior: SnackBarBehavior.floating),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ));
    }
  }

  Widget _buildTechCard(BuildContext context, WidgetRef ref, AdminTechnician t) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          iconColor: AppColors.brandGreen,
          collapsedIconColor: AppColors.textSecondary,
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Iconsax.setting_4, color: Color(0xFFD97706), size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            t.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${t.id}',
                            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${t.specialization} • ${t.phone}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text(
                    t.rating.toStringAsFixed(1),
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildBadge('📅', '${t.booked} Scheduled', const Color(0xFFD97706)),
                _buildBadge('⚙️', '${t.undergoing} In Progress', const Color(0xFF0284C7)),
                _buildBadge('✅', '${t.completed} Completed', AppColors.brandGreen),
              ],
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 18),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Assigned Jobs', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
                ElevatedButton.icon(
                  onPressed: () => _showAssignBookingDialog(context, ref, t),
                  icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                  label: const Text('Dispatch New Job', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: const Size(60, 30),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (t.jobs.isEmpty)
              const Text('No active jobs currently assigned.', style: TextStyle(color: AppColors.textMuted, fontSize: 12))
            else
              ...t.jobs.map((job) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEEF2F6)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Iconsax.car, size: 16, color: AppColors.textSecondary),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job.vehicleType, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 12)),
                                Text('${job.regNo} • ${job.date}', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: job.status.toLowerCase().contains('progress')
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              job.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: job.status.toLowerCase().contains('progress')
                                    ? AppColors.brandGreen
                                    : const Color(0xFF16A34A),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
