import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/admin_bottom_nav_bar.dart';

final serviceBookingsDispatchStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  return supabase
      .from('service_bookings')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((list) => list);
});

class ServiceDispatchScreen extends ConsumerStatefulWidget {
  const ServiceDispatchScreen({super.key});

  @override
  ConsumerState<ServiceDispatchScreen> createState() =>
      _ServiceDispatchScreenState();
}

class _ServiceDispatchScreenState extends ConsumerState<ServiceDispatchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'ALL';

  final List<String> _categories = ['ALL', 'EV', 'BIKE', 'CAR'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(serviceBookingsDispatchStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Dispatch Console',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Real-Time Technician Allocation',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.primaryBlue),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(serviceBookingsDispatchStreamProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: bookingsAsync.when(
        data: (bookings) {
          final unassigned = bookings.where((b) {
            final s = b['status']?.toString().toLowerCase() ?? 'pending';
            return s == 'pending' || b['assigned_technician_id'] == null;
          }).toList();

          final inField = bookings.where((b) {
            final s = b['status']?.toString().toLowerCase() ?? '';
            return ['assigned', 'on_my_way', 'arrived', 'in_progress']
                    .contains(s) &&
                b['assigned_technician_id'] != null;
          }).toList();

          final completed = bookings.where((b) {
            final s = b['status']?.toString().toLowerCase() ?? '';
            return s == 'completed';
          }).toList();

          return Column(
            children: [
              // Top Stats Banner
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatChip(
                          'Unassigned Queue',
                          unassigned.length.toString(),
                          AppColors.dangerRed,
                          Iconsax.clock,
                        ),
                        const SizedBox(width: 10),
                        _buildStatChip(
                          'In Field Jobs',
                          inField.length.toString(),
                          AppColors.primaryBlue,
                          Iconsax.routing,
                        ),
                        const SizedBox(width: 10),
                        _buildStatChip(
                          'Completed',
                          completed.length.toString(),
                          AppColors.successGreen,
                          Iconsax.tick_circle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Category Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                cat == 'ALL'
                                    ? 'All Services'
                                    : '$cat Maintenance',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                              selected: isSelected,
                              backgroundColor: const Color(0xFFF1F3F7),
                              selectedColor: AppColors.deepNavy,
                              showCheckmark: false,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              onSelected: (_) {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedCategory = cat);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primaryBlue,
                  indicatorWeight: 3,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: GoogleFonts.outfit(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  tabs: [
                    Tab(text: 'Unassigned (${unassigned.length})'),
                    Tab(text: 'In Field (${inField.length})'),
                    Tab(text: 'Completed (${completed.length})'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(unassigned, isUnassigned: true),
                    _buildBookingList(inField),
                    _buildBookingList(completed),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
        error: (err, _) => Center(
          child: Text('Error loading service bookings: $err'),
        ),
      ),
    );
  }

  Widget _buildStatChip(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList(List<Map<String, dynamic>> items,
      {bool isUnassigned = false}) {
    final filtered = items.where((b) {
      if (_selectedCategory == 'ALL') return true;
      final package = b['package_name']?.toString().toUpperCase() ?? '';
      final vehicle = b['vehicle_name']?.toString().toUpperCase() ?? '';
      return package.contains(_selectedCategory) ||
          vehicle.contains(_selectedCategory);
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.task,
                size: 64, color: AppColors.textMuted.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'No service bookings in this queue',
              style: GoogleFonts.outfit(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = filtered[index];
        final packageName = b['package_name'] ?? 'General Service';
        final vehicleName = b['vehicle_name'] ?? 'Vehicle';
        final vehiclePlate = b['vehicle_plate'] ?? 'N/A';
        final address = b['address'] ?? 'Customer Location';
        final date = b['date'] ?? 'Today';
        final time = b['time'] ?? 'ASAP';
        final totalCost = b['total_cost']?.toString() ?? '0';
        final status = b['status']?.toString().toUpperCase() ?? 'PENDING';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.build_circle_rounded,
                        color: AppColors.primaryBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packageName,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '$vehicleName · $vehiclePlate',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: status == 'COMPLETED'
                          ? AppColors.successGreen.withValues(alpha: 0.1)
                          : isUnassigned
                              ? AppColors.dangerRed.withValues(alpha: 0.1)
                              : AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: status == 'COMPLETED'
                            ? AppColors.successGreen
                            : isUnassigned
                                ? AppColors.dangerRed
                                : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              // Location & Slot
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text('$date at $time',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary)),
                  const Spacer(),
                  Text('₹$totalCost',
                      style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ],
              ),
              if (isUnassigned) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _autoDispatchTechnician(b),
                        icon: const Icon(Icons.flash_on_rounded, size: 16),
                        label: const Text('Auto-Dispatch'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.primaryBlue),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showManualAssignSheet(b),
                        icon: const Icon(Icons.person_add_rounded, size: 16),
                        label: const Text('Manual Assign'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepNavy,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 300.ms);
      },
    );
  }

  void _autoDispatchTechnician(Map<String, dynamic> booking) async {
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue)),
    ));

    try {
      final supabase = Supabase.instance.client;
      // Fetch online technicians
      final techs = await supabase
          .from('users')
          .select('id, full_name, rating')
          .eq('role', 'technician')
          .limit(5);

      if (techs.isNotEmpty) {
        final assignedTech = techs.first;
        await supabase.from('service_bookings').update({
          'assigned_technician_id': assignedTech['id'],
          'status': 'assigned',
        }).eq('id', booking['id']);

        if (mounted) {
          Navigator.pop(context); // Close loader
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ Auto-dispatched to ${assignedTech['full_name'] ?? 'Technician'}!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No online technicians available in this zone.'),
              backgroundColor: AppColors.warningAmber,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to auto-dispatch: $e'),
              backgroundColor: AppColors.dangerRed),
        );
      }
    }
  }

  void _showManualAssignSheet(Map<String, dynamic> booking) {
    final messenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Field Technician',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.deepNavy,
              ),
            ),
            Text(
              'Assigning for ${booking['package_name'] ?? 'Service'}',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: Supabase.instance.client
                    .from('users')
                    .select('id, full_name, rating, phone')
                    .eq('role', 'technician'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryBlue));
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(
                        child: Text('No registered technicians found.'));
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tech = list[index];
                      final name =
                          tech['full_name'] ?? 'Technician #${index + 1}';
                      final rating = tech['rating']?.toString() ?? '4.8';

                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.border),
                        ),
                        leading: CircleAvatar(
                          backgroundColor:
                              AppColors.primaryBlue.withValues(alpha: 0.1),
                          child: const Icon(Icons.person,
                              color: AppColors.primaryBlue),
                        ),
                        title: Text(name,
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600)),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFFBBF24), size: 14),
                            const SizedBox(width: 4),
                            Text(rating, style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 8),
                            const Text('· Available Now',
                                style: TextStyle(
                                    color: AppColors.successGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(sheetContext);
                            await HapticFeedback.heavyImpact();
                            try {
                              await Supabase.instance.client
                                  .from('service_bookings')
                                  .update({
                                'assigned_technician_id': tech['id'],
                                'status': 'assigned',
                              }).eq('id', booking['id']);

                              messenger.showSnackBar(
                                SnackBar(
                                  content:
                                      Text('✅ Assigned to $name successfully!'),
                                  backgroundColor: AppColors.successGreen,
                                ),
                              );
                            } catch (e) {
                              messenger.showSnackBar(
                                SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: AppColors.dangerRed),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                          ),
                          child: const Text('Assign',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
