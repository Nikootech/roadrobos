import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/admin_bottom_nav_bar.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/sos_button.dart';

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
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Center(
          child: ScaleOnTap(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF0F172A)),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'Service Dispatch Console',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Real-Time Technician Allocation',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDCFCE7)),
              ),
              child: const Icon(Iconsax.refresh,
                  color: Color(0xFF006241), size: 16),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(serviceBookingsDispatchStreamProvider);
            },
          ),
          const SizedBox(width: 4),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: SOSButton.headerPill(
              rideDetails: 'Service Dispatch Console',
            ),
          ),
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
              // ── TOP METRICS & CATEGORY SELECTOR ───────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildStatChip(
                          'Unassigned Queue',
                          unassigned.length.toString(),
                          const Color(0xFFE11D48),
                          const Color(0xFFFFF1F2),
                          const Color(0xFFFECDD3),
                          Iconsax.clock,
                        ),
                        const SizedBox(width: 10),
                        _buildStatChip(
                          'In Field Jobs',
                          inField.length.toString(),
                          const Color(0xFF0284C7),
                          const Color(0xFFF0F9FF),
                          const Color(0xFFBAE6FD),
                          Iconsax.routing,
                        ),
                        const SizedBox(width: 10),
                        _buildStatChip(
                          'Completed',
                          completed.length.toString(),
                          const Color(0xFF006241),
                          const Color(0xFFF0FDF4),
                          const Color(0xFFBBF7D0),
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
                          IconData catIcon = Iconsax.category;
                          if (cat == 'EV') catIcon = Iconsax.flash_1;
                          if (cat == 'BIKE') catIcon = Iconsax.driving;
                          if (cat == 'CAR') catIcon = Iconsax.car;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ScaleOnTap(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedCategory = cat);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF006241),
                                            Color(0xFF10B981)
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF006241)
                                        : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      catIcon,
                                      size: 13,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      cat == 'ALL'
                                          ? 'All Services'
                                          : '$cat Maintenance',
                                      style: GoogleFonts.inter(
                                        fontSize: 11.5,
                                        fontWeight: isSelected
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // ── SEGMENTED QUEUE TABS ─────────────────────────────────────
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      _buildQueueTab(
                          0, 'Unassigned (${unassigned.length})'),
                      _buildQueueTab(
                          1, 'In Field (${inField.length})'),
                      _buildQueueTab(
                          2, 'Completed (${completed.length})'),
                    ],
                  ),
                ),
              ),

              // ── TAB VIEWS ────────────────────────────────────────────────
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
          child: CircularProgressIndicator(color: Color(0xFF006241)),
        ),
        error: (err, _) => Center(
          child: Text('Error loading service bookings: $err'),
        ),
      ),
    );
  }

  Widget _buildQueueTab(int index, String label) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          _tabController.animateTo(index);
          setState(() {});
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF006241)
                    : const Color(0xFF64748B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String title, String value, Color textColor,
      Color bgColor, Color borderColor, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: textColor),
                const SizedBox(width: 5),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: const Color(0xFF64748B),
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
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Iconsax.task,
                  size: 28, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            Text(
              'No service bookings in this queue',
              style: GoogleFonts.outfit(
                color: const Color(0xFF334155),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final b = filtered[index];
        final packageName = b['package_name'] ?? 'Full Service';
        final vehicleName = b['vehicle_name'] ?? 'Vehicle';
        final vehiclePlate = b['vehicle_plate'] ?? 'N/A';
        final address = b['address'] ?? 'Customer Location';
        final date = b['date'] ?? 'Today';
        final time = b['time'] ?? 'ASAP';
        final totalCost = b['total_cost']?.toString() ?? '4500';
        final status = b['status']?.toString().toUpperCase() ?? 'PENDING';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF006241), Color(0xFF10B981)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Iconsax.setting_2,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          packageName,
                          style: GoogleFonts.outfit(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '$vehicleName · $vehiclePlate',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildBookingStatusBadge(status, isUnassigned),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF1F5F9), height: 1),
              const SizedBox(height: 10),

              // Location & Slot
              Row(
                children: [
                  const Icon(Iconsax.location,
                      size: 14, color: Color(0xFF006241)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Iconsax.calendar_1,
                      size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    '$date at $time',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹$totalCost',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),

              if (isUnassigned) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ScaleOnTap(
                        onTap: () => _autoDispatchTechnician(b),
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: const Color(0xFF006241), width: 1.2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.flash_1,
                                  size: 16, color: Color(0xFF006241)),
                              const SizedBox(width: 6),
                              Text(
                                'Auto-Dispatch',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF006241),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ScaleOnTap(
                        onTap: () => _showManualAssignSheet(b),
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF006241), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF006241)
                                    .withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.user_add,
                                  size: 16, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                'Manual Assign',
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ).animate().fadeIn(duration: 250.ms);
      },
    );
  }

  Widget _buildBookingStatusBadge(String status, bool isUnassigned) {
    Color bg = const Color(0xFFF0FDF4);
    Color fg = const Color(0xFF006241);
    Color dot = const Color(0xFF10B981);

    if (status == 'COMPLETED') {
      bg = const Color(0xFFF0FDF4);
      fg = const Color(0xFF006241);
      dot = const Color(0xFF10B981);
    } else if (isUnassigned || status == 'PENDING') {
      bg = const Color(0xFFFFF1F2);
      fg = const Color(0xFFE11D48);
      dot = const Color(0xFFF43F5E);
    } else {
      bg = const Color(0xFFF0F9FF);
      fg = const Color(0xFF0284C7);
      dot = const Color(0xFF38BDF8);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  void _autoDispatchTechnician(Map<String, dynamic> booking) async {
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF006241))),
    ));

    try {
      final supabase = Supabase.instance.client;
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
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ Auto-dispatched to ${assignedTech['full_name'] ?? 'Technician'}!',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFF006241),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No online technicians available in this zone.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              backgroundColor: const Color(0xFFD97706),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to auto-dispatch: $e',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            backgroundColor: const Color(0xFFE11D48),
            behavior: SnackBarBehavior.floating,
          ),
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
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Field Technician',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'Assigning for ${booking['package_name'] ?? 'Service'}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
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
                            color: Color(0xFF006241)));
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return Center(
                      child: Text('No registered technicians found.',
                          style: GoogleFonts.inter(
                              color: const Color(0xFF64748B))),
                    );
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final tech = list[index];
                      final name =
                          tech['full_name'] ?? 'Technician #${index + 1}';
                      final rating = tech['rating']?.toString() ?? '4.8';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF006241),
                                    Color(0xFF10B981)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Icon(Iconsax.user,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded,
                                          color: Color(0xFFF59E0B), size: 14),
                                      const SizedBox(width: 3),
                                      Text(rating,
                                          style: GoogleFonts.inter(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(width: 6),
                                      Text('· Available Now',
                                          style: GoogleFonts.inter(
                                              color: const Color(0xFF006241),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ScaleOnTap(
                              onTap: () async {
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
                                      content: Text(
                                          '✅ Assigned to $name successfully!',
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600)),
                                      backgroundColor: const Color(0xFF006241),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } catch (e) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e',
                                          style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600)),
                                      backgroundColor: const Color(0xFFE11D48),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF006241),
                                      Color(0xFF10B981)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Assign',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
