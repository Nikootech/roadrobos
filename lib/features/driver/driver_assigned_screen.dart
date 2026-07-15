import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../shared/widgets/glass_card.dart';
import '../../core/models/ride_booking.dart';
import '../../core/repositories/driver_repository.dart';
import '../../core/models/user_role.dart';
import 'providers/driver_state_provider.dart';

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

  // Validates OTP and atomically starts the trip on the backend.
  // Must be async so we can await the DB write and surface errors to the driver.
  Future<void> _handleOtpSubmit(RideBooking booking) async {
    if (_otpController.text == booking.otp) {
      setState(() => _showOtpError = false);
      await HapticFeedback.mediumImpact();
      try {
        await ref
            .read(driverRepositoryProvider)
            .updateTripStatus(booking.id, 'started');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      setState(() => _showOtpError = true);
      await HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTripAsync = ref.watch(driverActiveTripProvider);

    return activeTripAsync.when(
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (booking) {
        if (booking == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip completed or cancelled.')),
              );
              context.pop();
            }
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          );
        }

        final passengerAsync =
            ref.watch(passengerProfileProvider(booking.customerId));
        final passenger = passengerAsync.value;
        final driverMapState = ref.watch(mapStateProvider);
        final driverLoc = LatLng(driverMapState.lat, driverMapState.lng);

        return Scaffold(
          backgroundColor: AppColors.bgLightGrey,
          body: Stack(
            fit: StackFit.expand,
            children: [
              // Map Background Section
              Positioned.fill(
                child: LiveMapWidget(
                  height: MediaQuery.of(context).size.height,
                  roadroboLocation: driverLoc,
                  pickupLocation: LatLng(booking.pickupLat, booking.pickupLng),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      _buildTripStatusHeader(booking),
                      const SizedBox(height: 28),
                      if (booking.status == 'arrived')
                        _buildOtpSection(booking)
                      else
                        _buildRouteInfo(booking),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),
                      _buildPassengerInfo(booking, passenger),
                      const SizedBox(height: 32),
                      _buildActionButton(booking),
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
      },
    );
  }

  Widget _buildTripStatusHeader(RideBooking booking) {
    String title = 'Picking up passenger';
    String subtitle = 'Arriving at pickup';
    Color accentColor = AppColors.primaryBlue;

    if (booking.status == 'arrived') {
      title = 'Waiting at pickup';
      subtitle = 'Ask for OTP to start trip';
      accentColor = AppColors.successGreen;
    } else if (booking.status == 'started') {
      title = 'Heading to Dropoff';
      subtitle = 'Drive safely';
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
            booking.status == 'started'
                ? Icons.location_on_rounded
                : Icons.directions_car_rounded,
            color: accentColor,
            size: 32,
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms),
      ],
    );
  }

  Widget _buildOtpSection(RideBooking booking) {
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
                    _handleOtpSubmit(booking);
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

  Widget _buildRouteInfo(RideBooking booking) {
    final showDrop = booking.status == 'started';
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
              color: showDrop ? AppColors.dangerRed : AppColors.successGreen,
              size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              showDrop ? booking.destinationAddress : booking.pickupAddress,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary),
            ),
          ),
          Text(
            showDrop ? 'DROP OFF' : 'PICKUP',
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

  Widget _buildPassengerInfo(RideBooking booking, AppUser? passenger) {
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(passenger?.name ?? 'Passenger',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    const Text('4.8 • ',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('${booking.paymentMethod} Payment',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        _buildActionIcon(Iconsax.message, AppColors.primaryBlue, () {
          context.push('/chat', extra: {
            'bookingId': booking.id,
            'receiverId': booking.customerId,
            'receiverName': passenger?.name ?? 'Passenger',
          });
        }),
        const SizedBox(width: 12),
        _buildActionIcon(Iconsax.call, AppColors.successGreen, () async {
          final phone = passenger?.phone ?? '+919876543210';
          final uri = Uri(scheme: 'tel', path: phone);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cannot open dialer on this device')),
              );
            }
          }
        }),
      ],
    );
  }

  Widget _buildActionButton(RideBooking booking) {
    String label = 'I\'VE ARRIVED';
    Color color = AppColors.primaryBlue;
    // I'VE ARRIVED — awaited so DB and UI are always in sync.
    VoidCallback onPressed = () async {
      try {
        await ref
            .read(driverRepositoryProvider)
            .updateTripStatus(booking.id, 'arrived');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };

    if (booking.status == 'arrived') {
      label = 'ENTER OTP TO START';
      color = AppColors.textMuted;
      onPressed = () {}; // Managed by OTP entry input field
    } else if (booking.status == 'started') {
      label = 'COMPLETE TRIP';
      color = AppColors.deepNavy;
      onPressed = () async {
        try {
          await ref
              .read(driverRepositoryProvider)
              .updateTripStatus(booking.id, 'completed');
          if (mounted) context.pop();
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to complete trip: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      };
    }

    return CustomButton(
      label: label,
      onPressed: booking.status == 'arrived' ? null : onPressed,
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
