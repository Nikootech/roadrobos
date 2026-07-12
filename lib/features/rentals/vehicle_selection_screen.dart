// ignore_for_file: deprecated_member_use, unused_import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/responsive_utils.dart';
import 'rental_providers.dart';
import '../../core/models/rental_vehicle.dart';

/// Rentals - Vehicle Selection Screen matching Figma Screen [3] & [4]
class VehicleSelectionScreen extends ConsumerStatefulWidget {
  const VehicleSelectionScreen({super.key});

  @override
  ConsumerState<VehicleSelectionScreen> createState() =>
      _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState
    extends ConsumerState<VehicleSelectionScreen> {
  final List<Map<String, dynamic>> _filters = [
    {'name': 'All', 'icon': Iconsax.category},
    {'name': 'Cars', 'icon': Iconsax.car},
    {'name': 'Bikes', 'icon': Icons.pedal_bike_rounded},
    {'name': 'EV', 'icon': Icons.electric_bolt_rounded},
  ];
  int _selectedFilterIndex = 0;

  List<Map<String, dynamic>> _processFleet(List<RentalVehicle> fleet) {
    List<RentalVehicle> filtered;
    final category = _filters[_selectedFilterIndex]['name'];
    if (category == 'All') {
      filtered = fleet;
    } else if (category == 'Cars') {
      filtered = fleet.where((v) => !v.isBike).toList();
    } else if (category == 'Bikes') {
      filtered = fleet.where((v) => v.isBike && v.category != 'EV').toList();
    } else if (category == 'EV') {
      filtered = fleet.where((v) => v.category == 'EV').toList();
    } else {
      filtered = fleet.where((v) => v.category == category).toList();
    }
    // Include the Supabase id so the router can fetch by ID
    return filtered.map((v) => v.toMap()..['id'] = v.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Rental Fleet',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                color: AppColors.textPrimary),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilterIndex == index;
                final filterMap = _filters[index];
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedFilterIndex = index);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryBlue
                          : AppColors.bgLightGrey,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBlue
                              : AppColors.border.withValues(alpha: 0.5)),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4))
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filterMap['icon'],
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filterMap['name'],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: ref.watch(rentalCatalogProvider).when(
            data: (fleet) {
              final vehicles = _processFleet(fleet);
              if (vehicles.isEmpty) {
                return const Center(
                    child: Text('No vehicles found for this filter'));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: vehicles.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  final vehicle = vehicles[index];

                  return _VehicleCard(
                    key: ValueKey(vehicle['name']),
                    vehicle: vehicle,
                    onTap: () {
                      if (vehicle['is_coming_soon'] == true) return;
                      HapticFeedback.mediumImpact();
                      final vehicleId = vehicle['id']?.toString() ?? '';
                      ref
                          .read(recentlyViewedProvider.notifier)
                          .addView(vehicle);
                      ref.read(selectedVehicleProvider.notifier).state =
                          vehicle;
                      context.push('/rental-detail/$vehicleId');
                    },
                  )
                      .animate()
                      .fadeIn(delay: (100 * index).ms)
                      .slideY(begin: 0.1, end: 0);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
    );
  }
}

class _VehicleCard extends ConsumerWidget {
  final Map<String, dynamic> vehicle;
  final VoidCallback onTap;

  const _VehicleCard({super.key, required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBike = vehicle['is_bike'] == true;
    final isEV = vehicle['type'] == 'EV Bike' || vehicle['category'] == 'EV';
    final isZeelio = vehicle['name'].toString().contains('Zelio');

    return GestureDetector(
      onTap: () {
        if (vehicle['is_coming_soon'] == true) return;
        ref.read(selectedVehicleProvider.notifier).state = vehicle;
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isZeelio
                  ? AppColors.primaryBlue.withValues(alpha: 0.15)
                  : (isEV
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.08)),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: isZeelio
              ? Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  width: 1.5)
              : (isEV
                  ? Border.all(color: Colors.green.withValues(alpha: 0.1))
                  : null),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area with Badges
            Stack(
              children: [
                Container(
                  height: ResponsiveLayout.responsiveHeight(context, 26),
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isEV
                        ? const Color(0xFFF0FAF0)
                        : const Color(0xFFF9FAFB),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Hero(
                    tag: 'vehicle_${vehicle['name']}',
                    child: vehicle['image_url'].toString().startsWith('http')
                        ? Image.network(vehicle['image_url'],
                            fit: BoxFit.contain)
                        : Image.asset(vehicle['image_url'],
                            fit: BoxFit.contain),
                  ),
                ),
                if (vehicle['is_coming_soon'] == true)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28)),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue
                                        .withValues(alpha: 0.9),
                                    AppColors.primaryBlue
                                        .withValues(alpha: 0.7),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue
                                        .withValues(alpha: 0.4),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer_outlined,
                                      color: Colors.white, size: 20),
                                  SizedBox(height: 4),
                                  Text(
                                    'COMING SOON',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                // EV Badge
                if (isEV)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.electric_bolt_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'ECO FRIENDLY',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Zeelio Series Badge
                if (isZeelio)
                  Positioned(
                    top: isEV ? 48 : 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryBlue.withValues(alpha: 0.9),
                            AppColors.primaryBlue.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.stars_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'ZEELIO SERIES',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Price Tag
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: vehicle['isComingSoon'] == true
                          ? AppColors.bgLightGrey
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: vehicle['isComingSoon'] == true
                          ? null
                          : [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10)
                            ],
                    ),
                    child: Text(
                      vehicle['is_coming_soon'] == true
                          ? 'N/A'
                          : vehicle['price'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: vehicle['is_coming_soon'] == true
                            ? AppColors.textMuted
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.star_rounded,
                              color: Colors.amber, size: 18),
                          SizedBox(width: 4),
                          Text('4.9',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(
                          isBike ? Icons.speed_rounded : Iconsax.user,
                          isBike
                              ? (vehicle['spec'] ?? '')
                              : (vehicle['seats'] ?? '')),
                      const SizedBox(width: 8),
                      _buildInfoChip(
                          isBike ? Icons.pedal_bike_rounded : Iconsax.car,
                          vehicle['type']),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      if (vehicle['is_coming_soon'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'We will notify you when ${vehicle['name']} is available!'),
                            backgroundColor: AppColors.primaryBlue,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                        return;
                      }
                      final vehicleId = vehicle['id']?.toString() ?? '';
                      ref
                          .read(recentlyViewedProvider.notifier)
                          .addView(vehicle);
                      ref.read(selectedVehicleProvider.notifier).state =
                          vehicle;
                      context.push('/rental-detail/$vehicleId');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vehicle['is_coming_soon'] == true
                          ? Colors.white
                          : AppColors.primaryBlue,
                      foregroundColor: vehicle['is_coming_soon'] == true
                          ? AppColors.primaryBlue
                          : Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: vehicle['is_coming_soon'] == true
                            ? const BorderSide(
                                color: AppColors.primaryBlue, width: 2)
                            : BorderSide.none,
                      ),
                      elevation: vehicle['is_coming_soon'] == true ? 0 : 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          vehicle['is_coming_soon'] == true
                              ? Icons.notifications_active_outlined
                              : Icons.bolt_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          vehicle['is_coming_soon'] == true
                              ? 'Notify Me'
                              : 'Book Now',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (vehicle['is_coming_soon'] != true) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgLightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
