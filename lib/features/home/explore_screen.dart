import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/home/vehicle_provider.dart';

/// Explore/Search Screen - Service categories and search
/// Matches Figma service category patterns
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = [
      {'icon': Icons.build_rounded, 'label': 'Repair', 'count': '12 services', 'color': const Color(0xFF3B82F6), 'route': '/select-service'},
      {'icon': Icons.car_rental_rounded, 'label': 'Rentals', 'count': '15+ models', 'color': const Color(0xFF8B5CF6), 'route': '/rentals'},
      {'icon': Icons.bolt_rounded, 'label': 'EV Service', 'count': '4 services', 'color': const Color(0xFF06B6D4), 'route': '/ev-bike-service-booking'},
      {'icon': Icons.local_car_wash_rounded, 'label': 'Water Service', 'count': 'Wash & Clean', 'color': const Color(0xFF0EA5E9), 'route': '/water-service-booking'},
      {'icon': Icons.local_shipping_rounded, 'label': 'Logistics', 'count': 'Full support', 'color': const Color(0xFFF97316), 'route': '/delivery-logistics'},
      {'icon': Icons.oil_barrel_rounded, 'label': 'Oil & Fluids', 'count': '6 services', 'color': const Color(0xFFF97316), 'route': '/car-service-booking'},
      {'icon': Icons.ac_unit_rounded, 'label': 'AC & Climate', 'count': '5 services', 'color': const Color(0xFF8B5CF6), 'route': '/car-service-booking'},
      {'icon': Icons.tire_repair_rounded, 'label': 'Tyres & Wheels', 'count': '10 services', 'color': const Color(0xFFEF4444), 'route': '/car-service-booking'},
      {'icon': Icons.electrical_services_rounded, 'label': 'Electrical', 'count': '9 services', 'color': const Color(0xFFFACC15), 'route': '/car-service-booking'},
    ];

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

            // Search bar
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
                      const Text(
                        'Search all services...',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const Spacer(),
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
                  'Service Categories',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Category grid
            SliverPadding(
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
                    final cat = categories[index];
                    return GestureDetector(
                      onTap: () {
                        final route = cat['route'] as String;
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
                                color: (cat['color'] as Color).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                cat['icon'] as IconData,
                                color: cat['color'] as Color,
                                size: 20,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cat['label'] as String,
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  cat['count'] as String,
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
                    )
                        .animate(delay: Duration(milliseconds: 100 * index))
                        .fadeIn(duration: 400.ms)
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1.0, 1.0),
                          duration: 400.ms,
                        );
                  },
                  childCount: categories.length,
                ),
              ),
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

