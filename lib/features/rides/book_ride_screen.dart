import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../shared/widgets/sos_button.dart';
import '../../navigation/nav_helpers.dart';
import '../../providers/taxi_provider.dart';
import '../profile/sos_provider.dart';
import '../profile/user_provider.dart';
import 'schedule_ride_screen.dart';

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
          // 1. Background Map
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

          // 3. Draggable Bottom Sheet
          Builder(
            builder: (context) {
              final screenHeight = MediaQuery.of(context).size.height;
              final double initialSize = screenHeight < 850 ? 0.60 : 0.48;
              final double minSize = screenHeight < 850 ? 0.50 : 0.45;

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
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, -6),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Drag handle
                          Center(
                            child: Container(
                              width: 44,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Plan Your Ride',
                            style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                                letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Where would you like to travel today?',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),

                          // Interconnected Route Card
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                // Pickup Location
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/taxi/search-location',
                                        extra: {'focusPickup': true});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: taxiState.isLoadingLocation
                                                ? const SizedBox(
                                                    width: 14,
                                                    height: 14,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Color(0xFF10B981),
                                                    ),
                                                  )
                                                : const Icon(
                                                    Iconsax.record_circle,
                                                    size: 16,
                                                    color: Color(0xFF10B981),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            taxiState.isLoadingLocation
                                                ? 'Detecting GPS location...'
                                                : (taxiState.pickupAddress ??
                                                    'Set pickup location'),
                                            style: GoogleFonts.inter(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Iconsax.edit_2,
                                            size: 14, color: Color(0xFF94A3B8)),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Destination Location
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/taxi/search-location',
                                        extra: {'focusPickup': false});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF2F2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Iconsax.location5,
                                            size: 16,
                                            color: Color(0xFFEF4444),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            taxiState.dropoffAddress ??
                                                'Where to?',
                                            style: GoogleFonts.inter(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                              color: taxiState.dropoffAddress ==
                                                      null
                                                  ? const Color(0xFF94A3B8)
                                                  : const Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Iconsax.search_normal_1,
                                            size: 14, color: Color(0xFF94A3B8)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Primary CTA Button
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              if (taxiState.dropoffLocation == null) {
                                context.push('/taxi/search-location',
                                    extra: {'focusPickup': false});
                              } else {
                                context.push('/taxi/ride-options');
                              }
                            },
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF006241),
                                    Color(0xFF10B981)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF006241)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Iconsax.routing,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    taxiState.dropoffLocation != null
                                        ? 'VIEW RIDE OPTIONS'
                                        : 'SELECT DESTINATION',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Secondary CTA — Schedule for Later
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ScheduleRideScreen(
                                    pickupAddress: taxiState.pickupAddress,
                                    dropoffAddress: taxiState.dropoffAddress,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Iconsax.calendar_1,
                                      size: 16, color: Color(0xFF475569)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SCHEDULE FOR LATER',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF475569),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
              const Spacer(),
              SOSButton.headerPill(
                rideDetails:
                    'Planning Ride from ${state.pickupAddress ?? "Current Location"}',
                onTrigger: () {
                  final userId = ref.read(userProvider).user?.id ?? 'demo';
                  ref.read(sosProvider.notifier).triggerEmergency(userId);
                },
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
