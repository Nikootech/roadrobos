import 'dart:async';
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
            0.85,
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

          // 2. Floating Header with Back Button and Route Info Card
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Back Button
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Route Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 8, color: Colors.green),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                taxiState.pickupAddress ?? 'Pickup Location',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 3, top: 2, bottom: 2),
                          child: Container(
                            width: 2,
                            height: 6,
                            color: Colors.black12,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 10, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                taxiState.dropoffAddress ?? 'Destination',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Builder(
            builder: (context) {
              final screenHeight = MediaQuery.of(context).size.height;
              final double initialSize = screenHeight < 850 ? 0.58 : 0.45;
              final double minSize = screenHeight < 850 ? 0.48 : 0.4;
              
              return DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: initialSize,
                minChildSize: minSize,
                maxChildSize: 0.85,
                snap: true,
                snapSizes: [minSize, 0.85],
                builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),

                    // Title and Distance (Image 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Suggested rides',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w900)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              '${taxiState.distance.toStringAsFixed(1)}km • ${taxiState.eta ?? '15 min'}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700),
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
                          // Provider is the single source of truth for selection
                          final isSelected =
                              taxiState.selectedOption?.id == option.id;
                          // Only show discount on the selected option
                          final hasDiscount =
                              isSelected && taxiState.discountAmount > 0;
                          final finalPrice = hasDiscount
                              ? (option.price - taxiState.discountAmount)
                                  .clamp(0.0, double.infinity)
                              : option.price;
                          final originalPriceStr = hasDiscount
                              ? '\u20B9${option.price.toStringAsFixed(0)}'
                              : null;

                          // Use user-provided icons with fallback
                          String seats = '4';
                          if (option.id.contains('bike')) {
                            seats = '1';
                          } else if (option.id.contains('auto')) {
                            seats = '3';
                          }

                          return _buildVehicleSelectableItem(
                            option.title,
                            '\u20B9${finalPrice.toStringAsFixed(0)}',
                            seats,
                            option.subtitle,
                            option.assetPath,
                            fallbackIcon: option.icon,
                            badge: option.tag,
                            isSelected: isSelected,
                            originalPriceStr: originalPriceStr,
                            onTap: () {
                              // Update provider — no local setState for selection
                              ref
                                  .read(taxiProvider.notifier)
                                  .selectOption(option);
                              HapticFeedback.selectionClick();
                              if (_sheetController.isAttached) {
                                _sheetController.animateTo(
                                  0.85,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),

                    // Footer — Payment Method Selection
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Cash on Drop button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(taxiProvider.notifier)
                                        .setPaymentMethod('Cash');
                                    HapticFeedback.selectionClick();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                      color: taxiState.paymentMethod == 'Cash'
                                          ? Colors.orange.shade50
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: taxiState.paymentMethod == 'Cash'
                                            ? Colors.orange.shade400
                                            : Colors.grey.shade200,
                                        width: taxiState.paymentMethod == 'Cash' ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.money_rounded,
                                          color: taxiState.paymentMethod == 'Cash'
                                              ? Colors.orange.shade700
                                              : Colors.grey,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Cash on Drop',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: taxiState.paymentMethod == 'Cash'
                                                ? Colors.orange.shade700
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        if (taxiState.paymentMethod == 'Cash')
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 4),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade400,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Text('Selected',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Pay Online (Razorpay) button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(taxiProvider.notifier)
                                        .setPaymentMethod('Online');
                                    HapticFeedback.selectionClick();
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    decoration: BoxDecoration(
                                      color: taxiState.paymentMethod == 'Online'
                                          ? AppColors.primaryBlue
                                              .withValues(alpha: 0.06)
                                          : Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: taxiState.paymentMethod == 'Online'
                                            ? AppColors.primaryBlue
                                            : Colors.grey.shade200,
                                        width:
                                            taxiState.paymentMethod == 'Online' ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.payment_rounded,
                                          color: taxiState.paymentMethod == 'Online'
                                              ? AppColors.primaryBlue
                                              : Colors.grey,
                                          size: 28,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Pay Online',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: taxiState.paymentMethod == 'Online'
                                                ? AppColors.primaryBlue
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: taxiState.paymentMethod == 'Online'
                                              ? Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.primaryBlue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Text('Selected',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                )
                                              : Text('via Razorpay',
                                                  style: TextStyle(
                                                      color:
                                                          Colors.grey.shade400,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Promo / coupons row
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => _showPromoCodeSheet(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.local_offer_outlined,
                                      size: 18, color: Color(0xFF6366F1)),
                                  const SizedBox(width: 10),
                                  const Text('Apply Promo Code',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                  const Spacer(),
                                  Icon(Icons.chevron_right_rounded,
                                      color: Colors.grey.shade400),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Book Button
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                          20, 0, 20, 20 + MediaQuery.of(context).padding.bottom),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isBooking
                              ? null
                              : () async {
                                  // Guard: need a selected option
                                  final selectedOption =
                                      taxiState.selectedOption;
                                  if (selectedOption == null) return;
                                  setState(() => _isBooking = true);
                                  try {
                                    ref
                                        .read(taxiProvider.notifier)
                                        .selectOption(selectedOption);
                                    final success = await ref
                                        .read(taxiProvider.notifier)
                                        .startSearching();
                                    if (success) {
                                      if (context.mounted) {
                                        // Navigate to live tracking screen
                                        // (not home — user needs to see driver search)
                                        context.go('/taxi/tracking');
                                      }
                                    } else {
                                      if (context.mounted) {
                                        unawaited(showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(24)),
                                            title: const Row(children: [
                                              Icon(Icons.location_off_rounded,
                                                  color: Colors.orange),
                                              SizedBox(width: 12),
                                              Expanded(
                                                  child: Text(
                                                      'No Drivers Nearby',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 18))),
                                            ]),
                                            content: const Text(
                                              'All drivers in your area are currently offline. You can still book and wait — we\'ll keep searching for 10 minutes and notify you when a driver accepts.',
                                              style: TextStyle(
                                                  fontSize: 14, height: 1.6),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('Cancel',
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  final date =
                                                      await showDatePicker(
                                                    context: ctx,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.now()
                                                        .add(const Duration(
                                                            days: 7)),
                                                  );
                                                  if (date != null &&
                                                      ctx.mounted) {
                                                    final time =
                                                        await showTimePicker(
                                                      context: ctx,
                                                      initialTime:
                                                          TimeOfDay.now(),
                                                    );
                                                    if (time != null &&
                                                        ctx.mounted) {
                                                      final scheduledTime =
                                                          DateTime(
                                                              date.year,
                                                              date.month,
                                                              date.day,
                                                              time.hour,
                                                              time.minute);
                                                      try {
                                                        await ref
                                                            .read(taxiProvider
                                                                .notifier)
                                                            .scheduleRideForLater(
                                                                scheduledTime);
                                                        if (ctx.mounted) {
                                                          Navigator.pop(
                                                              ctx); // close dialog
                                                          context.go(
                                                              '/main/home'); // Go to home screen
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              content: Text(
                                                                  'Ride scheduled for ${time.format(context)} on ${date.day}/${date.month}'),
                                                              backgroundColor:
                                                                  Colors.green,
                                                            ),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        if (ctx.mounted) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                                content: Text(e
                                                                    .toString()),
                                                                backgroundColor:
                                                                    AppColors
                                                                        .dangerRed),
                                                          );
                                                        }
                                                      }
                                                    }
                                                  }
                                                },
                                                child: const Text('Schedule',
                                                    style: TextStyle(
                                                        color: AppColors
                                                            .primaryBlue,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  // Navigate to live tracking — user is still searching
                                                  context.go('/taxi/tracking');
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      AppColors.primaryBlue,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12)),
                                                ),
                                                child:
                                                    const Text('Book Anyway'),
                                              ),
                                            ],
                                          ),
                                        ));
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(e
                                              .toString()
                                              .replaceAll('Exception: ', '')),
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
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32)),
                            elevation: 0,
                          ),
                          child: _isBooking
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 3),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      taxiState.paymentMethod == 'Online'
                                          ? Icons.payment_rounded
                                          : Icons.money_rounded,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      taxiState.paymentMethod == 'Online'
                                          ? 'Pay & Book ${taxiState.selectedOption?.title ?? ''}'
                                          : 'Book ${taxiState.selectedOption?.title ?? 'Any'}',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5),
                                    ),
                                  ],
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


  Widget _buildVehicleSelectableItem(
      String name, String price, String seats, String eta, String? imagePath,
      {IconData? fallbackIcon,
      String? badge,
      String? originalPriceStr,
      bool isSelected = false,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue.withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : Colors.black.withValues(alpha: 0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ]
              : null,
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
                    color: isSelected
                        ? AppColors.primaryBlue.withValues(alpha: 0.1)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: imagePath != null
                        ? (imagePath.startsWith('http')
                            ? Image.network(imagePath,
                                width: 44,
                                height: 44,
                                errorBuilder: (_, __, ___) => Icon(
                                    fallbackIcon ?? Icons.local_taxi,
                                    size: 32,
                                    color: Colors.black45))
                            : Image.asset(imagePath,
                                width: 44,
                                height: 44,
                                errorBuilder: (_, __, ___) => Icon(
                                    fallbackIcon ?? Icons.local_taxi,
                                    size: 32,
                                    color: Colors.black45)))
                        : Icon(fallbackIcon ?? Icons.local_taxi,
                            size: 32,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.black45),
                  ),
                ),
                if (badge != null)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badge == 'Quickest'
                            ? AppColors.dangerRed
                            : AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4)
                        ],
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800),
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
                      Text(name,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 8),
                      Icon(Icons.person, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Text(seats,
                          style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                  Text(eta,
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
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
                    color:
                        originalPriceStr != null ? Colors.green : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      )
          .animate(target: isSelected ? 1 : 0)
          .shimmer(color: Colors.white24)
          .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
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
