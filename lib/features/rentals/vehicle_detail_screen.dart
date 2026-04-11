// ignore_for_file: deprecated_member_use, unused_import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/gsheets_api.dart';
import '../../shared/widgets/live_map_widget.dart';
import 'rental_providers.dart';

class RentalVehicleDetailScreen extends ConsumerWidget {
  const RentalVehicleDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicle = ref.watch(selectedVehicleProvider);
    
    // Log view activity once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vehicle != null) {
        GSheetsApi.logCustomerActivity(
          'VIEW_DETAIL',
          vehicle: vehicle['name'],
          price: vehicle['price'],
        );
      }
    });
    
    // Default placeholder vehicle if none selected
    final displayVehicle = vehicle ?? {
      'name': 'Maruti Baleno',
      'image': 'assets/icons/baleno.png',
      'price': '₹159/hr',
      'rating': '4.9',
      'seats': '5 Seats',
      'type': 'Hatchback',
    };

    final bool isBike = displayVehicle['isBike'] == true;
    final bool isEV = displayVehicle['type'] == 'EV Bike' || displayVehicle['category'] == 'EV';

    final String description = isBike 
        ? 'The ${displayVehicle['name']} is a perfect companion for your daily commutes. Enjoy the freedom of two wheels with this well-maintained ${displayVehicle['type'].toLowerCase()}.'
        : 'The ${displayVehicle['name']} is a premium ${displayVehicle['type'].toLowerCase()} offering a perfect blend of style, comfort, and efficiency. Ideal for city drives and highway cruises.';

    final spec1Icon = isEV ? Icons.electric_bolt_rounded : Iconsax.gas_station;
    final spec1Text = isEV ? 'Electric' : 'Petrol';

    final spec2Icon = isBike ? Icons.speed_rounded : Iconsax.setting_4;
    final spec2Text = isBike ? (displayVehicle['spec'] ?? '110cc') : 'Automatic';

    final spec3Icon = isBike ? Icons.pedal_bike_rounded : Iconsax.user;
    final spec3Text = isBike ? displayVehicle['type'] : (displayVehicle['seats'] ?? '5 Seats');

    final List<String> features = isBike
        ? (isEV ? ['Fast Charging', 'Tubeless Tyres', 'Digital Meter', 'Disc Brakes'] : ['Helmet Included', 'Disk Brakes', 'Tubeless Tyres', 'Self Start'])
        : ['Air Conditioning', 'Power Windows', 'Bluetooth', 'Reverse Camera', 'ABS'];

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
            actions: [
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.white, child: Icon(Iconsax.heart, size: 20, color: AppColors.textPrimary)),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Hero(
                    tag: 'vehicle_${displayVehicle['name']}',
                    child: Image.asset(
                      displayVehicle['image'],
                      fit: BoxFit.contain,
                    ),
                  ),
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
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(displayVehicle['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
                      Text(displayVehicle['price'] ?? '₹159/hr', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaryBlue)),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Iconsax.star1, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${displayVehicle['rating']} (124 reviews)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSpecCard(spec1Icon, spec1Text),
                      _buildSpecCard(spec2Icon, spec2Text),
                      _buildSpecCard(spec3Icon, spec3Text),
                    ],
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  const Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: features.asMap().entries.map((entry) => Chip(
                      label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                      backgroundColor: AppColors.bgLightGrey,
                      side: BorderSide.none,
                    ).animate().fadeIn(delay: (400 + entry.key * 50).ms).scale()).toList(),
                  ),
                  const SizedBox(height: 32),
                  if (isEV) ...[
                    const Text('Eco-Friendly Advantage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.1)),
                      ),
                      child: const Column(
                        children: [
                          _EcoRow(Icons.eco_rounded, 'Zero Carbon Emissions'),
                          SizedBox(height: 12),
                          _EcoRow(Icons.volume_off_rounded, 'Silent & Smooth Operation'),
                          SizedBox(height: 12),
                          _EcoRow(Icons.bolt_rounded, 'Fast Charging Support'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 32),
                  ],
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 32),
                  const Text('Pickup Location', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (isEV) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgLightGrey,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on_rounded, color: AppColors.primaryBlue),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RoAd RoBo\'s EV Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                                SizedBox(height: 4),
                                Text('View exact location and get directions on Google Maps.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final url = Uri.parse('https://maps.app.goo.gl/mkgcjKXEKmJvUEtv6');
                              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                                debugPrint('Could not launch EV Hub URL');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              minimumSize: const Size(0, 40),
                            ),
                            child: const Text('Directions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 750.ms),
                    const SizedBox(height: 16),
                  ],
                  const LiveMapWidget(height: 200).animate().fadeIn(delay: 800.ms).scale(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Price', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  Text(displayVehicle['price'] ?? '₹159/hr', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    if (isBike || isEV) {
                      final slug = displayVehicle['name']
                          .toString()
                          .toLowerCase()
                          .replaceAll(' ', '-');
                      final url = Uri.parse('https://roadrobos.com/product/$slug');
                      
                      try {
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          await launchUrl(Uri.parse('https://roadrobos.com'), mode: LaunchMode.externalApplication);
                        }
                        // Log website redirect lead
                        GSheetsApi.logCustomerActivity(
                          'WEBSITE_REDIRECT',
                          vehicle: displayVehicle['name'],
                          details: 'Slug: $slug',
                        );
                      } catch (e) {
                        await launchUrl(Uri.parse('https://roadrobos.com'), mode: LaunchMode.externalApplication);
                      }
                    } else {
                      // Internal booking flow for cars
                      context.push('/rental-checkout');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (isBike || isEV) ? 'Book through the website' : 'Book Now',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Icon((isBike || isEV) ? Icons.open_in_new_rounded : Icons.arrow_forward_ios_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
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

class _EcoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EcoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.green.shade600, size: 20),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.green.shade900, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
