import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/vehicle_provider.dart';
import 'home_providers.dart';
import '../../core/utils/icon_helper.dart';

/// Explore/Search Screen - Service categories and search with live filtering
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String getCategoryRoute(String label) {
    switch (label.toLowerCase()) {
      case 'repair': return '/select-service';
      case 'rentals': return '/rentals-selection';
      case 'ev service': return '/select-service';
      case 'water service': return '/water-service-booking';
      case 'logistics': return '/delivery-logistics';
      default: return '/select-service';
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(homeCategoriesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  'Explore Services',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

            // Functional Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(Iconsax.search_normal, size: 18, color: AppColors.textMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            hintText: 'Search all services...',
                            hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
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
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.all(6),
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Iconsax.setting_4,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Categories label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Text(
                  _searchQuery.isEmpty ? 'Service Categories' : 'Results for "$_searchQuery"',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Category grid with filtering
            categoriesAsync.when(
              data: (categories) {
                final filtered = _searchQuery.isEmpty
                    ? categories
                    : categories.where((c) => c.label.toLowerCase().contains(_searchQuery)).toList();

                if (filtered.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(60),
                        child: Column(
                          children: [
                            Icon(Iconsax.search_status, size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty ? 'No categories found' : 'No services match "$_searchQuery"',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = filtered[index];
                        final icon = IconHelper.getIcon(cat.icon);
                        final route = getCategoryRoute(cat.label);
                        final theme = _getCategoryTheme(cat.label);

                        return GestureDetector(
                          onTap: () {
                            if (route == '/bike-service-booking') {
                              final bikes = ref.read(allVehiclesProvider).where((v) => v.type == 'Bike' || v.type == 'EV Bike').toList();
                              if (bikes.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(bikes.first);
                            } else if (route == '/car-service-booking') {
                              final cars = ref.read(allVehiclesProvider).where((v) => v.type == 'Car').toList();
                              if (cars.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(cars.first);
                            } else if (route == '/ev-bike-service-booking') {
                              final evBikes = ref.read(allVehiclesProvider).where((v) => v.type == 'EV Bike').toList();
                              if (evBikes.isNotEmpty) {
                                ref.read(vehicleProvider.notifier).setVehicle(evBikes.first);
                              } else {
                                final bikes = ref.read(allVehiclesProvider).where((v) => v.type == 'Bike').toList();
                                if (bikes.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(bikes.first);
                              }
                            } else if (route == '/water-service-booking') {
                              final cars = ref.read(allVehiclesProvider).where((v) => v.type == 'Car').toList();
                              if (cars.isNotEmpty) ref.read(vehicleProvider.notifier).setVehicle(cars.first);
                            }
                            context.push(route);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: theme.gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: theme.primary.withValues(alpha: 0.12)),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primary.withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.primary.withValues(alpha: 0.12),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        icon,
                                        color: theme.primary,
                                        size: 20,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: theme.primary.withValues(alpha: 0.4),
                                      size: 14,
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.label,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.primary.withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${cat.count} services',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: theme.accent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 400.ms);
                      },
                      childCount: filtered.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))),
              error: (err, stack) => SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.all(40), child: Text('Error: $err')))),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  _CategoryTheme _getCategoryTheme(String label) {
    switch (label.toLowerCase()) {
      case 'repair':
        return const _CategoryTheme(
          primary: Color(0xFF3B82F6), // Blue
          accent: Color(0xFF1D4ED8),
          gradient: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
        );
      case 'rentals':
        return const _CategoryTheme(
          primary: Color(0xFF10B981), // Emerald
          accent: Color(0xFF047857),
          gradient: [Color(0xFFECFDF5), Color(0xFFD1FAE5)],
        );
      case 'ev service':
        return const _CategoryTheme(
          primary: Color(0xFFF59E0B), // Amber
          accent: Color(0xFFB45309),
          gradient: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
        );
      case 'water service':
        return const _CategoryTheme(
          primary: Color(0xFF06B6D4), // Cyan
          accent: Color(0xFF0E7490),
          gradient: [Color(0xFFECFEFF), Color(0xFFCFFAFE)],
        );
      case 'logistics':
        return const _CategoryTheme(
          primary: Color(0xFF8B5CF6), // Violet
          accent: Color(0xFF6D28D9),
          gradient: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
        );
      case 'oil & fluids':
        return const _CategoryTheme(
          primary: Color(0xFFEF4444), // Red
          accent: Color(0xFFB91C1C),
          gradient: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
        );
      default:
        return const _CategoryTheme(
          primary: Color(0xFF6366F1), // Indigo
          accent: Color(0xFF4338CA),
          gradient: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
        );
    }
  }
}

class _CategoryTheme {
  final Color primary;
  final Color accent;
  final List<Color> gradient;

  const _CategoryTheme({
    required this.primary,
    required this.accent,
    required this.gradient,
  });
}
