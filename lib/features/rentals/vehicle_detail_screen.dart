// ignore_for_file: deprecated_member_use, unused_import
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../core/providers/favorites_provider.dart';
import '../../core/services/osm_maps_service.dart';
import 'rental_providers.dart';

class RentalVehicleDetailScreen extends ConsumerStatefulWidget {
  const RentalVehicleDetailScreen({super.key});

  @override
  ConsumerState<RentalVehicleDetailScreen> createState() =>
      _RentalVehicleDetailScreenState();
}

class _RentalVehicleDetailScreenState
    extends ConsumerState<RentalVehicleDetailScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  List<Map<String, dynamic>> get _defaultAddressSuggestions {
    return [
      {
        'name': 'Current Location',
        'address': 'Your current location',
        'lat': 12.9716,
        'lng': 77.5946
      },
      {
        'name': 'Old Airport Road',
        'address': 'Old Airport Road, Kodihalli, Bengaluru',
        'lat': 12.9610,
        'lng': 77.6487
      },
      {
        'name': 'MG Road Metro Station',
        'address': 'Mahatma Gandhi Road, Bengaluru',
        'lat': 12.9756,
        'lng': 77.6068
      },
      {
        'name': 'Indiranagar Double Road',
        'address': 'Indiranagar, Stage 2, Bengaluru',
        'lat': 12.9719,
        'lng': 77.6412
      },
      {
        'name': 'Koramangala 4th Block',
        'address': 'Koramangala, St. John\'s Hospital Road, Bengaluru',
        'lat': 12.9352,
        'lng': 77.6245
      },
      {
        'name': 'Whitefield Railway Station',
        'address': 'Kadugodi, Bengaluru',
        'lat': 12.9698,
        'lng': 77.7499
      },
      {
        'name': 'Majestic Bus Station',
        'address': 'Kempegowda Bus Station, Majestic, Bengaluru',
        'lat': 12.9779,
        'lng': 77.5724
      },
      {
        'name': 'Electronic City Phase 1',
        'address': 'Hosur Road, Bengaluru',
        'lat': 12.8497,
        'lng': 77.6749
      },
    ];
  }

  void _showLocationSearchSheet({required bool isPickup}) {
    final searchController = TextEditingController();
    final osmService = OSMMapsService();
    List<Map<String, dynamic>> results = [];
    bool isSearching = false;
    Timer? debounce;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final displayList = results.isEmpty && searchController.text.isEmpty
              ? _defaultAddressSuggestions
              : results;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPickup
                            ? 'Select Pickup Location'
                            : 'Select Drop-off Location',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchController,
                        autofocus: true,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search for a location...',
                          hintStyle: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.normal),
                          prefixIcon: Icon(
                            isPickup
                                ? Icons.trip_origin_rounded
                                : Icons.location_on_rounded,
                            color: isPickup
                                ? AppColors.successGreen
                                : AppColors.brandGreen,
                            size: 20,
                          ),
                          suffixIcon: isSearching
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2)),
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.bgLightGrey,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onChanged: (query) {
                          debounce?.cancel();
                          if (query.length < 2) {
                            setSheetState(() {
                              results = [];
                              isSearching = false;
                            });
                            return;
                          }

                          // Get pickup location as bias if available
                          final pickup = ref.read(rentalPickupLocationProvider);
                          LatLng? biasLoc;
                          if (pickup != null &&
                              pickup['lat'] != null &&
                              pickup['lng'] != null) {
                            biasLoc = LatLng(pickup['lat'], pickup['lng']);
                          }

                          if (query.length == 2) {
                            osmService
                                .searchAddress(query, biasLocation: biasLoc)
                                .then((searchResults) {
                              if (ctx.mounted) {
                                setSheetState(() {
                                  results = searchResults;
                                  isSearching = false;
                                });
                              }
                            });
                            return;
                          }
                          debounce = Timer(const Duration(milliseconds: 500),
                              () async {
                            setSheetState(() => isSearching = true);
                            final searchResults = await osmService
                                .searchAddress(query, biasLocation: biasLoc);
                            if (ctx.mounted) {
                              setSheetState(() {
                                results = searchResults;
                                isSearching = false;
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (displayList.isNotEmpty && searchController.text.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 12, bottom: 4),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'SUGGESTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
                const Divider(height: 1),
                // Results
                Expanded(
                  child: displayList.isEmpty && !isSearching
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.location,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'No locations found',
                                style: TextStyle(
                                    color: Colors.grey.shade400, fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          itemCount: displayList.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, indent: 60),
                          itemBuilder: (context, index) {
                            final loc = displayList[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.bgLightGrey,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Iconsax.location,
                                    color: AppColors.primaryBlue, size: 20),
                              ),
                              title: Text(
                                loc['name'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                loc['address'] ?? '',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                // ignore: unawaited_futures
                                HapticFeedback.lightImpact();
                                if (isPickup) {
                                  ref
                                      .read(
                                          rentalPickupLocationProvider.notifier)
                                      .state = loc;
                                } else {
                                  ref
                                      .read(rentalDropoffLocationProvider
                                          .notifier)
                                      .state = loc;
                                }
                                Navigator.pop(sheetCtx);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      debounce?.cancel();
      searchController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = ref.watch(selectedVehicleProvider);
    final pickupLocation = ref.watch(rentalPickupLocationProvider);
    final dropoffLocation = ref.watch(rentalDropoffLocationProvider);

    // Default placeholder vehicle if none selected
    final displayVehicle = vehicle ??
        {
          'name': 'Maruti Baleno',
          'image_url': 'assets/icons/baleno.png',
          'price': '₹159/hr',
          'rating': '4.9',
          'seats': '5 Seats',
          'type': 'Hatchback',
        };

    final bool isBike = displayVehicle['is_bike'] == true;
    final bool isEV = displayVehicle['type'] == 'EV Bike' ||
        displayVehicle['category'] == 'EV';

    final String description = isBike
        ? 'The ${displayVehicle['name']} is a perfect companion for your daily commutes. Enjoy the freedom of two wheels with this well-maintained ${displayVehicle['type'].toLowerCase()}.'
        : 'The ${displayVehicle['name']} is a premium ${displayVehicle['type'].toLowerCase()} offering a perfect blend of style, comfort, and efficiency. Ideal for city drives and highway cruises.';

    final spec1Icon = isEV ? Icons.electric_bolt_rounded : Iconsax.gas_station;
    final spec1Text = isEV ? 'Electric' : 'Petrol';

    final spec2Icon = isBike ? Icons.speed_rounded : Iconsax.setting_4;
    final spec2Text =
        isBike ? (displayVehicle['spec'] ?? '110cc') : 'Automatic';

    final spec3Icon = isBike ? Icons.pedal_bike_rounded : Iconsax.user;
    final spec3Text = isBike
        ? displayVehicle['type']
        : (displayVehicle['seats'] ?? '5 Seats');

    final List<String> features = isBike
        ? (isEV
            ? [
                'Fast Charging',
                'Tubeless Tyres',
                'Digital Meter',
                'Disc Brakes'
              ]
            : [
                'Helmet Included',
                'Disk Brakes',
                'Tubeless Tyres',
                'Self Start'
              ])
        : [
            'Air Conditioning',
            'Power Windows',
            'Bluetooth',
            'Reverse Camera',
            'ABS'
          ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppColors.textPrimary)),
              onPressed: () => context.pop(),
            ),
            actions: [
              Consumer(builder: (context, ref, _) {
                final vehicleId = displayVehicle['name'].toString();
                final isFav = ref.watch(favoritesProvider).contains(vehicleId);

                return IconButton(
                  icon: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(isFav ? Iconsax.heart5 : Iconsax.heart,
                        size: 20,
                        color: isFav
                            ? AppColors.dangerRed
                            : AppColors.textPrimary),
                  ),
                  onPressed: () {
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(vehicleId);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(isFav
                            ? 'Removed from favorites'
                            : 'Added to favorites!'),
                        behavior: SnackBarBehavior.floating));
                  },
                );
              }),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'vehicle_${displayVehicle['name']}',
                    child: displayVehicle['image_url']
                            .toString()
                            .startsWith('http')
                        ? Image.network(displayVehicle['image_url'],
                            fit: BoxFit.contain)
                        : Image.asset(displayVehicle['image_url'],
                            fit: BoxFit.contain),
                  ),
                  Positioned(
                    bottom: 40,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
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
                    )
                        .animate()
                        .fadeIn(delay: 800.ms)
                        .slideX(begin: 0.5, end: 0),
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
                      Expanded(
                          child: Text(displayVehicle['name'],
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w800))),
                      Text(displayVehicle['price'] ?? '₹159/hr',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryBlue)),
                    ],
                  ).animate().fadeIn().slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Iconsax.star1, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${displayVehicle['rating']} (124 reviews)',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
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
                  const Text('Features',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: features
                        .asMap()
                        .entries
                        .map((entry) => Chip(
                              label: Text(entry.value,
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor: AppColors.bgLightGrey,
                              side: BorderSide.none,
                            )
                                .animate()
                                .fadeIn(delay: (400 + entry.key * 50).ms)
                                .scale())
                        .toList(),
                  ),
                  const SizedBox(height: 32),

                  // ── Pickup & Drop-off Location Section ─────────────────────
                  const Text('Pickup & Drop-off',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Select where you want to pick up and return the vehicle',
                    style:
                        TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgLightGrey,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.border.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        // Pickup tile
                        _buildLocationTile(
                          icon: Icons.trip_origin_rounded,
                          iconColor: AppColors.successGreen,
                          label: 'Pickup Location',
                          value: pickupLocation?['name'] as String?,
                          address: pickupLocation?['address'] as String?,
                          onTap: () => _showLocationSearchSheet(isPickup: true),
                        ),
                        Divider(
                            height: 1,
                            indent: 56,
                            endIndent: 16,
                            color: AppColors.border.withValues(alpha: 0.3)),
                        // Drop-off tile
                        _buildLocationTile(
                          icon: Icons.location_on_rounded,
                          iconColor: AppColors.accentOrange,
                          label: 'Drop-off Location',
                          value: dropoffLocation?['name'] as String?,
                          address: dropoffLocation?['address'] as String?,
                          onTap: () =>
                              _showLocationSearchSheet(isPickup: false),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05, end: 0),
                  const SizedBox(height: 32),

                  if (isEV) ...[
                    const Text('Eco-Friendly Advantage',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.1)),
                      ),
                      child: const Column(
                        children: [
                          _EcoRow(Icons.eco_rounded, 'Zero Carbon Emissions'),
                          SizedBox(height: 12),
                          _EcoRow(Icons.volume_off_rounded,
                              'Silent & Smooth Operation'),
                          SizedBox(height: 12),
                          _EcoRow(Icons.bolt_rounded, 'Fast Charging Support'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 32),
                  ],
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 32),
                  const Text('Pickup Location',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.location_on_rounded,
                                color: AppColors.primaryBlue),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RoAd RoBo\'s EV Hub',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppColors.textPrimary)),
                                SizedBox(height: 4),
                                Text(
                                    'View exact location and get directions on Google Maps.',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.4)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              final url = Uri.parse(
                                  'https://maps.app.goo.gl/mkgcjKXEKmJvUEtv6');
                              if (!await launchUrl(url,
                                  mode: LaunchMode.externalApplication)) {
                                debugPrint('Could not launch EV Hub URL');
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              minimumSize: const Size(0, 40),
                            ),
                            child: const Text('Directions',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 750.ms),
                    const SizedBox(height: 16),
                  ],
                  const LiveMapWidget(height: 200)
                      .animate()
                      .fadeIn(delay: 800.ms)
                      .scale(),
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
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -5))
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Price',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  Text(displayVehicle['price'] ?? '₹159/hr',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    // ignore: unawaited_futures
                    HapticFeedback.mediumImpact();
                    if (isBike || isEV) {
                      final slug = displayVehicle['name']
                          .toString()
                          .toLowerCase()
                          .replaceAll(' ', '-');
                      final url =
                          Uri.parse('https://roadrobos.com/product/$slug');

                      try {
                        if (!await launchUrl(url,
                            mode: LaunchMode.externalApplication)) {
                          await launchUrl(Uri.parse('https://roadrobos.com'),
                              mode: LaunchMode.externalApplication);
                        }
                      } catch (e) {
                        await launchUrl(Uri.parse('https://roadrobos.com'),
                            mode: LaunchMode.externalApplication);
                      }
                    } else {
                      // Validate pickup & drop-off locations before proceeding
                      final pickup = ref.read(rentalPickupLocationProvider);
                      final dropoff = ref.read(rentalDropoffLocationProvider);

                      if (pickup == null || dropoff == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.info_outline_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    pickup == null && dropoff == null
                                        ? 'Please select pickup & drop-off locations'
                                        : pickup == null
                                            ? 'Please select a pickup location'
                                            : 'Please select a drop-off location',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.accentOrange,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                        return;
                      }

                      // Internal booking flow for cars
                      // ignore: unawaited_futures
                      context.push('/rental-checkout');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (isBike || isEV)
                            ? 'Book through the website'
                            : 'Book Now',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                          (isBike || isEV)
                              ? Icons.open_in_new_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: 18),
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

  Widget _buildLocationTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? value,
    String? address,
    required VoidCallback onTap,
  }) {
    final bool hasValue = value != null && value.isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasValue ? value : 'Tap to select location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            hasValue ? FontWeight.w700 : FontWeight.w500,
                        color: hasValue
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (hasValue && address != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        address,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                hasValue
                    ? Icons.check_circle_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: hasValue ? 20 : 14,
                color: hasValue ? AppColors.successGreen : AppColors.textMuted,
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
      decoration: BoxDecoration(
          color: AppColors.bgLightGrey,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 24),
          const SizedBox(height: 8),
          Text(val,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
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
        Text(text,
            style: TextStyle(
                color: Colors.green.shade900,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
