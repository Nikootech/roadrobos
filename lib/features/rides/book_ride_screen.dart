import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../navigation/nav_helpers.dart';
import 'taxi_provider.dart';

class BookRideScreen extends ConsumerStatefulWidget {
  const BookRideScreen({super.key});

  @override
  ConsumerState<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends ConsumerState<BookRideScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. OSM Map Base
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              showLiveIndicator: false,
            ),
          ),

          // 2. Top Location Pill (Rapido Style)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: _buildTopLocationIndicator(taxiState.pickupAddress ?? 'Current Location'),
          ),

          // 3. Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.35,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: _buildSearchBar(context),
                    ),

                    // Recent Locations List
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        itemCount: _recentLocations.length,
                        itemBuilder: (context, index) {
                          final loc = _recentLocations[index];
                          return _buildLocationItem(context, ref, loc);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // 4. Back Button (Left top)
          Positioned(
             top: MediaQuery.of(context).padding.top + 16,
             left: 24,
             child: InkWell(
               onTap: () => NavHelpers.pop(context),
               child: Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: Colors.white.withValues(alpha: 0.9),
                   shape: BoxShape.circle,
                   boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                 ),
                 child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.primaryNavy),
               ),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopLocationIndicator(String address) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Refocus search to change pickup
            _searchController.clear();
            ref.read(taxiProvider.notifier).setPickup(const LatLng(12.9716, 77.5946), 'Current Location');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '80', // As per screenshot
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primaryNavy),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Arrow/Dot connector
        Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            color: AppColors.successGreen,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 3)),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.bgSkyLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.black87, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Where do you want to go?',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryNavy,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryNavy,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    ref.read(taxiProvider.notifier).setDropoff(
                          const LatLng(12.9716, 77.5946), // Mock coordinates
                          value,
                        );
                    context.push('/taxi/ride-options');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationItem(BuildContext context, WidgetRef ref, Map<String, String> loc) {
    return InkWell(
      onTap: () {
        final lat = double.parse(loc['lat']!);
        final lng = double.parse(loc['lng']!);
        ref.read(taxiProvider.notifier).setDropoff(
              LatLng(lat, lng),
              loc['title']!,
            );
        context.push('/taxi/ride-options');
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Column(
                  children: [
                    const Icon(Iconsax.clock, color: Colors.grey, size: 22),
                    const SizedBox(height: 4),
                    Text(
                      loc['distance']!,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc['title']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc['address']!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(Iconsax.heart, color: Colors.grey, size: 22),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(height: 1, color: Colors.grey[200], thickness: 1),
          ),
        ],
      ),
    );
  }

  static const List<Map<String, String>> _recentLocations = [
    {
      'title': '5th Main, 7, 17th Cross Rd, Sector...',
      'address': '5th Main, 7, 17th Cross Rd, Sector 6, HSR...',
      'distance': '2 km',
      'lat': '12.9121',
      'lng': '77.6445',
    },
    {
      'title': '155, 155, Outer Ring Rd, Sector 4,...',
      'address': '155, 155, Outer Ring Rd, Sector 4, HSR La...',
      'distance': '2.2 km',
      'lat': '12.9141',
      'lng': '77.6465',
    },
    {
      'title': 'Indiranagar Police Station, Old Mad...',
      'address': 'Indiranagar Police Station, Old Madras Ro...',
      'distance': '9.3 km',
      'lat': '12.9784',
      'lng': '77.6408',
    },
  ];
}
