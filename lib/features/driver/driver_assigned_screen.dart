import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../shared/widgets/glass_card.dart';
import '../../providers/taxi_provider.dart';

/// Driver Assigned Screen matching Rapido Captain Logic — Premium Overhaul
class DriverAssignedScreen extends ConsumerStatefulWidget {
  const DriverAssignedScreen({super.key});

  @override
  ConsumerState<DriverAssignedScreen> createState() =>
      _DriverAssignedScreenState();
}

class _DriverAssignedScreenState extends ConsumerState<DriverAssignedScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _showOtpError = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _handleOtpSubmit() {
    final success =
        ref.read(taxiProvider.notifier).verifyOtp(_otpController.text);
    if (success) {
      setState(() => _showOtpError = false);
      HapticFeedback.mediumImpact();
    } else {
      setState(() => _showOtpError = true);
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(taxiProvider, (previous, next) {
      if (previous?.status != RideStatus.idle &&
          next.status == RideStatus.idle) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Ride was cancelled by the customer.')));
          context.pop();
        }
      }
    });

    final taxiState = ref.watch(taxiProvider);
    final status = taxiState.status;

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Map Background Section
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              roadroboLocation: taxiState.roadroboLocation,
              pickupLocation: taxiState.pickupLocation,
              isTracking: true,
              isDriver: true,
            ),
          ),

          // Top Controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFloatingButton(Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.pop()),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.deepNavy,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 10)
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.directions_rounded,
                              color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text('NAVIGATE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  letterSpacing: 0.5)),
                        ],
                      ),
                    ).animate().fadeIn().scale(),
                  ],
                ),
              ),
            ),
          ),

          // Sliding Trip Info Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                          color: AppColors.bgLightGrey,
                          borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 24),
                  _buildTripStatusHeader(taxiState),
                  const SizedBox(height: 28),
                  if (status == RideStatus.atPickup && !taxiState.isOtpVerified)
                    _buildOtpSection()
                  else
                    _buildRouteInfo(taxiState),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 24),
                  _buildPassengerInfo(taxiState),
                  const SizedBox(height: 32),
                  _buildActionButton(taxiState),
                ],
              ),
            ).animate().slideY(
                begin: 0.5,
                end: 0,
                duration: 800.ms,
                curve: Curves.easeOutQuart),
          )
        ],
      ),
    );
  }

  Widget _buildTripStatusHeader(TaxiState state) {
    String title = 'Picking up passenger';
    String subtitle = state.eta ?? 'Calculating...';
    Color accentColor = AppColors.primaryBlue;

    if (state.status == RideStatus.atPickup) {
      title = state.isOtpVerified ? 'OTP Verified' : 'Waiting at pickup';
      subtitle = 'Arrived at pickup point';
      accentColor = AppColors.successGreen;
    } else if (state.status == RideStatus.headingToDropoff) {
      title = 'In Trip';
      subtitle = 'Heading to destination';
      accentColor = AppColors.accentOrange;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time_filled_rounded,
                            size: 14, color: accentColor),
                        const SizedBox(width: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            state.status == RideStatus.headingToDropoff
                ? Icons.location_on_rounded
                : Icons.directions_car_rounded,
            color: accentColor,
            size: 32,
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms),
      ],
    );
  }

  Widget _buildOtpSection() {
    return Column(
      children: [
        GlassCard(
          opacity: 0.05,
          child: Column(
            children: [
              const Text('ENTER START CODE (OTP)',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      letterSpacing: 1)),
              const SizedBox(height: 16),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10,
                    color: AppColors.deepNavy),
                maxLength: 4,
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '----',
                  hintStyle: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.3)),
                  border: InputBorder.none,
                ),
                onChanged: (val) {
                  if (val.length == 4) {
                    _handleOtpSubmit();
                  }
                },
              ),
              if (_showOtpError)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text('Invalid OTP. Please try again.',
                      style: TextStyle(
                          color: AppColors.dangerRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn().scale();
  }

  Widget _buildRouteInfo(TaxiState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgLightGrey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded,
              color: state.status == RideStatus.headingToDropoff
                  ? AppColors.dangerRed
                  : AppColors.successGreen,
              size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.status == RideStatus.headingToDropoff
                  ? (state.dropoffAddress ?? 'Terminal 3, IGI Airport')
                  : (state.pickupAddress ?? 'MG Road, Delhi'),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ),
          Text(
            state.status == RideStatus.headingToDropoff ? 'DROP OFF' : 'PICKUP',
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerInfo(TaxiState state) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?u=rahul'),
                fit: BoxFit.cover),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 2),
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Passenger',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                    SizedBox(width: 4),
                    Text('4.8 • ',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Wallet Payment',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildActionIcon(Iconsax.message, AppColors.primaryBlue, () => {}),
        const SizedBox(width: 12),
        _buildActionIcon(Iconsax.call, AppColors.successGreen, () => {}),
      ],
    );
  }

  Widget _buildActionButton(TaxiState state) {
    String label = 'I\'VE ARRIVED';
    Color color = AppColors.primaryBlue;
    VoidCallback onPressed =
        () => ref.read(taxiProvider.notifier).arriveAtPickup();

    if (state.status == RideStatus.atPickup) {
      if (!state.isOtpVerified) {
        label = 'ENTER OTP TO START';
        color = AppColors.textMuted;
        onPressed = () {}; // Managed by TextField onChanged
      } else {
        label = 'START TRIP';
        color = AppColors.successGreen;
        onPressed = () => ref.read(taxiProvider.notifier).startTrip();
      }
    } else if (state.status == RideStatus.headingToDropoff) {
      label = 'COMPLETE TRIP';
      color = AppColors.deepNavy;
      onPressed = () {
        ref.read(taxiProvider.notifier).completeRide();
        context.pop();
      };
    }

    return CustomButton(
      label: label,
      onPressed: onPressed,
      backgroundColor: color,
    ).animate().scale(delay: 500.ms);
  }

  Widget _buildFloatingButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (onTap != null) onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
            ]),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
