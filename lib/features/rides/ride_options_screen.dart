import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import 'taxi_provider.dart';

class RideOptionsScreen extends ConsumerStatefulWidget {
  const RideOptionsScreen({super.key});

  @override
  ConsumerState<RideOptionsScreen> createState() => _RideOptionsScreenState();
}

class _RideOptionsScreenState extends ConsumerState<RideOptionsScreen> {
  SelectedRide? _selectedRide;

  @override
  void initState() {
    super.initState();
    // Default selection
    _selectedRide = SelectedRide(
      name: 'Auto',
      price: '₹247',
      eta: '2 min away • Drop 1:11 pm',
      icon: 'https://img.icons8.com/color/150/rickshaw.png',
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

          // 3. Vehicles Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildVehiclesSheet(context, taxiState)
                .animate()
                .slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),
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
              _buildAddressPill(context, state.pickupAddress ?? 'Pick-up', isPickup: true),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: _buildAddressPill(context, state.dropoffAddress ?? 'Destination', isPickup: false),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressPill(BuildContext context, String address, {bool isPickup = true}) {
    return GestureDetector(
      onTap: () => context.pop(), // Go back to edit
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

  Widget _buildVehiclesSheet(BuildContext context, TaxiState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
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

          // Scrollable Vehicle List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildVehicleSelectableItem('Auto', '₹247', '3', '2 min away • Drop 1:11 pm', 'https://img.icons8.com/color/150/rickshaw.png'),
                _buildVehicleSelectableItem('Auto Priority', '₹314', '3', '2 min away • Drop 1:11 pm', 'https://img.icons8.com/color/150/rickshaw.png', isPriority: true),
                _buildVehicleSelectableItem('Cab Non AC', '₹237', '4', '2 min away • Drop 1:11 pm', 'https://img.icons8.com/color/150/car.png'),
                _buildVehicleSelectableItem('Cab Priority', '₹298', '4', '2 min away • Drop 1:11 pm', 'https://img.icons8.com/color/150/car.png', badge: 'Quickest'),
                _buildVehicleSelectableItem('Cab AC', '₹270', '4', '2 min away • Drop 1:11 pm', 'https://img.icons8.com/color/150/luxury-car.png'),
              ],
            ),
          ),

          // Footer Settings (Cash / Offers)
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(child: _buildFooterOption(Icons.wallet, 'Cash')),
                Container(width: 1, height: 24, color: Colors.grey[200]),
                Expanded(child: _buildFooterOption(Icons.local_offer, 'Offers')),
              ],
            ),
          ),

          // Book Button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
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
                    ref.read(taxiProvider.notifier).selectRide(_selectedRide!);
                    ref.read(taxiProvider.notifier).updateStatus(RideStatus.searching);
                    context.push('/taxi/tracking');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
  }

  Widget _buildVehicleSelectableItem(String name, String price, String seats, String eta, String iconUrl, {bool isPriority = false, String? badge}) {
    final isSelected = _selectedRide?.name == name;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRide = SelectedRide(name: name, price: price, eta: eta, icon: iconUrl);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon with priority badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.network(iconUrl, width: 44, height: 44, errorBuilder: (_, __, ___) => const Icon(Icons.local_taxi, size: 40)),
                if (isPriority)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
                      child: const Icon(Icons.bolt, color: Colors.yellow, size: 12),
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
      ),
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
