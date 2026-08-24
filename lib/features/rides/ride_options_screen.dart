import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../shared/widgets/sos_button.dart';
import '../../providers/taxi_provider.dart';
import '../profile/sos_provider.dart';
import '../profile/user_provider.dart';

class RideOptionsScreen extends ConsumerStatefulWidget {
  const RideOptionsScreen({super.key});

  @override
  ConsumerState<RideOptionsScreen> createState() => _RideOptionsScreenState();
}

class _RideOptionsScreenState extends ConsumerState<RideOptionsScreen>
    with TickerProviderStateMixin {
  // Local UI-only state — provider is the single source of truth for selection
  bool _isBooking = false;
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final options = ref.read(taxiProvider).rideOptions;
      if (options.isNotEmpty && mounted) {
        // Select first option via provider — no local state duplication
        ref.read(taxiProvider.notifier).selectOption(options.first);
      }

      // Auto-slide up sheet after landing
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_sheetController.isAttached && mounted) {
          _sheetController.animateTo(
            0.88,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          );
        }
      });
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

          // 2. Floating Top Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            child: Semantics(
              label: 'Go back',
              button: true,
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      size: 20, color: Color(0xFF0F172A)),
                ),
              ),
            ),
          ),

          // 2b. Karnataka MoRTH / BTP Safety SOS Header Pill
          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            right: 16,
            child: SOSButton.headerPill(
              rideDetails:
                  'Reviewing Options: ${taxiState.pickupAddress ?? "Pickup"} → ${taxiState.dropoffAddress ?? "Dropoff"}',
              onTrigger: () {
                final userId = ref.read(userProvider).user?.id ?? 'demo';
                ref.read(sosProvider.notifier).triggerEmergency(userId);
              },
            ),
          ),

          // 3. Draggable React-Style Bottom Sheet
          Builder(
            builder: (context) {
              final screenHeight = MediaQuery.of(context).size.height;
              final double initialSize = screenHeight < 850 ? 0.65 : 0.58;
              final double minSize = screenHeight < 850 ? 0.50 : 0.45;

              return DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: initialSize,
                minChildSize: minSize,
                maxChildSize: 0.92,
                snap: true,
                snapSizes: [minSize, 0.92],
                builder: (context, scrollController) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A0F172A),
                          blurRadius: 28,
                          offset: Offset(0, -6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag Handle
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 12),
                            width: 42,
                            height: 4.5,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),

                        // Title: Plan Your Ride
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Plan Your Ride',
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),

                        // Interconnected Route Card
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Pickup Row
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF22C55E),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              taxiState.pickupAddress ??
                                                  'Pickup Location',
                                              style: GoogleFonts.inter(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF0F172A),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 3, top: 3, bottom: 3),
                                        child: Container(
                                          width: 2,
                                          height: 10,
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      // Destination Row
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFEF4444),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              taxiState.dropoffAddress ??
                                                  'Destination',
                                              style: GoogleFonts.inter(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF0F172A),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    context.push('/taxi/search-location',
                                        extra: {'focusPickup': false});
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: const Icon(Iconsax.edit_2,
                                        size: 15, color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Vehicle Options List
                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 4),
                            itemCount: taxiState.rideOptions.length,
                            itemBuilder: (context, index) {
                              final option = taxiState.rideOptions[index];
                              final isSelected =
                                  taxiState.selectedOption?.id == option.id;
                              final hasDiscount =
                                  isSelected && taxiState.discountAmount > 0;
                              final finalPrice = hasDiscount
                                  ? (option.price - taxiState.discountAmount)
                                      .clamp(0.0, double.infinity)
                                  : option.price;
                              final originalPriceStr = hasDiscount
                                  ? '₹${option.price.toStringAsFixed(0)}'
                                  : null;

                              return _buildVehicleCard(
                                option: option,
                                finalPrice: finalPrice,
                                originalPriceStr: originalPriceStr,
                                isSelected: isSelected,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  ref
                                      .read(taxiProvider.notifier)
                                      .selectOption(option);
                                },
                              );
                            },
                          ),
                        ),

                        // Payment Method Segmented Toggle
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                // Cash on Drop
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      ref
                                          .read(taxiProvider.notifier)
                                          .setPaymentMethod('Cash');
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: taxiState.paymentMethod == 'Cash'
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: taxiState.paymentMethod ==
                                                'Cash'
                                            ? Border.all(
                                                color: const Color(0xFFE2E8F0))
                                            : null,
                                        boxShadow: taxiState.paymentMethod ==
                                                'Cash'
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.04),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.payments_outlined,
                                            size: 18,
                                            color: taxiState.paymentMethod ==
                                                    'Cash'
                                                ? const Color(0xFF059669)
                                                : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Cash on Drop',
                                            style: GoogleFonts.inter(
                                              fontSize: 12.5,
                                              fontWeight:
                                                  taxiState.paymentMethod ==
                                                          'Cash'
                                                      ? FontWeight.w800
                                                      : FontWeight.w600,
                                              color: taxiState.paymentMethod ==
                                                      'Cash'
                                                  ? const Color(0xFF0F172A)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Pay Online
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      ref
                                          .read(taxiProvider.notifier)
                                          .setPaymentMethod('Online');
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color:
                                            taxiState.paymentMethod == 'Online'
                                                ? Colors.white
                                                : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        border: taxiState.paymentMethod ==
                                                'Online'
                                            ? Border.all(
                                                color: const Color(0xFFE2E8F0))
                                            : null,
                                        boxShadow: taxiState.paymentMethod ==
                                                'Online'
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.04),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.credit_card_outlined,
                                            size: 18,
                                            color: taxiState.paymentMethod ==
                                                    'Online'
                                                ? const Color(0xFF006241)
                                                : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Pay Online',
                                            style: GoogleFonts.inter(
                                              fontSize: 12.5,
                                              fontWeight:
                                                  taxiState.paymentMethod ==
                                                          'Online'
                                                      ? FontWeight.w800
                                                      : FontWeight.w600,
                                              color: taxiState.paymentMethod ==
                                                      'Online'
                                                  ? const Color(0xFF0F172A)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Primary CTA: Book Button
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 4, 20,
                              16 + MediaQuery.of(context).padding.bottom),
                          child: GestureDetector(
                            onTap: _isBooking
                                ? null
                                : () => _handleBookRide(taxiState),
                            child: Container(
                              height: 54,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF006241),
                                    Color(0xFF10B981)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF006241)
                                        .withValues(alpha: 0.28),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isBooking
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        'Book ${taxiState.selectedOption?.title ?? 'Ride'}',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildVehicleCard({
    required RideOption option,
    required double finalPrice,
    required String? originalPriceStr,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    IconData getVehicleIcon(String id) {
      if (id.contains('bike')) {
        return Icons.two_wheeler_rounded;
      } else if (id.contains('auto')) {
        return Icons.electric_rickshaw_rounded;
      }
      return Iconsax.car;
    }

    Widget? getTagBadge(String? tag) {
      if (tag == null || tag.isEmpty) return null;
      Color bgColor;
      Color textColor;
      Color borderColor;

      if (tag == 'Cheapest') {
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        borderColor = const Color(0xFFBFDBFE);
      } else if (tag == 'Eco') {
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        borderColor = const Color(0xFFA7F3D0);
      } else if (tag == 'Quickest') {
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFD97706);
        borderColor = const Color(0xFFFDE68A);
      } else {
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        borderColor = const Color(0xFFE2E8F0);
      }

      return Container(
        margin: const EdgeInsets.only(left: 6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor, width: 0.8),
        ),
        child: Text(
          tag,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF006241) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF006241).withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Left Squircle Vehicle Icon (48x48)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Icon(
                  getVehicleIcon(option.id),
                  color: isSelected
                      ? const Color(0xFF006241)
                      : const Color(0xFF475569),
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Middle Column: Title, Badge, Subtitle ETA
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        option.title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (getTagBadge(option.tag) != null)
                        getTagBadge(option.tag)!,
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle.isNotEmpty
                        ? option.subtitle
                        : '2 min away • Drop nearby',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Right Column: Price Tag
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (originalPriceStr != null)
                  Text(
                    originalPriceStr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  '₹${finalPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleBookRide(TaxiState taxiState) async {
    final selectedOption = taxiState.selectedOption;
    if (selectedOption == null) return;

    await HapticFeedback.mediumImpact();
    setState(() => _isBooking = true);

    try {
      ref.read(taxiProvider.notifier).selectOption(selectedOption);
      final success = await ref.read(taxiProvider.notifier).startSearching();
      if (success) {
        if (mounted) {
          context.go('/taxi/tracking');
        }
      } else {
        if (mounted) {
          _showNoDriversDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.dangerRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }

  void _showNoDriversDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.location_off_rounded, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No Drivers Nearby',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          'All drivers in your area are currently offline. You can still book and wait — we\'ll keep searching for 10 minutes and notify you when a driver accepts.',
          style: GoogleFonts.inter(fontSize: 13.5, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                  color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/taxi/tracking');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006241),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Book Anyway',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
