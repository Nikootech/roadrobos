// ignore_for_file: deprecated_member_use, unused_import
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
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
              size: 18, color: Color(0xFF0F172A)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Rental Fleet',
          style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Iconsax.notification,
                  size: 18, color: Color(0xFF0F172A)),
              onPressed: () => context.push('/notifications'),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            height: 56,
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
                    duration: const Duration(milliseconds: 250),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF006241), Color(0xFF10B981)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFE2E8F0)),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: const Color(0xFF006241)
                                      .withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3))
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filterMap['icon'],
                          size: 15,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          filterMap['name'],
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF0F172A),
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

    return GestureDetector(
      onTap: () {
        if (vehicle['is_coming_soon'] == true) return;
        ref.read(selectedVehicleProvider.notifier).state = vehicle;
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area with Badges
            Stack(
              children: [
                Container(
                  height: ResponsiveLayout.responsiveHeight(context, 24),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
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
                          const BorderRadius.vertical(top: Radius.circular(24)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24)),
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF006241),
                                    Color(0xFF10B981)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'COMING SOON',
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 1.5,
                                ),
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
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.flash_1,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            'EV GREEN',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Price Tag
                Positioned(
                  bottom: 14,
                  right: 14,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      vehicle['is_coming_soon'] == true
                          ? 'N/A'
                          : vehicle['price'],
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF006241),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle['name'],
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFFDE68A)
                                  .withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFFF59E0B), size: 15),
                            const SizedBox(width: 3),
                            Text('4.9',
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: const Color(0xFFB45309))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildInfoChip(
                          isBike ? Iconsax.speedometer : Iconsax.profile_2user,
                          isBike
                              ? (vehicle['spec'] ?? '')
                              : (vehicle['seats'] ?? '')),
                      const SizedBox(width: 8),
                      _buildInfoChip(isBike ? Iconsax.routing : Iconsax.car,
                          vehicle['type']),
                    ],
                  ),
                  const SizedBox(height: 18),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (vehicle['is_coming_soon'] == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'We will notify you when ${vehicle['name']} is available!'),
                            backgroundColor: const Color(0xFF006241),
                            behavior: SnackBarBehavior.floating,
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
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF006241), Color(0xFF10B981)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF006241).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.flash_1,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            vehicle['is_coming_soon'] == true
                                ? 'Notify Me'
                                : 'Book Now',
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Iconsax.arrow_right_3,
                              color: Colors.white, size: 14),
                        ],
                      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}
