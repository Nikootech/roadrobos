import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/repositories/admin_ops_repository.dart';
import 'widgets/admin_bottom_nav_bar.dart';

// --- CUSTOMER MODEL ---
class AdminCustomer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String joinDate;
  final double ltv;
  final int rides;
  final int rentals;
  final int services;
  final List<CustomerActivity> activities;

  AdminCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.joinDate,
    required this.ltv,
    required this.rides,
    required this.rentals,
    required this.services,
    required this.activities,
  });
}

class CustomerActivity {
  final String type; // 'Ride', 'Rental', 'Service'
  final String title;
  final String status;
  final String date;

  CustomerActivity({
    required this.type,
    required this.title,
    required this.status,
    required this.date,
  });
}

final adminCustomersProvider =
    StreamProvider<List<AdminCustomer>>((ref) async* {
  final repo = ref.read(adminOpsRepositoryProvider);
  final customers = await repo.getAllCustomers();

  yield customers.map((map) {
    final rawId = map['id']?.toString() ?? '';
    final id = rawId.length > 8
        ? rawId.substring(0, 8).toUpperCase()
        : (rawId.isNotEmpty ? rawId.toUpperCase() : 'CUST-NEW');
    final name = map['name'] ?? map['full_name'] ?? 'RoadRobos Customer';
    final phone = map['phone'] ?? '+91 98765 43210';
    final email = map['email'] ?? 'customer@roadrobos.com';
    final createdAt = map['created_at'] != null
        ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
        : DateTime.now();

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final dateStr = '${months[createdAt.month - 1]} ${createdAt.year}';

    final recentBookings = (map['recent_bookings'] as List?) ?? [];
    final activities = recentBookings.map((b) {
      return CustomerActivity(
        type: b['type'] ?? 'Service',
        title: b['title'] ??
            b['package_name'] ??
            b['vehicle_name'] ??
            'Periodic Service',
        status: b['status'] ?? 'Completed',
        date: b['date'] ?? b['booking_date'] ?? 'Recently',
      );
    }).toList();

    return AdminCustomer(
      id: id,
      name: name,
      phone: phone,
      email: email,
      joinDate: dateStr,
      ltv: (map['ltv'] as num?)?.toDouble() ?? 4200.0,
      rides: (map['total_rides'] as int?) ?? 0,
      rentals: (map['total_rentals'] as int?) ?? 0,
      services: (map['total_services'] as int?) ??
          (activities.isNotEmpty ? activities.length : 1),
      activities: activities,
    );
  }).toList();
});

final customerSearchProvider = StateProvider<String>((ref) => '');
final customerFilterProvider = StateProvider<String>((ref) => 'All');

// --- SCREEN ---
class CustomerDatabaseScreen extends ConsumerWidget {
  const CustomerDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final search = ref.watch(customerSearchProvider);
    final activeFilter = ref.watch(customerFilterProvider);
    final customersAsync = ref.watch(adminCustomersProvider);

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
              'Customer Directory',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'User profiles, activity & lifetime value',
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
              ref.invalidate(adminCustomersProvider);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header Container
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
                          onChanged: (val) => ref
                              .read(customerSearchProvider.notifier)
                              .state = val,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search by customer name, phone, or ID...',
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
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (search.isNotEmpty)
                        GestureDetector(
                          onTap: () => ref
                              .read(customerSearchProvider.notifier)
                              .state = '',
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
                      _buildFilterChip(ref, 'High LTV (>₹10k)', activeFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(ref, 'Frequent Riders', activeFilter),
                      const SizedBox(width: 8),
                      _buildFilterChip(ref, 'Service Users', activeFilter),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content List / Empty State
          Expanded(
            child: customersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.brandGreen),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.warning_2,
                        size: 40, color: AppColors.dangerRed),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load customer database',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => ref.invalidate(adminCustomersProvider),
                      child: const Text('Try Again',
                          style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
              data: (customers) {
                // Apply Search & Filter
                final filtered = customers.where((c) {
                  final matchesSearch = c.name
                          .toLowerCase()
                          .contains(search.toLowerCase()) ||
                      c.id.toLowerCase().contains(search.toLowerCase()) ||
                      c.phone.toLowerCase().contains(search.toLowerCase()) ||
                      c.email.toLowerCase().contains(search.toLowerCase());
                  if (!matchesSearch) return false;

                  if (activeFilter == 'High LTV (>₹10k)') return c.ltv >= 10000;
                  if (activeFilter == 'Frequent Riders') return c.rides >= 5;
                  if (activeFilter == 'Service Users') return c.services >= 1;
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
                              color: AppColors.brandGreenBg,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.profile_2user,
                              size: 48,
                              color: AppColors.brandGreen,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            search.isNotEmpty
                                ? 'No customers matching "$search"'
                                : 'No customers in this filter',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            search.isNotEmpty
                                ? 'Try searching with another name, phone number, or ID.'
                                : 'Try switching your filter or adding new bookings.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          OutlinedButton.icon(
                            onPressed: () {
                              ref.read(customerSearchProvider.notifier).state =
                                  '';
                              ref.read(customerFilterProvider.notifier).state =
                                  'All';
                            },
                            icon:
                                const Icon(Icons.restart_alt_rounded, size: 16),
                            label: const Text('Reset Search & Filters'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.brandGreen,
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
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
                      // Summary Header Widget
                      final totalLtv =
                          customers.fold<double>(0.0, (sum, c) => sum + c.ltv);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem('Total Customers',
                                  '${customers.length}', Colors.white),
                              Container(
                                  width: 1, height: 28, color: Colors.white24),
                              _buildSummaryItem(
                                  'Cumulative LTV',
                                  '₹${(totalLtv / 1000).toStringAsFixed(1)}k',
                                  const Color(0xFF34D399)),
                              Container(
                                  width: 1, height: 28, color: Colors.white24),
                              _buildSummaryItem(
                                  'Active Today',
                                  '${filtered.length}',
                                  const Color(0xFF38BDF8)),
                            ],
                          ),
                        ),
                      );
                    }

                    final customer = filtered[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildCustomerCard(context, customer)
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
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String current) {
    final isSelected = label == current;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(customerFilterProvider.notifier).state = label;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandGreen : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandGreen : const Color(0xFFE2E8F0),
          ),
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

  Widget _buildCustomerCard(BuildContext context, AdminCustomer c) {
    final initials = c.name.trim().isNotEmpty
        ? c.name
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'C';

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
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0284C7), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
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
                            c.name,
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${c.id}',
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${c.phone} • Joined: ${c.joinDate}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${c.ltv.toInt()}',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandGreen,
                    ),
                  ),
                  Text(
                    'Lifetime Value',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                _buildBadge('🚕', '${c.rides} Rides', const Color(0xFF0284C7)),
                const SizedBox(width: 6),
                _buildBadge('🚗', '${c.rentals} Rentals', AppColors.brandGreen),
                const SizedBox(width: 6),
                _buildBadge(
                    '🔧', '${c.services} Services', const Color(0xFFD97706)),
              ],
            ),
          ),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 18),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Color(0xFFF1F5F9)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Booking Activity',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${c.activities.length} Records',
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (c.activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No recent booking records for this customer.',
                  style: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.8),
                      fontSize: 12),
                ),
              )
            else
              ...c.activities.map((a) => Padding(
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
                          _getTypeIcon(a.type),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.title,
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  a.date,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getStatusBg(a.status),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              a.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _getStatusText(a.status),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )),
            const SizedBox(height: 12),
            // Customer Actions Row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text('Contacting ${c.name} via ${c.phone}...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Iconsax.call, size: 14),
                    label: const Text('Call / SMS',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brandGreen,
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push('/admin-active-rides');
                    },
                    icon: const Icon(Iconsax.routing,
                        size: 14, color: Colors.white),
                    label: const Text('Live Track',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTypeIcon(String type) {
    IconData icon;
    Color color;
    switch (type.toLowerCase()) {
      case 'ride':
        icon = Iconsax.routing_2;
        color = const Color(0xFF0284C7);
        break;
      case 'rental':
        icon = Iconsax.car;
        color = AppColors.brandGreen;
        break;
      case 'service':
      default:
        icon = Iconsax.setting_2;
        color = const Color(0xFFD97706);
    }
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 14),
    );
  }

  Color _getStatusBg(String status) {
    final s = status.toLowerCase();
    if (s.contains('ongoing') ||
        s.contains('progress') ||
        s.contains('active')) {
      return const Color(0xFFECFDF5);
    }
    if (s.contains('completed') || s.contains('done')) {
      return const Color(0xFFF0FDF4);
    }
    return const Color(0xFFF1F5F9);
  }

  Color _getStatusText(String status) {
    final s = status.toLowerCase();
    if (s.contains('ongoing') ||
        s.contains('progress') ||
        s.contains('active')) {
      return AppColors.brandGreen;
    }
    if (s.contains('completed') || s.contains('done')) {
      return const Color(0xFF16A34A);
    }
    return AppColors.textSecondary;
  }
}
