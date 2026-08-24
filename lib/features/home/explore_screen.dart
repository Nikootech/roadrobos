import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/vehicle_provider.dart';
import 'home_providers.dart';
import '../../core/utils/icon_helper.dart';
import '../../shared/widgets/kinetic_motion.dart';
import '../../shared/widgets/sos_button.dart';

/// Explore/Search Screen - World-Class React Tier-1 Service Catalog
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeFilterTab = 'All';

  // React Category Filter Definitions with native vector icons
  static const List<_FilterTabItem> _filterTabs = [
    _FilterTabItem(key: 'All', label: 'All Services', icon: Iconsax.category),
    _FilterTabItem(key: 'Rentals', label: 'Rentals', icon: Iconsax.car),
    _FilterTabItem(key: 'EV Service', label: 'EV Care', icon: Iconsax.flash_1),
    _FilterTabItem(
        key: 'Water Service', label: 'Detailing', icon: Iconsax.drop),
    _FilterTabItem(key: 'Repair', label: 'Repair', icon: Iconsax.setting_2),
    _FilterTabItem(key: 'Logistics', label: 'Cargo', icon: Iconsax.box),
    _FilterTabItem(
        key: 'Oil & Fluids', label: 'Oil & Lube', icon: Iconsax.gas_station),
    _FilterTabItem(
        key: 'AC & Climate', label: 'AC Climate', icon: Iconsax.sun_1),
    _FilterTabItem(key: 'Tyres & Wheels', label: 'Tyres', icon: Iconsax.repeat),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getCategoryRoute(String label) {
    switch (label.toLowerCase()) {
      case 'repair':
        return '/select-service';
      case 'rentals':
        return '/rentals-selection';
      case 'ev service':
        return '/select-service';
      case 'water service':
        return '/water-service-booking';
      case 'logistics':
        return '/delivery/create';
      default:
        return '/select-service';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(homeCategoriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── TOP APP BAR & HEADER ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore Services',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Find certified experts for your vehicle',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
                          ),
                          child: Row(
                            children: [
                              const PulseBeacon(
                                color: Color(0xFF006241),
                                size: 7,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'ONLINE',
                                style: GoogleFonts.inter(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF006241),
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const SOSButton.headerPill(
                          rideDetails: 'Explore Services Catalog',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── REACT-STYLE GLASS SEARCH BAR ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _searchQuery.isNotEmpty
                          ? const Color(0xFF006241)
                          : const Color(0xFFE2E8F0),
                      width: _searchQuery.isNotEmpty ? 1.5 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Iconsax.search_normal_1,
                        size: 19,
                        color: _searchQuery.isNotEmpty
                            ? const Color(0xFF006241)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(
                              () => _searchQuery = value.toLowerCase()),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: 'Search repairs, rentals, EV, wash...',
                            hintStyle: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF94A3B8),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.close_rounded,
                                size: 18, color: Color(0xFF94A3B8)),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Iconsax.candle_2,
                          color: Color(0xFF006241),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── REACT-STYLE PREMIUM SEGMENTED CATEGORY PILLS ─────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 46,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filterTabs.length,
                  itemBuilder: (context, index) {
                    final item = _filterTabs[index];
                    return _buildReactFilterPill(item);
                  },
                ),
              ),
            ),

            // ── REACT-STYLE TRUST & ARRIVAL BANNER ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border:
                        Border.all(color: const Color(0xFFBBF7D0), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF006241).withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF006241), Color(0xFF10B981)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Iconsax.shield_tick,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '100% Certified Mechanics',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Text(
                                    '★ 4.9',
                                    style: GoogleFonts.inter(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '30-Min Rapid Doorstep Arrival in Bengaluru',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF006241),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── SECTION HEADER ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchQuery.isEmpty
                          ? (_activeFilterTab == 'All'
                              ? 'All Services & Packages'
                              : '$_activeFilterTab Services')
                          : 'Results for "$_searchQuery"',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'INSTANT BOOKING',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── SERVICE CATALOG LIST (REACT TIER-1 CARDS) ────────────────────
            categoriesAsync.when(
              data: (categories) {
                final filtered = categories.where((c) {
                  final matchesQuery = _searchQuery.isEmpty ||
                      c.label.toLowerCase().contains(_searchQuery);
                  final matchesTab = _activeFilterTab == 'All' ||
                      c.label.toLowerCase() == _activeFilterTab.toLowerCase();
                  return matchesQuery && matchesTab;
                }).toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Icon(
                                Iconsax.search_status,
                                size: 28,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'No services found',
                              style: GoogleFonts.outfit(
                                color: const Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try searching for another category or reset filters',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF64748B),
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = filtered[index];
                        final icon = IconHelper.getIcon(cat.icon);
                        final route = getCategoryRoute(cat.label);
                        final meta = _getCategoryMetadata(cat.label);

                        return ScaleOnTap(
                          onTap: () {
                            if (route == '/bike-service-booking') {
                              final bikes = ref
                                  .read(allVehiclesProvider)
                                  .where((v) =>
                                      v.type == 'Bike' || v.type == 'EV Bike')
                                  .toList();
                              if (bikes.isNotEmpty) {
                                ref
                                    .read(vehicleProvider.notifier)
                                    .setVehicle(bikes.first);
                              }
                            } else if (route == '/car-service-booking') {
                              final cars = ref
                                  .read(allVehiclesProvider)
                                  .where((v) => v.type == 'Car')
                                  .toList();
                              if (cars.isNotEmpty) {
                                ref
                                    .read(vehicleProvider.notifier)
                                    .setVehicle(cars.first);
                              }
                            }
                            context.push(route);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: meta.gradient.first
                                      .withValues(alpha: 0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // 3D Squircle with Dual Linear Gradient
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: meta.gradient,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: meta.gradient.first
                                            .withValues(alpha: 0.28),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Icon(
                                      icon,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Title, Subtitle & Micro Badges
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              meta.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.outfit(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF0F172A),
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: meta.badgeBg,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                color: meta.badgeColor
                                                    .withValues(alpha: 0.2),
                                              ),
                                            ),
                                            child: Text(
                                              '${cat.count} SERVICES',
                                              style: GoogleFonts.inter(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: meta.badgeColor,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        meta.description,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF0FDF4),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFFDCFCE7)),
                                            ),
                                            child: Text(
                                              meta.startingPrice,
                                              style: GoogleFonts.inter(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF006241),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '•',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              color: const Color(0xFFCBD5E1),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            meta.tag,
                                            style: GoogleFonts.inter(
                                              fontSize: 10.5,
                                              color: const Color(0xFF64748B),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Right Chevron Circle Button
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFF8FAFC),
                                    border: Border.all(
                                        color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Iconsax.arrow_right_3,
                                      size: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate(delay: Duration(milliseconds: 35 * index))
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.05, end: 0);
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: Color(0xFF006241)),
                  ),
                ),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('Error: $err'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// React-Style Premium Filter Pill with custom Vector Icon & Active Glow
  Widget _buildReactFilterPill(_FilterTabItem item) {
    final isSelected = _activeFilterTab == item.key;

    return ScaleOnTap(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _activeFilterTab = item.key);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF006241), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF006241) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.4 : 1.1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF006241).withValues(alpha: 0.28),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  size: 13,
                  color: isSelected ? Colors.white : const Color(0xFF006241),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF334155),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _CategoryMetadata _getCategoryMetadata(String label) {
    switch (label.toLowerCase()) {
      case 'rentals':
        return const _CategoryMetadata(
          title: 'Self-Drive Rentals',
          description: 'Cars, bikes & electric scooters with zero deposit',
          startingPrice: 'From ₹45/hr',
          tag: 'Doorstep Delivery',
          gradient: [Color(0xFF0284C7), Color(0xFF38BDF8)],
          badgeBg: Color(0xFFF0F9FF),
          badgeColor: Color(0xFF0284C7),
        );
      case 'ev service':
        return const _CategoryMetadata(
          title: 'EV Hub & Battery Care',
          description: 'Battery diagnostic, BMS update & charging inspection',
          startingPrice: 'From ₹299',
          tag: 'Certified EV Tech',
          gradient: [Color(0xFF059669), Color(0xFF34D399)],
          badgeBg: Color(0xFFECFDF5),
          badgeColor: Color(0xFF059669),
        );
      case 'water service':
        return const _CategoryMetadata(
          title: 'Eco Foam Wash & Spa',
          description: 'High-pressure wash, interior vacuum & ceramic wax',
          startingPrice: 'From ₹199',
          tag: 'Doorstep Spa',
          gradient: [Color(0xFF0891B2), Color(0xFF22D3EE)],
          badgeBg: Color(0xFFECFEFF),
          badgeColor: Color(0xFF0891B2),
        );
      case 'repair':
        return const _CategoryMetadata(
          title: 'General Repair & Inspection',
          description: 'Engine tune-up, brake overhaul & mechanical repairs',
          startingPrice: 'From ₹349',
          tag: 'OEM Spare Parts',
          gradient: [Color(0xFFE11D48), Color(0xFFFB7185)],
          badgeBg: Color(0xFFFFF1F2),
          badgeColor: Color(0xFFE11D48),
        );
      case 'logistics':
        return const _CategoryMetadata(
          title: 'Courier & Hyperlocal Cargo',
          description: 'Doorstep parcel pickup & intercity delivery transport',
          startingPrice: 'From ₹49',
          tag: 'Express Dispatch',
          gradient: [Color(0xFF0D9488), Color(0xFF14B8A6)],
          badgeBg: Color(0xFFF0FDFA),
          badgeColor: Color(0xFF0D9488),
        );
      case 'oil & fluids':
        return const _CategoryMetadata(
          title: 'Oil & Fluid Flush',
          description: 'Synthetic engine oil, brake fluid & coolant top-up',
          startingPrice: 'From ₹499',
          tag: 'Top Grade Oils',
          gradient: [Color(0xFFD97706), Color(0xFFFBBF24)],
          badgeBg: Color(0xFFFFFBEB),
          badgeColor: Color(0xFFD97706),
        );
      case 'ac & climate':
        return const _CategoryMetadata(
          title: 'AC & Climate Overhaul',
          description: 'Cooling gas recharge, antibacterial wash & leak test',
          startingPrice: 'From ₹799',
          tag: 'Chilled Cabin',
          gradient: [Color(0xFF006241), Color(0xFF10B981)],
          badgeBg: Color(0xFFF0FDF4),
          badgeColor: Color(0xFF006241),
        );
      case 'tyres & wheels':
        return const _CategoryMetadata(
          title: 'Tyres, Alignment & Balance',
          description: '3D laser alignment, wheel balancing & puncture repair',
          startingPrice: 'From ₹149',
          tag: 'Laser Accurate',
          gradient: [Color(0xFF334155), Color(0xFF64748B)],
          badgeBg: Color(0xFFF8FAFC),
          badgeColor: Color(0xFF475569),
        );
      case 'electrical':
        return const _CategoryMetadata(
          title: 'Electrical & ECU Scan',
          description: 'Battery health, ECU fault code scan & wiring harness',
          startingPrice: 'From ₹249',
          tag: 'Digital OBD-II',
          gradient: [Color(0xFFEA580C), Color(0xFFFB923C)],
          badgeBg: Color(0xFFFFF7ED),
          badgeColor: Color(0xFFEA580C),
        );
      default:
        return const _CategoryMetadata(
          title: 'Automotive Care',
          description: 'Comprehensive automotive service and maintenance',
          startingPrice: 'From ₹299',
          tag: 'Expert Care',
          gradient: [Color(0xFF006241), Color(0xFF10B981)],
          badgeBg: Color(0xFFF0FDF4),
          badgeColor: Color(0xFF006241),
        );
    }
  }
}

class _FilterTabItem {
  final String key;
  final String label;
  final IconData icon;

  const _FilterTabItem({
    required this.key,
    required this.label,
    required this.icon,
  });
}

class _CategoryMetadata {
  final String title;
  final String description;
  final String startingPrice;
  final String tag;
  final List<Color> gradient;
  final Color badgeBg;
  final Color badgeColor;

  const _CategoryMetadata({
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.tag,
    required this.gradient,
    required this.badgeBg,
    required this.badgeColor,
  });
}
