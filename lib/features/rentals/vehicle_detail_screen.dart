import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/live_map_widget.dart';

class RentalVehicleDetailScreen extends StatelessWidget {
  const RentalVehicleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary)),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/baleno.png',
                    fit: BoxFit.cover,
                  ),
                  // Animated Premium Badge
                  Positioned(
                    bottom: 40,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.verify5, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'PREMIUM FLEET',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.5, end: 0),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text('Maruti Baleno', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                       Text('₹1,200/day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                     ],
                   ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                   const SizedBox(height: 8),
                   const Row(
                     children: [
                       Icon(Iconsax.star1, color: Colors.amber, size: 16),
                       SizedBox(width: 4),
                       Text('4.9 (124 reviews)', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                     ],
                   ).animate().fadeIn(delay: 200.ms),
                   
                   const SizedBox(height: 32),
                   const Text('Specifications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 16),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       _buildSpecCard(Iconsax.gas_station, 'Petrol'),
                       _buildSpecCard(Iconsax.setting_4, 'Manual'),
                       _buildSpecCard(Iconsax.user, '5 Seats'),
                     ],
                   ),
                   
                   const SizedBox(height: 32),
                   const Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 12),
                   Wrap(
                     spacing: 8,
                     runSpacing: 8,
                     children: ['Air Conditioning', 'Power Windows', 'Bluetooth', 'Reverse Camera', 'ABS'].asMap().entries.map((entry) => Chip(
                       label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                       backgroundColor: AppColors.bgLightGrey,
                       side: BorderSide.none,
                     ).animate().fadeIn(delay: (400 + entry.key * 50).ms).scale()).toList(),
                   ),
                   
                   const SizedBox(height: 32),
                   const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                   const SizedBox(height: 12),
                   const Text(
                     'The Maruti Baleno is a premium hatchback with a perfect blend of style, comfort, and efficiency. Ideal for city drives and highway cruises.',
                     style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                   ).animate().fadeIn(delay: 600.ms),
                    
                    const SizedBox(height: 32),
                    const Text('Pickup Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const LiveMapWidget(height: 200).animate().fadeIn(delay: 800.ms).scale(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: CustomButton(
          label: 'BOOK NOW',
          onPressed: () => context.push('/rental-checkout'),
        ),
      ),
    );
  }

  Widget _buildSpecCard(IconData icon, String val) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(height: 8),
          Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

