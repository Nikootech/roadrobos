import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../core/theme/app_colors.dart';

// --- MOCK DATA ---
class AdminTechnician {
  final String id;
  final String uid;
  final String name;
  final String joinDate;
  final int booked;
  final int undergoing;
  final int completed;
  final List<TechJob> jobs;

  AdminTechnician(this.id, this.uid, this.name, this.joinDate, this.booked, this.undergoing, this.completed, this.jobs);
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
    final id = realId.length > 4 ? realId.substring(0, 4).toUpperCase() : 'NEW';
    final name = map['name'] ?? 'Expert Technician';
    final createdAt = map['created_at'] != null 
        ? DateTime.parse(map['created_at']) 
        : DateTime.now();
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[createdAt.month - 1]} ${createdAt.year}';

    return AdminTechnician(
      id,
      realId,
      name,
      dateStr,
      map['booked_jobs'] ?? 0,
      map['ongoing_jobs'] ?? 0,
      map['completed_jobs'] ?? 0,
      [], // Jobs could be fetched separately
    );
  }).toList();
});

final techSearchProvider = StateProvider<String>((ref) => '');

// --- SCREEN ---
class TechnicianDatabaseScreen extends ConsumerWidget {
  const TechnicianDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(techSearchProvider);
    final techsAsync = ref.watch(adminTechProvider);

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
          'Technician Database',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                onChanged: (val) => ref.read(techSearchProvider.notifier).state = val,
                decoration: const InputDecoration(
                  icon: Icon(Iconsax.search_normal, size: 20, color: AppColors.textSecondary),
                  hintText: 'Search by technician name or ID...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          
          Expanded(
            child: techsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
              error: (err, stack) => const Center(child: Text('Error loading data')),
              data: (techs) {
                final filtered = techs.where((t) => t.name.toLowerCase().contains(search.toLowerCase()) || t.id.toLowerCase().contains(search.toLowerCase())).toList();
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildTechCard(context, ref, filtered[index]).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignBookingDialog(BuildContext context, WidgetRef ref, AdminTechnician technician) async {
    final repo = ref.read(adminOpsRepositoryProvider);
    
    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
    ));

    List<Map<String, dynamic>> unassignedBookings = [];
    try {
      unassignedBookings = await repo.getUnassignedServiceBookings();
      if (context.mounted) Navigator.pop(context); // Pop loading
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading bookings: $e')));
      }
      return;
    }

    if (unassignedBookings.isEmpty) {
      if (context.mounted) {
        unawaited(showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('No Unassigned Bookings'),
            content: const Text('All service bookings are currently assigned to technicians.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
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
          title: Text('Assign to ${technician.name}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: unassignedBookings.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final booking = unassignedBookings[index];
                final bookingId = booking['id'].toString();
                final packageName = booking['package_name'] ?? 'General Service';
                final vehicle = booking['vehicle_name'] ?? 'Vehicle';
                final date = booking['booking_date'] ?? 'Today';
                final cost = booking['total_cost'] ?? '0';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(packageName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('$vehicle • $date\nID: #${bookingId.substring(0, 8).toUpperCase()}', style: const TextStyle(fontSize: 12)),
                  trailing: Text('₹$cost', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontSize: 14)),
                  onTap: () async {
                    Navigator.pop(context); // Close list dialog
                    unawaited(showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                    ));

                    try {
                      await repo.assignTechnicianToBooking(bookingId, technician.uid);
                      if (context.mounted) {
                        Navigator.pop(context); // Pop progress
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Technician assigned successfully!')));
                        ref.invalidate(adminTechProvider);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // Pop progress
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Assignment failed: $e')));
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
              child: const Text('Cancel'),
            ),
          ],
        ),
      ));
    }
  }

  Widget _buildTechCard(BuildContext context, WidgetRef ref, AdminTechnician t) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          iconColor: AppColors.primaryBlue,
          collapsedIconColor: AppColors.textSecondary,
          title: Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1), child: const Text('🔧', style: TextStyle(fontSize: 18))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${t.name} (${t.id})', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Joined: ${t.joinDate}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBadge('📅', '${t.booked} Booked', AppColors.warningAmber),
                _buildBadge('⚙️', '${t.undergoing} In Progress', AppColors.primaryBlue),
                _buildBadge('✅', '${t.completed} Completed', AppColors.successGreen),
              ],
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Assigned Services', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ElevatedButton.icon(
                  onPressed: () => _showAssignBookingDialog(context, ref, t),
                  icon: const Icon(Icons.add_rounded, size: 14, color: Colors.white),
                  label: const Text('Assign Booking', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: const Size(60, 28),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (t.jobs.isEmpty)
              const Text('No jobs assigned.', style: TextStyle(color: AppColors.textMuted))
            else
              ...t.jobs.map((job) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle), child: const Icon(Iconsax.car, color: AppColors.textSecondary, size: 16)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${job.regNo} - ${job.vehicleType}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
                          Text('Status: ${job.status} • ${job.date}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    if (job.status == 'Completed') ...[
                       const SizedBox(width: 8),
                       IconButton(
                         icon: const Icon(Icons.receipt_long_rounded, color: AppColors.successGreen, size: 20),
                         onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading Invoice for ₹${job.invoice.toInt()}...')));
                         },
                         tooltip: 'Download Invoice',
                       ),
                       IconButton(
                         icon: const Icon(Icons.analytics_rounded, color: AppColors.primaryBlue, size: 20),
                         onPressed: () {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Viewing Detailed Service Report...')));
                         },
                         tooltip: 'View Report',
                       )
                    ] else
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: job.status == 'In Progress' ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.warningAmber.withValues(alpha: 0.1), borderRadius: const BorderRadius.all(Radius.circular(6))),
                        child: Text(job.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: job.status == 'In Progress' ? AppColors.primaryBlue : AppColors.warningAmber)),
                      )
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.1))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
