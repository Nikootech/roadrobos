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
                        const color = AppColors.primaryBlue;
                        final route = getCategoryRoute(cat.label);

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
                              color: AppColors.bgSkyLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: color,
                                    size: 20,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cat.label,
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      '${cat.count} services',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
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
}
