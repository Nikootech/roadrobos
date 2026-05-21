import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../shared/widgets/live_map_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/shimmer_loading.dart';
import '../../shared/widgets/rental_completion_dialog.dart';
import '../../providers/taxi_provider.dart';
import '../../core/repositories/transaction_repository.dart';
import '../../core/models/transaction_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/payment_service.dart';
import '../../core/services/pricing_service.dart';
import '../../shared/widgets/sos_button.dart';
import '../../shared/widgets/chat/chat_screen.dart';
import '../profile/user_provider.dart';
import '../profile/sos_provider.dart';

class TaxiRideScreen extends ConsumerStatefulWidget {
  const TaxiRideScreen({super.key});

  @override
  ConsumerState<TaxiRideScreen> createState() => _TaxiRideScreenState();
}

class _TaxiRideScreenState extends ConsumerState<TaxiRideScreen> {
  final DraggableScrollableController _sheetController = DraggableScrollableController();
  late final PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      onSuccess: (PaymentSuccessResponse? response) async {
        final state = ref.read(taxiProvider);
        final basePrice = state.selectedOption?.price ?? 145.0;
        final breakdown = PricingService.calculateBill(basePrice);
        final userId = ref.read(userProvider).user?.id ?? 'demo';

        // 1. Log Transaction
        await ref.read(transactionRepositoryProvider).logTransaction(AppTransaction(
          id: '',
          userId: userId,
          razoprayPaymentId: response?.paymentId ?? 'SIM_SUCCESS',
          razorpayOrderId: response?.orderId,
          razorpaySignature: response?.signature,
          baseAmount: breakdown.baseAmount,
          gstAmount: breakdown.gstAmount,
          platformFee: breakdown.platformFee,
          handlingCharges: breakdown.handlingCharges,
          totalAmount: breakdown.totalPayable,
          description: 'Taxi Ride: ${state.pickupAddress} to ${state.dropoffAddress}',
          timestamp: DateTime.now(),
        ));

        // 2. Reset Taxi State
        ref.read(taxiProvider.notifier).reset();
        if (mounted) Navigator.pop(context); // Close the dialog
      },
      onFailure: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error),
            backgroundColor: AppColors.errorRed,
          ));
        }
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taxiProvider.notifier).initializeLocation();
    });
  }

  @override
  void dispose() {
    _paymentService.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final taxiState = ref.watch(taxiProvider);
    final taxiNotifier = ref.read(taxiProvider.notifier);
    final pickupController = ref.watch(pickupControllerProvider);
    final dropoffController = ref.watch(dropoffControllerProvider);

    // Sync controllers with state
    // Sync controllers with state ONLY if they are not currently focused to avoid jitter
    final pFocus = FocusScope.of(context).focusedChild;
    if (taxiState.pickupAddress != null && pickupController.text != taxiState.pickupAddress && pFocus == null) {
      pickupController.text = taxiState.pickupAddress!;
    }
    if (taxiState.dropoffAddress != null && dropoffController.text != taxiState.dropoffAddress && pFocus == null) {
      dropoffController.text = taxiState.dropoffAddress!;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Live Map
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              showLiveIndicator: taxiState.status == RideStatus.idle || taxiState.status == RideStatus.selectingPickup,
              roadroboLocation: taxiState.roadroboLocation,
              showNearbyTaxis: true,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture && (taxiState.status == RideStatus.selectingPickup || taxiState.status == RideStatus.selectingDrop)) {
                  final center = camera.center;
                  if (taxiState.status == RideStatus.selectingPickup) {
                    taxiNotifier.setPickup(center, 'Map Pin Location');
                  } else {
                    taxiNotifier.setDropoff(center, 'Map Pin Location');
                  }
                }
              },
            ),
          ),

          // 2. Center Pin for Selection
          if (taxiState.status == RideStatus.selectingPickup || taxiState.status == RideStatus.selectingDrop)
            _buildCenterPin(taxiState.status == RideStatus.selectingPickup),

          // 3. Safe Area Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildRoundedButton(Icons.arrow_back, () => Navigator.pop(context)),
                  const Spacer(),
                  if (taxiState.status == RideStatus.tracking || 
                      taxiState.status == RideStatus.headingToDropoff)
                    _buildRoundedButton(Icons.share, () {
                      final pos = taxiState.pickupLocation; // Using pickup as live loc for demo
                      if (pos != null) {
                        final link = 'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}';
                        ref.read(taxiProvider.notifier).shareTrip(link);
                      }
                    }),
                  const SizedBox(width: 12),
                  if (taxiState.status == RideStatus.tracking || 
                      taxiState.status == RideStatus.atPickup ||
                      taxiState.status == RideStatus.headingToDropoff)
                    _buildETAIndicator(taxiState.eta ?? 'Calculating...'),
                ],
              ),
            ),
          ),

          // 3. Main UI Overlay based on Status
          _buildBottomUI(context, taxiState, taxiNotifier, pickupController, dropoffController),
          
          // 3b. SOS Button Overlay (Visible during tracking/ride)
          if (taxiState.status == RideStatus.tracking || 
              taxiState.status == RideStatus.atPickup || 
              taxiState.status == RideStatus.headingToDropoff)
            Positioned(
              right: 20,
              bottom: MediaQuery.of(context).size.height * 0.45 + 20, // Sit above the sheet
              child: SOSButton(
                onTrigger: () {
                  final userId = ref.read(userProvider).user?.id ?? 'demo';
                  ref.read(sosProvider.notifier).triggerEmergency(userId);
                },
              ),
            ).animate().fadeIn().scale(),

          // 4. Booking Shimmer Overlay
          if (taxiState.status == RideStatus.booked)
            _buildBookingShimmer(),
        ],
      ),
    );
  }

  Widget _buildBottomUI(
    BuildContext context, 
    TaxiState state, 
    TaxiNotifier notifier,
    TextEditingController pickupCtrl,
    TextEditingController dropoffCtrl,
  ) {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: state.status == RideStatus.idle ? 0.35 : 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20)],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 24),
              
              if (state.status == RideStatus.idle || 
                  state.status == RideStatus.selectingPickup || 
                  state.status == RideStatus.selectingDrop ||
                  state.status == RideStatus.vehicleSelection)
                _buildSearchSection(state, notifier, pickupCtrl, dropoffCtrl),
              
              if (state.status == RideStatus.tracking)
                _buildTrackingSection(state, notifier),
                
              if (state.status == RideStatus.completed)
                _buildCompletedSection(state, notifier),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchSection(TaxiState state, TaxiNotifier notifier, TextEditingController pCtrl, TextEditingController dCtrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Plan Your Ride', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 24),
        CustomTextField(
          label: 'Pickup Location',
          hint: 'Select pickup point',
          controller: pCtrl,
          prefixIcon: Iconsax.location,
          onChanged: (val) {
             notifier.updateStatus(RideStatus.selectingPickup);
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Destination',
          hint: 'Where to?',
          controller: dCtrl,
          prefixIcon: Iconsax.routing,
          onChanged: (val) {
             notifier.updateStatus(RideStatus.selectingDrop);
          },
        ),
        const SizedBox(height: 32),
        if (state.status == RideStatus.vehicleSelection)
          _buildFareEstimate(state),
        const SizedBox(height: 16),
        CustomButton(
          label: state.status == RideStatus.vehicleSelection ? 'BOOK NOW' : 'SELECT LOCATIONS',
          onPressed: state.status == RideStatus.booked ? null : () {
            _triggerHaptic();
            if (state.status == RideStatus.vehicleSelection) {
              // Fix: Centralized booking logic in Notifier ONLY to avoid duplicate writes
              notifier.bookRide(); 
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both locations')));
            }
          },
          isLoading: state.status == RideStatus.booked,
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildFareEstimate(TaxiState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estimated Fare', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text('₹ 145 - 180', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
            ],
          ),
          Text('${state.distance.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTrackingSection(TaxiState state, TaxiNotifier notifier) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Roadrobo Arriving', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)), child: Text('OTP: ${state.otp}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))),
          ],
        ),
        const SizedBox(height: 20),
        GlassCard(
          child: Row(
            children: [
              const CircleAvatar(radius: 24, backgroundColor: AppColors.bgLightAlt, child: Icon(Iconsax.user, color: AppColors.primaryBlue)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.roadroboName ?? 'Roadrobo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Text('Suzuki Gixxer • KA 01 EB 4567', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Iconsax.message, color: AppColors.primaryBlue),
                onPressed: () {
                  final currentUserId = ref.read(userProvider).user?.id ?? 'demo';
                  final driverId = state.driverId ?? 'driver_demo';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        roomId: '${currentUserId}_$driverId',
                        otherPartyName: state.roadroboName ?? 'Roadrobo',
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.call, color: AppColors.primaryBlue),
                onPressed: () async {
                  final Uri url = Uri(scheme: 'tel', path: '+919876543210');
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  try {
                    final success = await launchUrl(url);
                    if (!success) {
                      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
                    }
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Could not launch dialer')));
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        CustomButton(
          label: 'ARRIVED? END TRIP',
          onPressed: () {
            _triggerHaptic();
            notifier.completeRide();
            _showCompletionDialog(context, notifier);
          },
          backgroundColor: AppColors.errorRed,
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildCompletedSection(TaxiState state, TaxiNotifier notifier) {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 64),
        const SizedBox(height: 16),
        const Text('Ride Completed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 24),
        const Text('How was your experience?', style: TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => IconButton(
            icon: Icon(Icons.star_border_rounded, color: Colors.amber.withValues(alpha: 0.4), size: 32),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your rating!'), backgroundColor: AppColors.successGreen),
              );
            },
          )),
        ),
        const SizedBox(height: 32),
        CustomButton(
          label: 'BOOK NEXT RIDE',
          onPressed: () => notifier.reset(),
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildBookingShimmer() {
    return Container(
      color: Colors.white.withValues(alpha: 0.8),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShimmerLoading(height: 60, width: 60, borderRadius: 30),
              SizedBox(height: 32),
              ShimmerLoading(height: 20, width: 200),
              SizedBox(height: 12),
              ShimmerLoading(height: 15, width: 150),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildRoundedButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildETAIndicator(String eta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 14),
          const SizedBox(width: 8),
          Text(eta, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCenterPin(bool isPickup) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40), // Offset for pin tip
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
              child: Text(
                isPickup ? 'PICKUP HERE' : 'SET DESTINATION',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const Icon(Icons.location_on, size: 44, color: AppColors.errorRed),
          ],
        ),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  void _showCompletionDialog(BuildContext context, TaxiNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RentalCompletionDialog(
        vehicleName: 'Motorcycle',
        onCompletePayment: () {
          final userData = ref.read(userProvider).user;
          final state = ref.read(taxiProvider);
          final basePrice = state.selectedOption?.price ?? 145.0;
          final breakdown = PricingService.calculateBill(basePrice);

          _paymentService.startPayment(
            amount: breakdown.totalPayable,
            contact: userData?.phone ?? '9876543210',
            email: userData?.email ?? 'customer@example.com',
            description: 'Taxi Ride Payment',
            bookingId: '00000000-0000-0000-0000-000000000000',
            userId: userData?.id ?? 'demo',
          );
        },
        onReschedule: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
