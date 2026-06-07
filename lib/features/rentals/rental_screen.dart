import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../navigation/nav_helpers.dart';
import 'rental_providers.dart';
import 'map_controller.dart';

class RentalScreen extends ConsumerStatefulWidget {
  const RentalScreen({super.key});

  @override
  ConsumerState<RentalScreen> createState() => _RentalScreenState();
}

class _RentalScreenState extends ConsumerState<RentalScreen> {
  late ConfettiController _confettiController;
  final TextEditingController _pickupController = TextEditingController(text: 'My Current Location');
  final TextEditingController _dropController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  bool _isSearching = false;
  final List<Map<String, dynamic>> _recentLocations = [
    {'display_name': 'Koramangala 4th Block, Bengaluru', 'lat': 12.9344, 'lon': 77.6244},
    {'display_name': 'Indiranagar Double Road, Bengaluru', 'lat': 12.9719, 'lon': 77.6412},
    {'display_name': 'MG Road Metro Station, Bengaluru', 'lat': 12.9716, 'lon': 77.5946},
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pickupController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  void _handleBooking() {
    final selectedVehicle = ref.read(selectedVehicleProvider);
    if (selectedVehicle == null) {
      NavHelpers.showSnackAction(context, 'Please select a vehicle first!', icon: Iconsax.info_circle, color: AppColors.accentOrange);
      return;
    }

    _confettiController.play();
    HapticFeedback.mediumImpact();
    
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      NavHelpers.push(context, '/rental-checkout');
    });
  }

  @override
  Widget build(BuildContext context) {
    final rentalType = ref.watch(selectedRentalTypeProvider);
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final totalPrice = ref.watch(rentalPriceProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Full Screen Map
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              showLiveIndicator: false,
            ),
          ),

          // 2. Floating Header with Search Fields
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      borderRadius: 20,
                      opacity: 0.8,
                      child: Column(
                        children: [
                          _buildSearchField(
                            controller: _pickupController,
                            hint: 'Pickup Location',
                            icon: Iconsax.location5,
                            iconColor: AppColors.primaryBlue,
                            onChanged: (val) => _onSearchChanged(val),
                          ),
                          const Divider(height: 1, indent: 40),
                          _buildSearchField(
                            controller: _dropController,
                            hint: 'Where to? (Destination)',
                            icon: Iconsax.search_normal_1,
                            iconColor: AppColors.accentOrange,
                            onChanged: (val) => _onSearchChanged(val),
                          ),
                        ],
                      ),
                    ),
                    if (_showSuggestions && _suggestions.isNotEmpty)
                      _buildSuggestionsOverlay(),
                  ],
                ),
              ],
            ),
          ),

          // 3. Bottom Carousel & Booking Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 20, bottom: 30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(0),
                    Colors.white.withAlpha((0.9 * 255).toInt()),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rental Type Switcher (Hourly/Daily)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildTypeToggle('HOURLY', RentalType.hourly, rentalType),
                        const SizedBox(width: 12),
                        _buildTypeToggle('DAILY', RentalType.daily, rentalType),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Vehicle Carousel
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 180,
                      viewportFraction: 0.75,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        ref.read(selectedVehicleProvider.notifier).state = _vehicles[index];
                      },
                    ),
                    items: _vehicles.map((v) => _buildVehicleCard(v, selectedVehicle == v)).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Booking CTA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: CustomButton(
                      label: selectedVehicle != null 
                        ? 'BOOK ${selectedVehicle['name'].toUpperCase()} ($totalPrice)' 
                        : 'SELECT A VEHICLE',
                      onPressed: _handleBooking,
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              colors: const [Colors.blue, Colors.lightBlue, Colors.white, Colors.orange],
            ),
          ),
          
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: CircleAvatar(
              backgroundColor: Colors.white.withAlpha((0.9 * 255).toInt()),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                onPressed: () => NavHelpers.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color iconColor,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      onTap: () {
        _onSearchChanged(controller.text);
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: iconColor, size: 20),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        suffixIcon: _isSearching ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : null,
      ),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = true;
        _suggestions = [];
      });
      return;
    }

    if (query.length < 2) {
      setState(() {
        _showSuggestions = false;
        _suggestions = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await ref.read(mapControllerProvider.notifier).searchPlaces(query);
    if (!mounted) return;
    
    setState(() {
      _suggestions = results;
      _showSuggestions = true;
      _isSearching = false;
    });
  }

  Widget _buildSuggestionsOverlay() {
    return Positioned(
      top: 110,
      left: 0,
      right: 0,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: 16,
        opacity: 0.95,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_suggestions.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(
                  'RECENT SEARCHES',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 1),
                ),
              ),
              ..._recentLocations.map((loc) => _buildLocationItem(loc)),
            ] else 
              ..._suggestions.map((s) => _buildLocationItem(s)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0);
  }

  Widget _buildLocationItem(Map<String, dynamic> loc) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.bgLightGrey,
            shape: BoxShape.circle,
          ),
          child: const Icon(Iconsax.location, size: 16, color: AppColors.primaryBlue),
        ),
        title: Text(
          loc['display_name'], 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        onTap: () {
          setState(() {
            _dropController.text = loc['display_name'];
            _showSuggestions = false;
          });
          final pos = LatLng(loc['lat'], loc['lon']);
          ref.read(mapControllerProvider.notifier).selectDestination(pos);
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Widget _buildTypeToggle(String label, RentalType type, RentalType current) {
    final active = type == current;
    return GestureDetector(
      onTap: () => ref.read(selectedRentalTypeProvider.notifier).state = type,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primaryBlue : AppColors.border),
          boxShadow: active ? [
            BoxShadow(color: AppColors.primaryBlue.withAlpha((0.3 * 255).toInt()), blurRadius: 10, offset: const Offset(0, 4))
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w800, 
            color: active ? Colors.white : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Map<String, dynamic> vehicle, bool isSelected) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      opacity: isSelected ? 0.95 : 0.7,
      border: isSelected ? Border.all(color: AppColors.primaryBlue, width: 2) : null,
      child: Column(
        children: [
          Expanded(
            child: Image.asset(vehicle['image'], fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            vehicle['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.star5, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                '${vehicle['rating']} • ${vehicle['type']}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            vehicle['price'],
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  final List<Map<String, dynamic>> _vehicles = [
    {
      'name': 'Maruti Baleno',
      'image': 'assets/icons/baleno.png',
      'price': '₹159/hr',
      'rating': '4.9',
      'type': 'Hatchback'
    },
    {
      'name': 'Honda City',
      'image': 'assets/icons/city.png',
      'price': '₹179/hr',
      'rating': '4.9',
      'type': 'Sedan'
    },
    {
      'name': 'Maruti Swift',
      'image': 'assets/icons/swift.png',
      'price': '₹129/hr',
      'rating': '4.8',
      'type': 'Hatchback'
    },
    {
      'name': 'Mahindra Scorpio',
      'image': 'assets/icons/scorpio.png',
      'price': '₹219/hr',
      'rating': '4.7',
      'type': 'SUV'
    },
    {
      'name': 'Hyundai Creta',
      'image': 'assets/icons/creta.png',
      'price': '₹199/hr',
      'rating': '4.9',
      'type': 'SUV'
    },
    {
      'name': 'Maruti Dzire',
      'image': 'assets/icons/dzire.png',
      'price': '₹149/hr',
      'rating': '4.8',
      'type': 'Sedan'
    },
  ];
}
