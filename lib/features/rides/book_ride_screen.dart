import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../navigation/nav_helpers.dart';
import '../../providers/taxi_provider.dart';

class BookRideScreen extends ConsumerStatefulWidget {
  const BookRideScreen({super.key});

  @override
  ConsumerState<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends ConsumerState<BookRideScreen> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taxiProvider.notifier).initializeLocation();
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Map
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              showLiveIndicator: false,
            ),
          ),

          // 2. Floating Header & Pickup Pill
          _buildFloatingHeader(context, taxiState),

          // 3. Draggable Quick Sheet
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: 0.38,
            minChildSize: 0.38,
            maxChildSize: 0.7,
            snap: true,
            snapSizes: const [0.38, 0.7],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 36, height: 4,
                            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                          ),
                          _buildSearchTrigger(context),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildRecentList()),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader(BuildContext context, TaxiState state) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16, right: 16,
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => NavHelpers.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
          GestureDetector(
            onTap: () => context.push('/taxi/search-location', extra: {'focusPickup': true}),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x6622C55E), blurRadius: 8, spreadRadius: 2),
                      ],
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                   .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1000.ms)
                   .boxShadow(begin: const BoxShadow(color: Color(0x3322C55E), blurRadius: 4), end: const BoxShadow(color: Color(0x8822C55E), blurRadius: 12), duration: 1000.ms),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      state.pickupAddress ?? 'Detecting Location...',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().scale(),
        ],
      ),
    );
  }

  Widget _buildSearchTrigger(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/taxi/search-location', extra: {'focusPickup': false}),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Iconsax.search_normal, size: 20, color: Colors.black54),
            SizedBox(width: 12),
            Text(
              'Where do you want to go?',
              style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentList() {
    final mockLocations = ref.read(taxiProvider).mockLocations;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Locations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF374151))),
          const SizedBox(height: 16),
          ...mockLocations.take(3).map((loc) => _buildRecommendedItem(loc)),
        ],
      ),
    );
  }

  Widget _buildRecommendedItem(Map<String, dynamic> loc) {
     final String title = loc['name']!;
     final String subtitle = loc['address']!;
     final String distance = loc['distance']!;

     return Material(
       color: Colors.transparent,
       child: InkWell(
         onTap: () {
           final lat = loc['lat'] as double;
           final lng = loc['lng'] as double;
           final latLng = LatLng(lat, lng);
           
           ref.read(taxiProvider.notifier).setDropoff(latLng, title);
           context.push('/taxi/ride-options');
         },
         borderRadius: BorderRadius.circular(16),
         child: Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: const Color(0xFFF9FAFB),
             borderRadius: BorderRadius.circular(16),
           ),
           child: Row(
             children: [
               const Icon(Iconsax.location, color: Colors.black45, size: 20),
               const SizedBox(width: 16),
               Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                     Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 11)),
                   ],
                 ),
               ),
               Text(distance, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: Colors.black38)),
             ],
           ),
         ),
       ),
     );
  }
}
