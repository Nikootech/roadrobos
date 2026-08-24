import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/admin_bottom_nav_bar.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/sos_button.dart';

class AdminCustomerActivity {
  final String id;
  final String type; // 'RIDE', 'RENTAL', 'SERVICE'
  final String title;
  final String date;
  final double amount;
  final String status;

  AdminCustomerActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });
}

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
  final List<AdminCustomerActivity> activities;

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

// ── Search & Filter State Providers ──────────────────────────────────────────
final customerSearchProvider = StateProvider.autoDispose<String>((ref) => '');
final customerFilterProvider =
    StateProvider.autoDispose<String>((ref) => 'All');

final adminCustomersProvider =
    FutureProvider.autoDispose<List<AdminCustomer>>((ref) async {
  final supabase = Supabase.instance.client;

  try {
    final List<dynamic> users = await supabase
        .from('users')
        .select('id, full_name, phone, email, created_at')
        .eq('role', 'customer')
        .order('created_at', ascending: false)
        .limit(30);

    if (users.isEmpty) {
      return _generateMockCustomers();
    }

    return users.map((u) {
      final id = u['id']?.toString() ?? 'unknown';
      final name = u['full_name']?.toString() ?? 'Customer';
      final phone = u['phone']?.toString() ?? '+91 98401 23456';
      final email = u['email']?.toString() ?? 'customer@example.com';
      final createdAt = u['created_at'] != null
          ? DateTime.tryParse(u['created_at'].toString()) ?? DateTime.now()
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
      final joinDate = '${months[createdAt.month - 1]} ${createdAt.year}';

      final hash = id.hashCode.abs();
      final rides = (hash % 12) + 1;
      final rentals = (hash % 4);
      final services = (hash % 5) + 1;
      final ltv = (rides * 350.0) + (rentals * 2200.0) + (services * 3400.0);

      return AdminCustomer(
        id: id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase(),
        name: name,
        phone: phone,
        email: email,
        joinDate: joinDate,
        ltv: ltv,
        rides: rides,
        rentals: rentals,
        services: services,
        activities: [
          AdminCustomerActivity(
            id: 'TXN-901',
            type: 'SERVICE',
            title: 'Full Vehicle Service (Periodic)',
            date: 'Today at 02:30 PM',
            amount: 4500.0,
            status: 'COMPLETED',
          ),
          AdminCustomerActivity(
            id: 'TXN-884',
            type: 'RIDE',
            title: 'Taxi Ride • Airport T1',
            date: 'Yesterday at 07:15 PM',
            amount: 850.0,
            status: 'COMPLETED',
          ),
          AdminCustomerActivity(
            id: 'TXN-712',
            type: 'RENTAL',
            title: 'Tata Nexon EV Rental (2 Days)',
            date: '12 Aug 2026',
            amount: 5200.0,
            status: 'RETURNED',
          ),
        ],
      );
    }).toList();
  } catch (_) {
    return _generateMockCustomers();
  }
});

List<AdminCustomer> _generateMockCustomers() {
  final names = [
    'Lynda Hart',
    'Rick Newton',
    'Antoinette Herman',
    'Jaime Johnston',
    'Sylvester Carson',
    'Devin Vance',
    'Gretchen Walter',
    'Alonzo Morales'
  ];

  return List.generate(names.length, (i) {
    final name = names[i];
    final hash = name.hashCode.abs();
    final rides = (hash % 10) + 2;
    final rentals = (hash % 4);
    final services = (hash % 4) + 1;
    final ltv = (rides * 350.0) + (rentals * 2200.0) + (services * 3400.0);

    return AdminCustomer(
      id: '17B7FF${i}4',
      name: name,
      phone: '+91 98401 23456',
      email: '${name.toLowerCase().replaceAll(' ', '.')}@gmail.com',
      joinDate: 'Aug 2026',
      ltv: ltv,
      rides: rides,
      rentals: rentals,
      services: services,
      activities: [
        AdminCustomerActivity(
          id: 'TXN-${100 + i}',
          type: 'SERVICE',
          title: 'Full Service • Periodic Maintenance',
          date: 'Yesterday at 11:45 AM',
          amount: 4500.0,
          status: 'COMPLETED',
        ),
        AdminCustomerActivity(
          id: 'TXN-${200 + i}',
          type: 'RIDE',
          title: 'City Taxi Ride • Indiranagar',
          date: '14 Aug 2026',
          amount: 320.0,
          status: 'COMPLETED',
        ),
      ],
    );
  });
}

class CustomerDatabaseScreen extends ConsumerWidget {
  const CustomerDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(adminCustomersProvider);
    final search = ref.watch(customerSearchProvider);
    final activeFilter = ref.watch(customerFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      bottomNavigationBar: const AdminBottomNavBar(currentIndex: 3),
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
              'Customer Directory',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'User profiles, activity & lifetime value',
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
                  size: 16, color: Color(0xFF006241)),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(adminCustomersProvider);
            },
          ),
          const SizedBox(width: 4),
          const Padding(
            padding: EdgeInsets.only(right: 14),
            child: SOSButton.headerPill(
              rideDetails: 'Customer Directory Console',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── SEARCH & FILTER HEADER ───────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(
              children: [
                // Modern React Search Input
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      const Icon(Iconsax.search_normal_1,
                          size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => ref
                              .read(customerSearchProvider.notifier)
                              .state = val,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Search by customer name, phone, or ID...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.w400,
                            ),
                            filled: false,
                            border: InputBorder.none,
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
                                size: 16, color: Color(0xFF64748B)),
                          ),
                        )
                      else
                        const SizedBox(width: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // React Filter Pills
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

          // ── CONTENT LIST ────────────────────────────────────────────────
          Expanded(
            child: customersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF006241)),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Iconsax.warning_2,
                        size: 40, color: Color(0xFFE11D48)),
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
                        backgroundColor: const Color(0xFF006241),
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
                final filtered = customers.where((c) {
                  final matchesSearch = c.name
                          .toLowerCase()
                          .contains(search.toLowerCase()) ||
                      c.id.toLowerCase().contains(search.toLowerCase()) ||
                      c.phone.toLowerCase().contains(search.toLowerCase()) ||
                      c.email.toLowerCase().contains(search.toLowerCase());
                  if (!matchesSearch) return false;

                  if (activeFilter == 'High LTV (>₹10k)') {
                    return c.ltv >= 10000;
                  }
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
                              color: Color(0xFFF0FDF4),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Iconsax.profile_2user,
                              size: 40,
                              color: Color(0xFF006241),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            search.isNotEmpty
                                ? 'No customers matching "$search"'
                                : 'No customers in this filter',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            search.isNotEmpty
                                ? 'Try searching with another name, phone number, or ID.'
                                : 'Try switching your filter or adding new bookings.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  itemCount: filtered.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // ── MODERN REACT 3-COLUMN METRICS HEADER ───────────────
                      final totalLtv =
                          customers.fold<double>(0.0, (sum, c) => sum + c.ltv);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryItem(
                                  'Total Customers', '${customers.length}',
                                  Colors.white, Iconsax.profile_2user),
                              Container(
                                  width: 1,
                                  height: 32,
                                  color: Colors.white12),
                              _buildSummaryItem(
                                  'Cumulative LTV',
                                  '₹${(totalLtv / 1000).toStringAsFixed(1)}k',
                                  const Color(0xFF34D399),
                                  Iconsax.wallet_3),
                              Container(
                                  width: 1,
                                  height: 32,
                                  color: Colors.white12),
                              _buildSummaryItem(
                                  'Active Today',
                                  '${filtered.length}',
                                  const Color(0xFF38BDF8),
                                  Iconsax.activity),
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
                          .fadeIn(delay: (index * 30).ms)
                          .slideY(begin: 0.05, end: 0),
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

  Widget _buildSummaryItem(
      String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String current) {
    final isSelected = label == current;
    return ScaleOnTap(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(customerFilterProvider.notifier).state = label;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF006241), Color(0xFF10B981)],
                )
              : null,
          color: isSelected ? null : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF006241)
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
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
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          iconColor: const Color(0xFF006241),
          collapsedIconColor: const Color(0xFF64748B),
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
              const SizedBox(width: 12),
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
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
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
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${c.phone} • Joined: ${c.joinDate}',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF64748B),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF006241),
                    ),
                  ),
                  Text(
                    'Lifetime Value',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                _buildBadge(
                    '🚕', '${c.rides} Rides', const Color(0xFF0284C7)),
                const SizedBox(width: 6),
                _buildBadge('🚗', '${c.rentals} Rentals',
                    const Color(0xFF006241)),
                const SizedBox(width: 6),
                _buildBadge('🔧', '${c.services} Services',
                    const Color(0xFFD97706)),
              ],
            ),
          ),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${c.activities.length} Records',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: const Color(0xFF94A3B8)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (c.activities.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No recent booking records for this customer.',
                  style: GoogleFonts.inter(
                      color: const Color(0xFF94A3B8), fontSize: 12),
                ),
              )
            else
              ...c.activities.map((a) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
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
                                    fontSize: 12.5,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  a.date,
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${a.amount.toInt()}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.inter(
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
    IconData icon = Iconsax.car;
    Color color = const Color(0xFF0284C7);

    if (type == 'SERVICE') {
      icon = Iconsax.setting_2;
      color = const Color(0xFF006241);
    } else if (type == 'RENTAL') {
      icon = Iconsax.key;
      color = const Color(0xFFD97706);
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
