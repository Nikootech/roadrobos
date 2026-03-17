import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Screen [96]: Rental Exploration / Landing Page
class RentalExploreScreen extends ConsumerStatefulWidget {
  const RentalExploreScreen({super.key});

  @override
  ConsumerState<RentalExploreScreen> createState() => _RentalExploreScreenState();
}

class _RentalExploreScreenState extends ConsumerState<RentalExploreScreen> {
  String _selectedCategory = 'Recent';

  final List<String> _categories = ['Recent', 'Popular', 'SUV', 'Sedan'];

  final List<Map<String, dynamic>> _topVehicles = [
    {
      'name': 'Maruti Baleno',
      'type': 'Hatchback',
      'price': '₹159/hr',
      'rating': '4.9',
      'seats': '5 Seats',
      'image': 'assets/images/baleno.png',
      'category': 'Popular',
    },
    {
      'name': 'Honda City',
      'type': 'Sedan',
      'price': '₹179/hr',
      'rating': '4.9',
      'seats': '5 Seats',
      'image': 'assets/images/city.png',
      'category': 'Luxury',
    },
    {
      'name': 'Maruti Swift',
      'type': 'Hatchback',
      'price': '₹129/hr',
      'rating': '4.8',
      'seats': '5 Seats',
      'image': 'assets/images/swift.png',
      'category': 'Popular',
    },
    {
      'name': 'Mahindra Scorpio',
      'type': 'SUV',
      'price': '₹219/hr',
      'rating': '4.7',
      'seats': '7 Seats',
      'image': 'assets/images/scorpio.png',
      'category': 'Popular',
    },
  ];

  List<Map<String, dynamic>> get _filteredVehicles {
    if (_selectedCategory == 'Recent') return _topVehicles;
    return _topVehicles.where((v) => v['category'] == _selectedCategory || v['type'] == _selectedCategory).toList();
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
            onPressed: () {},
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
                      // Show search overlay or focus a real field
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
                  ..._categories.map((cat) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _buildTab(cat, _selectedCategory == cat),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section 1: Top Recommendations (Figma [96]: FRAME: "list")
            _buildSectionHeader('Top Recommendations'),
            _buildVehicleList(context),

            const SizedBox(height: 32),

            // Section 2: Recently Viewed (Figma [96]: FRAME: "list")
            _buildSectionHeader('Top Recommendations', () => context.push('/rentals-selection')),
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

  Widget _buildTab(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedCategory = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.bgLightGrey,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
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
      height: 480,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _filteredVehicles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final vehicle = _filteredVehicles[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/rental-detail');
            },
            child: Container(
              width: 300,
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
                  Stack(
                    children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Hero(
                          tag: 'vehicle_rec_${vehicle['name']}',
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
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            vehicle['price'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_outline_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
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
                            const Icon(Iconsax.user, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              vehicle['seats'],
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Iconsax.car, size: 14, color: AppColors.textSecondary),
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
                            context.push('/rental-detail');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
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
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 2,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            context.push('/rental-detail');
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
                  child: const Icon(Icons.car_rental_rounded, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hyundai Venue', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('Compact SUV', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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

