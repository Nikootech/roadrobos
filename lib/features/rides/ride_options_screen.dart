import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../providers/taxi_provider.dart';

class RideOptionsScreen extends ConsumerStatefulWidget {
  const RideOptionsScreen({super.key});

  @override
  ConsumerState<RideOptionsScreen> createState() => _RideOptionsScreenState();
}

class _RideOptionsScreenState extends ConsumerState<RideOptionsScreen> {
  RideOption? _selectedRide;

  @override
  void initState() {
    super.initState();
    // Default selection
    _selectedRide = RideOption(
      id: 'bike',
      title: 'Bike',
      price: 47,
      subtitle: '1 min away • Drop 1:05 pm',
      icon: Icons.motorcycle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Full Screen Route Map
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              showLiveIndicator: false,
            ),
          ),

          // 2. Floating Header Over Map
          SafeArea(
            child: Column(
              children: [
                _buildMapAddressControls(context, taxiState),
                const Spacer(),
                _buildAddStopButton(),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // 3. Draggable Vehicles Sheet (Rapido Style)
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                    ),

                    // Vehicle Options List
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: taxiState.rideOptions.length,
                        itemBuilder: (context, index) {
                          final option = taxiState.rideOptions[index];
                          final isSelected = _selectedRide?.title == option.title;
                          
                          // Use user-provided icons with fallback
                          String seats = '4';
                          if (option.id.contains('bike')) {
                            seats = '1';
                          } else if (option.id.contains('auto')) {
                            seats = '3';
                          }

                          return _buildVehicleSelectableItem(
                            option.title,
                            '₹${option.price.toStringAsFixed(0)}',
                            seats,
                            option.subtitle,
                            option.assetPath,
                            fallbackIcon: option.icon,
                            badge: option.tag,
                            isSelected: isSelected,
                            onTap: () {
                              setState(() => _selectedRide = option);
                              ref.read(taxiProvider.notifier).selectOption(option);
                              HapticFeedback.selectionClick();
                            },
                          );
                        },
                      ),
                    ),

                    // Footer Settings (Cash / Offers)
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(child: _buildFooterOption(Icons.wallet, 'Cash')),
                          Container(width: 1, height: 20, color: Colors.grey[200]),
                          Expanded(child: _buildFooterOption(Icons.local_offer, 'Offers')),
                        ],
                      ),
                    ),

                    // Book Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedRide != null) {
                              ref.read(taxiProvider.notifier).selectOption(_selectedRide!);
                              ref.read(taxiProvider.notifier).startSearching();
                              context.push('/taxi/tracking');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Book Ride Direct',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapAddressControls(BuildContext context, TaxiState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const Spacer(),
              // Pickup Pill
              Flexible(
                child: _buildAddressPill(context, state.pickupAddress ?? 'Pick-up'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: _buildAddressPill(context, state.dropoffAddress ?? 'Destination', isPickup: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPill(BuildContext context, String address, {bool isPickup = true}) {
    return GestureDetector(
      onTap: () {
        ref.read(taxiProvider.notifier).setFocus(isPickup);
        context.pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPickup ? Icons.circle : Icons.location_on,
              color: isPickup ? Colors.green : Colors.red,
              size: 14,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                address,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.edit_location_alt_rounded, size: 16, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildAddStopButton() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 18, color: Colors.black),
              SizedBox(width: 8),
              Text('Add stop', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelectableItem(
    String name, 
    String price, 
    String seats, 
    String eta, 
    String? imagePath, {
    IconData? fallbackIcon,
    String? badge, 
    bool isSelected = false, 
    VoidCallback? onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.black.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))
          ] : null,
        ),
        child: Row(
          children: [
            // Icon Container
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: imagePath != null 
                      ? (imagePath.startsWith('http') 
                          ? Image.network(imagePath, width: 44, height: 44, errorBuilder: (_, __, ___) => Icon(fallbackIcon ?? Icons.local_taxi, size: 32, color: Colors.black45))
                          : Image.asset(imagePath, width: 44, height: 44, errorBuilder: (_, __, ___) => Icon(fallbackIcon ?? Icons.local_taxi, size: 32, color: Colors.black45)))
                      : Icon(fallbackIcon ?? Icons.local_taxi, size: 32, color: isSelected ? AppColors.primaryBlue : Colors.black45),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badge == 'Quickest' ? AppColors.dangerRed : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 8),
                      Icon(Icons.person, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Text(seats, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.bold)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: AppColors.primaryBlueDark,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(eta, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            // Price
            Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0).shimmer(color: Colors.white24).scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
    );
  }

  Widget _buildFooterOption(IconData icon, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      ],
    );
  }
}
