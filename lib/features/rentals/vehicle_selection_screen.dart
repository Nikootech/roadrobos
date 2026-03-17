import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import 'rental_providers.dart';

/// Rentals - Vehicle Selection Screen matching Figma Screen [3] & [4]
class VehicleSelectionScreen extends ConsumerStatefulWidget {
  const VehicleSelectionScreen({super.key});

  @override
  ConsumerState<VehicleSelectionScreen> createState() => _VehicleSelectionScreenState();
}

class _VehicleSelectionScreenState extends ConsumerState<VehicleSelectionScreen> {
  final List<String> _filters = ['All', 'Sedan', 'SUV', 'Popular', 'Luxury'];
  int _selectedFilterIndex = 0;

  final List<Map<String, dynamic>> _vehicles = [
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
      'name': 'Maruti Swift',
      'type': 'Hatchback',
      'price': '₹129/hr',
      'rating': '4.8',
      'seats': '5 Seats',
      'image': 'assets/images/swift.png',
      'category': 'Popular',
    },
    {
      'name': 'Suzuki Dzire',
      'type': 'Sedan',
      'price': '₹149/hr',
      'rating': '4.7',
      'seats': '5 Seats',
      'image': 'assets/images/dzire.png',
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
      'name': 'Mahindra Scorpio',
      'type': 'SUV',
      'price': '₹219/hr',
      'rating': '4.7',
      'seats': '7 Seats',
      'image': 'assets/images/scorpio.png',
      'category': 'Popular',
    },
    {
      'name': 'Toyota Innova',
      'type': 'SUV',
      'price': '₹249/hr',
      'rating': '4.8',
      'seats': '7 Seats',
      'image': 'assets/images/innova.png',
      'category': 'Popular',
    },
  ];

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
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedFilterIndex = index);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBlue : AppColors.bgLightGrey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _filters[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: _vehicles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          // Simple filtering logic
          if (_selectedFilterIndex != 0) {
            final filter = _filters[_selectedFilterIndex].toLowerCase();
            if (vehicle['type'].toString().toLowerCase() != filter && 
                vehicle['category'].toString().toLowerCase() != filter) {
              return const SizedBox.shrink();
            }
          }
          
          return _buildPremiumVehicleCard(vehicle)
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }

  Widget _buildPremiumVehicleCard(Map<String, dynamic> vehicle) {
    return Container(
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
          // Image Area with Price Overlay
          Stack(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
              // Price Badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    vehicle['price'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Wishlist Button
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_outline_rounded,
                    color: AppColors.textSecondary,
                    size: 22,
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
                    Text(
                      vehicle['name'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          vehicle['rating'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Iconsax.user, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      vehicle['seats'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Iconsax.car, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      vehicle['type'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref.read(selectedVehicleProvider.notifier).state = vehicle;
                    context.push('/rental-detail');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 18,
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
    );
  }
}

