import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../navigation/nav_helpers.dart';
import '../../providers/taxi_provider.dart';

class BookRideScreen extends ConsumerStatefulWidget {
  const BookRideScreen({super.key});

  @override
  ConsumerState<BookRideScreen> createState() => _BookRideScreenState();
}

class _BookRideScreenState extends ConsumerState<BookRideScreen> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

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
          // 1. Background Map — wrapped in RepaintBoundary to prevent
          //    map tile repaints when the bottom sheet is dragging.
          Positioned.fill(
            child: RepaintBoundary(
              child: LiveMapWidget(
                height: MediaQuery.of(context).size.height,
                showLiveIndicator: false,
              ),
            ),
          ),

          // 2. Floating Header & Pickup Pill
          _buildFloatingHeader(context, taxiState),

          // 3. Draggable Bottom Sheet — snap points feel natural
          Builder(
            builder: (context) {
              final screenHeight = MediaQuery.of(context).size.height;
              final double initialSize = screenHeight < 850 ? 0.58 : 0.45;
              final double minSize = screenHeight < 850 ? 0.48 : 0.45;
              
              return DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: initialSize,
                minChildSize: minSize,
                maxChildSize: 0.9,
                snapSizes: [minSize, 0.75, 0.9],
                snap: true,
                builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Plan Your Ride',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 20),

                      // Pickup Location
                      const Text(
                        'Pickup Location',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: 'Set pickup location',
                        button: true,
                        child: GestureDetector(
                          onTap: () => context.push('/taxi/search-location',
                              extra: {'focusPickup': true}),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                // Show spinner while GPS is detecting
                                if (taxiState.isLoadingLocation)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.green,
                                    ),
                                  )
                                else
                                  const Icon(Icons.circle_outlined,
                                      size: 16, color: Colors.green),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(
                                  taxiState.isLoadingLocation
                                      ? 'Detecting your location...'
                                      : (taxiState.pickupAddress ??
                                          'Set pickup location'),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Destination
                      const Text(
                        'Destination',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Semantics(
                        label: 'Set destination',
                        button: true,
                        child: GestureDetector(
                          onTap: () => context.push('/taxi/search-location',
                              extra: {'focusPickup': false}),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    taxiState.dropoffAddress ?? 'Where to?',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: taxiState.dropoffAddress == null
                                            ? Colors.black45
                                            : Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // CTA Button — label reflects what happens next
                      Semantics(
                        label: taxiState.dropoffLocation != null
                            ? 'View ride options'
                            : 'Select destination',
                        button: true,
                        child: ElevatedButton(
                          onPressed: () {
                            if (taxiState.dropoffLocation == null) {
                              context.push('/taxi/search-location',
                                  extra: {'focusPickup': false});
                            } else {
                              context.push('/taxi/ride-options');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            elevation: 0,
                          ),
                          child: Text(
                            // Contextual label: changes once destination is set
                            taxiState.dropoffLocation != null
                                ? 'VIEW RIDE OPTIONS'
                                : 'SELECT DESTINATION',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              );
            },
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
      left: 16,
      right: 16,
      child: Column(
        children: [
          Row(
            children: [
              Semantics(
                label: 'Go back',
                button: true,
                child: GestureDetector(
                  onTap: () => NavHelpers.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 8)
                        ]),
                    child: const Icon(Icons.arrow_back_rounded,
                        size: 20, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 100),
          // Pickup pill — only show when not loading and location known
          if (!state.isLoadingLocation && state.pickupAddress != null)
            GestureDetector(
              onTap: () => context
                  .push('/taxi/search-location', extra: {'focusPickup': true}),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15)
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Color(0x6622C55E),
                              blurRadius: 8,
                              spreadRadius: 2),
                        ],
                      ),
                    )
                        .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true))
                        .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                            duration: 1000.ms)
                        .boxShadow(
                            begin: const BoxShadow(
                                color: Color(0x3322C55E), blurRadius: 4),
                            end: const BoxShadow(
                                color: Color(0x8822C55E), blurRadius: 12),
                            duration: 1000.ms),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        state.pickupAddress!,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}
