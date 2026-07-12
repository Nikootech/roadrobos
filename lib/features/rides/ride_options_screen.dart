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

  String _paymentMethod = 'Cash'; // default

  @override
  void initState() {
    super.initState();
    // Defer selection to first frame so we can read provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final options = ref.read(taxiProvider).rideOptions;
      if (options.isNotEmpty && mounted) {
        setState(() {
          _selectedRide = options.first; // use real first option with real price
          ref.read(taxiProvider.notifier).selectOption(options.first);
        });
      }
    });
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

                    // Title and Distance (Image 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Suggested rides', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              '${taxiState.distance.toStringAsFixed(1)}km • ${taxiState.eta ?? '15 min'}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Vehicle Options List
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: taxiState.rideOptions.length,
                        itemBuilder: (context, index) {
                          final option = taxiState.rideOptions[index];
                          final isSelected = _selectedRide?.id == option.id;
                          final hasDiscount = taxiState.discountAmount > 0;
                          final finalPrice = hasDiscount ? (option.price - taxiState.discountAmount).clamp(0.0, double.infinity) : option.price;
                          final originalPriceStr = hasDiscount ? '₹${option.price.toStringAsFixed(0)}' : null;
                          
                          // Use user-provided icons with fallback
                          String seats = '4';
                          if (option.id.contains('bike')) {
                            seats = '1';
                          } else if (option.id.contains('auto')) {
                            seats = '3';
                          }

                          return _buildVehicleSelectableItem(
                            option.title,
                            '₹${finalPrice.toStringAsFixed(0)}',
                            seats,
                            option.subtitle,
                            option.assetPath,
                            fallbackIcon: option.icon,
                            badge: option.tag,
                            isSelected: isSelected,
                            originalPriceStr: originalPriceStr,
                            onTap: () {
                              setState(() => _selectedRide = option);
                              ref.read(taxiProvider.notifier).selectOption(option);
                              HapticFeedback.selectionClick();
                            },
                          );
                        },
                      ),
                    ),

                    // Footer Settings (Cash / Coupons / Myself) - Image 3
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() => _paymentMethod = 'Cash');
                              ref.read(taxiProvider.notifier).setPaymentMethod('Cash');
                            },
                            child: _buildFooterOption(
                              Icons.money,
                              'Cash',
                              isSelected: _paymentMethod == 'Cash',
                            ),
                          ),
                          Container(width: 1, height: 20, color: Colors.grey[300]),
                          GestureDetector(
                            onTap: () {
                              _showPromoCodeSheet(context);
                            },
                            child: _buildFooterOption(Icons.local_offer_outlined, 'Coupons'),
                          ),
                          Container(width: 1, height: 20, color: Colors.grey[300]),
                          GestureDetector(
                            onTap: () {
                              setState(() => _paymentMethod = 'Myself');
                              ref.read(taxiProvider.notifier).setPaymentMethod('Online'); // Store as Online in provider
                            },
                            child: _buildFooterOption(
                              Icons.person_outline,
                              'Myself',
                              isSelected: _paymentMethod == 'Myself',
                            ),
                          ),
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
                          onPressed: () async {
                            if (_selectedRide != null) {
                              ref.read(taxiProvider.notifier).selectOption(_selectedRide!);
                              final success = await ref.read(taxiProvider.notifier).startSearching();
                              if (success) {
                                if (context.mounted) await context.push('/taxi/tracking');
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('No ${_selectedRide!.title} drivers are currently available online. Please select another category.'),
                                      backgroundColor: AppColors.dangerRed,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            elevation: 0,
                          ),
                          child: Text(
                            'Book ${_selectedRide?.title ?? 'Any'}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
    String? originalPriceStr,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (originalPriceStr != null)
                  Text(
                    originalPriceStr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: originalPriceStr != null ? Colors.green : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate(target: isSelected ? 1 : 0).shimmer(color: Colors.white24).scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
    );
  }

  Widget _buildFooterOption(IconData icon, String label, {bool isSelected = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: isSelected ? AppColors.primaryBlue : Colors.black87),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: isSelected ? AppColors.primaryBlue : Colors.black87,
          ),
        ),
        const SizedBox(width: 2),
        const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
      ],
    );
  }

  void _showPromoCodeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Apply Promo Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter code here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
