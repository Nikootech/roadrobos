import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'rental_providers.dart';
import '../../core/data/mock_data.dart';
import '../../shared/widgets/responsive_utils.dart';

class RentalExploreScreen extends ConsumerStatefulWidget {
  const RentalExploreScreen({super.key});

  @override
  ConsumerState<RentalExploreScreen> createState() => _RentalExploreScreenState();
}

class _RentalExploreScreenState extends ConsumerState<RentalExploreScreen> {
  String _selectedCategory = 'All';

  final List<Map<String, dynamic>> _topVehicles = MockData.rentalVehicles;

  List<Map<String, dynamic>> get _filteredVehicles {
    if (_selectedCategory == 'All') return _topVehicles;
    if (_selectedCategory == 'Cars') return _topVehicles.where((v) => v['isBike'] != true).toList();
    if (_selectedCategory == 'Bikes') return _topVehicles.where((v) => v['isBike'] == true && v['category'] != 'EV' && v['type'] != 'EV Bike').toList();
    return _topVehicles.where((v) => v['category'] == _selectedCategory || (v['isBike'] == true && _selectedCategory == 'EV' && v['type'] == 'EV Bike')).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Rental Fleet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Rentals Input (Figma [96]: FRAME: "Input")
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Search Rentals',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore our diverse range of vehicles available for rent.',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/rentals-selection'); // Navigate to full selection which has search
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.bgLightGrey,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 16),
                          Icon(Iconsax.search_normal, size: 20, color: AppColors.textMuted),
                          SizedBox(width: 12),
                          Text(
                            'Search by car name, type...',
                            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tab Group (Figma [96]: FRAME: "tab group")
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ...[
                    {'name': 'All', 'icon': Iconsax.category},
                    {'name': 'Cars', 'icon': Iconsax.car},
                    {'name': 'Bikes', 'icon': Icons.pedal_bike_rounded},
                    {'name': 'EV', 'icon': Icons.electric_bolt_rounded},
                  ].map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildTab(cat, _selectedCategory == cat['name']),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section 1: Top Recommendations (Figma [96]: FRAME: "list")
            _buildSectionHeader('Top Recommendations', () => context.push('/rentals-selection')),
            _buildVehicleList(context),

            const SizedBox(height: 32),

            // Section 2: Recently Viewed (Figma [96]: FRAME: "list")
            _buildSectionHeader('Recently Viewed', () => context.push('/rentals-selection')),
            _buildRecentList(context),

            const SizedBox(height: 100),
          ],
        ),
      ),
      // Bottom persistent button to go to full selection
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            context.push('/rentals-selection');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text(
            'Explore All Vehicles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(Map<String, dynamic> categoryData, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedCategory = categoryData['name']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.bgLightGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border.withValues(alpha: 0.5)),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryData['icon'],
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              categoryData['name'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, [VoidCallback? onSeeAll]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleList(BuildContext context) {
    return SizedBox(
      height: ResponsiveLayout.responsiveHeight(context, 55),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filteredVehicles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final vehicle = _filteredVehicles[index];
          return GestureDetector(
            onTap: () {
              if (vehicle['isComingSoon'] == true) return;
              HapticFeedback.lightImpact();
              final slug = vehicle['name'].toString().toLowerCase().replaceAll(' ', '-');
              ref.read(recentlyViewedProvider.notifier).addView(vehicle);
              ref.read(selectedVehicleProvider.notifier).state = vehicle;
              context.push('/rental-detail/$slug');
            },
            child: Container(
              width: ResponsiveLayout.responsiveWidth(context, 80),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // ... keep the rest of the column but make heights responsive
                  Stack(
                    children: [
                      Container(
                        height: ResponsiveLayout.responsiveHeight(context, 22),
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Hero(
                          tag: 'vehicle_${vehicle['name']}',
                          child: Image.asset(
                            vehicle['image'],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: vehicle['isComingSoon'] == true ? AppColors.textMuted : AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            vehicle['isComingSoon'] == true ? 'Coming Soon' : vehicle['price'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (vehicle['isComingSoon'] == true)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                                ),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryBlue.withValues(alpha: 0.9),
                                          AppColors.primaryBlue.withValues(alpha: 0.7),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.timer_outlined, color: Colors.white, size: 14),
                                        SizedBox(width: 4),
                                        Text(
                                          'COMING SOON',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 10,
                                            letterSpacing: 1,
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
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              vehicle['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  vehicle['rating'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(vehicle['isBike'] == true ? Icons.speed_rounded : Iconsax.user, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              vehicle['spec'] ?? vehicle['seats'] ?? '',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(vehicle['isBike'] == true ? Icons.pedal_bike_rounded : Iconsax.car, size: 14, color: AppColors.textSecondary),

                            const SizedBox(width: 4),
                            Text(
                              vehicle['type'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            if (vehicle['isComingSoon'] == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('We will notify you when ${vehicle['name']} is available!'),
                                  backgroundColor: AppColors.primaryBlue,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              );
                              return;
                            }
                            final slug = vehicle['name'].toString().toLowerCase().replaceAll(' ', '-');
                            ref.read(recentlyViewedProvider.notifier).addView(vehicle);
                            ref.read(selectedVehicleProvider.notifier).state = vehicle;
                            context.push('/rental-detail/$slug');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vehicle['isComingSoon'] == true ? Colors.white : AppColors.primaryBlue,
                            foregroundColor: vehicle['isComingSoon'] == true ? AppColors.primaryBlue : Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: vehicle['isComingSoon'] == true ? const BorderSide(color: AppColors.primaryBlue, width: 2) : BorderSide.none,
                            ),
                            elevation: vehicle['isComingSoon'] == true ? 0 : 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                vehicle['isComingSoon'] == true ? Icons.notifications_active_outlined : Icons.bolt_rounded,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                vehicle['isComingSoon'] == true ? 'Notify Me' : 'Book Now',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: null, // use foregroundColor
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildRecentList(BuildContext context) {
    final recentVehicles = ref.watch(recentlyViewedProvider);

    if (recentVehicles.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.bgLightGrey,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: const Center(
            child: Text(
              'Your recently viewed vehicles will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: recentVehicles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final vehicle = recentVehicles[index];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            final slug = vehicle['name'].toString().toLowerCase().replaceAll(' ', '-');
            ref.read(recentlyViewedProvider.notifier).addView(vehicle);
            ref.read(selectedVehicleProvider.notifier).state = vehicle;
            context.push('/rental-detail/$slug');
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.bgLightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: vehicle['image'] != null 
                      ? Image.asset(vehicle['image'], fit: BoxFit.contain)
                      : const Icon(Icons.car_rental, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle['name'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text(vehicle['type'], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
              ],
            ),
          ),
        ).animate().fadeIn(delay: (index * 100).ms);
      },
    );
  }
}

