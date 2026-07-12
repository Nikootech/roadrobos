import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../providers/taxi_provider.dart';
import '../../providers/connectivity_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen>
    with SingleTickerProviderStateMixin {
  // 10-minute countdown (600 seconds)
  static const int _searchDurationSeconds = 600;
  int _remainingSeconds = _searchDurationSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _remainingSeconds = _searchDurationSeconds;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          timer.cancel();
          // Time's up – the provider handles the actual cancel
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _countdownText {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get _countdownProgress => _remainingSeconds / _searchDurationSeconds;

  @override
  Widget build(BuildContext context) {
    // Listen for auto-cancel (provider → idle after timeout)
    ref.listen<TaxiState>(taxiProvider, (previous, next) {
      if (previous?.status == RideStatus.booked &&
          next.status == RideStatus.idle) {
        _countdownTimer?.cancel();
        if (mounted) {
          _showCancelledDialog(wasOnline: previous?.paymentMethod == 'Online');
        }
      }
    });

    final taxiState = ref.watch(taxiProvider);
    final isSearching = taxiState.status == RideStatus.booked;
    final isOffline = ref.watch(connectivityProvider).value ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. Live Map
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
              roadroboLocation: taxiState.roadroboLocation,
              isTracking: !isSearching,
              pickupLocation: taxiState.pickupLocation,
            ),
          ),

          // 2. Searching Full Screen
          if (isSearching) _buildSearchingOverlay(context, taxiState),

          // 3. Header Status (Pill style) — only when driver is assigned
          if (!isSearching && !isOffline)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              child: _buildTrackingStatusPill(taxiState),
            ).animate().fadeIn().slideY(begin: -0.5, end: 0),

          if (isOffline)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(20)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('Live updates paused',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ],
                ),
              ),
            ).animate().fadeIn(),

          // 4. Driver Card (Bottom) — only when driver assigned
          if (!isSearching)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildDriverBottomCard(context, taxiState),
            ).animate().slideY(
                begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutQuart),

          // 5. Close / Back button (only when driver assigned, not searching)
          if (!isSearching)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              child: GestureDetector(
                onTap: () async {
                  ref.read(taxiProvider.notifier).cancelRide();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ride cancelled'),
                        backgroundColor: Colors.redAccent,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    context.go('/main/home');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10)
                      ]),
                  child: const Icon(Icons.close, color: Colors.black, size: 24),
                ),
              ),
            ),

          // 6. SOS Button
          if (!isSearching)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  _showSOSBottomSheet(context, taxiState);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.redAccent, blurRadius: 15)
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.shield, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('SOS',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchingOverlay(BuildContext context, TaxiState taxiState) {
    final isOnline = taxiState.paymentMethod == 'Online';

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Top countdown pill
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Searching for drivers...',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _remainingSeconds <= 60
                          ? Colors.red.shade50
                          : const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _remainingSeconds <= 60
                            ? Colors.red.shade300
                            : AppColors.primaryBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: _remainingSeconds <= 60
                              ? Colors.red
                              : AppColors.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _countdownText,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _remainingSeconds <= 60
                                ? Colors.red
                                : AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Countdown ring + animation
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated circular progress ring
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background circle
                          const SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: 1.0,
                              strokeWidth: 8,
                              color: Color(0xFFF3F4F6),
                            ),
                          ),
                          // Progress ring
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: _countdownProgress,
                              strokeWidth: 8,
                              strokeCap: StrokeCap.round,
                              color: _remainingSeconds <= 60
                                  ? Colors.red
                                  : AppColors.primaryBlue,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                          // Center icon pulsing
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.directions_bike_rounded,
                                size: 44,
                                color: _remainingSeconds <= 60
                                    ? Colors.red
                                    : AppColors.primaryBlue,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _countdownText,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: _remainingSeconds <= 60
                                      ? Colors.red
                                      : AppColors.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(0.97, 0.97),
                        end: const Offset(1.03, 1.03),
                        duration: 1200.ms),

                    const SizedBox(height: 32),

                    Text(
                      'Finding Your Roadrobo',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryNavy,
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 12),

                    Text(
                      'We\'re searching nearby drivers.\nWill auto-cancel if none available in 10 min.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Payment method badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isOnline
                              ? Colors.green.shade200
                              : Colors.orange.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isOnline
                                ? Icons.payment_rounded
                                : Icons.money_rounded,
                            size: 16,
                            color: isOnline
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isOnline
                                ? 'Paid Online · Auto refund if cancelled'
                                : 'Cash on Drop',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isOnline
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom card — Cancel button
            Container(
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: Column(
                children: [
                  // Info box
                  if (isOnline)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: Colors.blue.shade600, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'If you cancel or no driver is found within 10 minutes, your payment will be automatically refunded.',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.blue.shade700,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Cancel ride button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCancelConfirmDialog(
                        isOnline: isOnline,
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 20),
                      label: Text(
                        isOnline ? 'Cancel & Refund' : 'Cancel Ride',
                        style: GoogleFonts.outfit(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  void _showCancelConfirmDialog({required bool isOnline}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(
              'Cancel Ride?',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Text(
          isOnline
              ? 'Your ride will be cancelled and ₹${ref.read(taxiProvider).selectedOption?.price.toStringAsFixed(0) ?? ''} will be automatically refunded to your original payment method within 5–7 business days.'
              : 'Are you sure you want to cancel this ride?',
          style: GoogleFonts.outfit(fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep Searching',
                style: GoogleFonts.outfit(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              _countdownTimer?.cancel();
              await ref.read(taxiProvider.notifier).cancelAndRefund();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isOnline
                        ? '✅ Ride cancelled. Refund initiated successfully!'
                        : '✅ Ride cancelled.'),
                    backgroundColor: isOnline ? Colors.green : Colors.redAccent,
                  ),
                );
                context.go('/main/home');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isOnline ? 'Cancel & Refund' : 'Yes, Cancel',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelledDialog({required bool wasOnline}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              wasOnline
                  ? Icons.account_balance_wallet_rounded
                  : Icons.info_rounded,
              color: wasOnline ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              wasOnline ? 'Refund Initiated' : 'No Driver Found',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
            ),
          ],
        ),
        content: Text(
          wasOnline
              ? 'No drivers accepted your request in 10 minutes. Your booking has been cancelled and a full refund has been initiated. It will appear in your account within 5–7 business days.'
              : 'No nearby drivers were available in your area. Please try again or schedule a ride for later.',
          style: GoogleFonts.outfit(fontSize: 14, height: 1.6),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/main/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: wasOnline ? Colors.green : AppColors.primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Go Home',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStatusPill(TaxiState state) {
    String statusStr = state.eta != null
        ? 'Arriving: ${state.eta}'
        : 'Roadrobo is arriving soon';

    if (state.status == RideStatus.atPickup) {
      statusStr = 'Roadrobo has arrived!';
    } else if (state.status == RideStatus.headingToDropoff) {
      statusStr = state.eta != null
          ? 'Dropoff in: ${state.eta}'
          : 'Heading to destination';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: state.status == RideStatus.atPickup
            ? Colors.green
            : AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
                  state.status == RideStatus.atPickup
                      ? Icons.check_circle
                      : Icons.flash_on,
                  color: state.status == RideStatus.atPickup
                      ? Colors.white
                      : AppColors.primaryBlue,
                  size: 18)
              .animate(onPlay: (c) => c.repeat())
              .shimmer(),
          const SizedBox(width: 12),
          Text(
            statusStr,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverBottomCard(BuildContext context, TaxiState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 30, offset: Offset(0, -10))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2))),

          Row(
            children: [
              // Roadrobo Profile Image with Vehicle Badge
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFF3F4F6),
                    backgroundImage:
                        NetworkImage('https://i.pravatar.cc/150?u=roadrobo123'),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 4)
                          ]),
                      child: Image.asset(
                          state.selectedOption?.assetPath ??
                              'assets/icons/car.png',
                          width: 16,
                          height: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.roadroboName ?? 'Roadrobo',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        const Text('4.8',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                                color: Colors.grey, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(state.selectedOption?.title ?? 'Vehicle',
                            style: const TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6)),
                      child: const Text('KA 01 EB 4567',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1)),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildCircleAction(
                      Icons.chat_bubble_rounded, AppColors.primaryBlue,
                      onTap: () {
                    context.push('/chat', extra: {
                      'bookingId': state.rideId,
                      'receiverId': state.driverId ?? '',
                      'receiverName': state.roadroboName ?? 'Driver',
                    });
                  }),
                  const SizedBox(width: 12),
                  _buildCircleAction(Icons.call_rounded, Colors.green,
                      onTap: () async {
                    const phone = '+919876543210';
                    final uri = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Cannot open dialer on this device')),
                        );
                      }
                    }
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Payment method chip
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: state.paymentMethod == 'Online'
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.paymentMethod == 'Online'
                      ? Colors.green.shade200
                      : Colors.orange.shade200,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.paymentMethod == 'Online'
                        ? Icons.payment_rounded
                        : Icons.money_rounded,
                    size: 14,
                    color: state.paymentMethod == 'Online'
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.paymentMethod == 'Online'
                        ? 'Paid Online'
                        : 'Cash on Drop',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: state.paymentMethod == 'Online'
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // OTP / Action Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (state.status == RideStatus.atPickup ||
                    state.status == RideStatus.tracking) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VERIFY OTP',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(state.otp ?? '----',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Colors.green)),
                    ],
                  ),
                  if (state.status == RideStatus.atPickup)
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(taxiProvider.notifier).startTrip(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Start Trip',
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                ] else if (state.status == RideStatus.headingToDropoff) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HEADING TO',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(state.dropoffAddress ?? 'Destination',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryNavy)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => context.push('/taxi/complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Finish Trip',
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ] else ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('OTP TO START TRIP',
                          style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(state.otp ?? '4582',
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryNavy,
                              letterSpacing: 4)),
                    ],
                  ),
                  Opacity(
                    opacity: 0.5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12)),
                      child: const Text('Waiting for Arrival',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSOSBottomSheet(BuildContext context, TaxiState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              const Text('Emergency SOS',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.black)),
              const SizedBox(height: 8),
              const Text('Are you in an emergency? Choose an action below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  final Uri url = Uri(scheme: 'tel', path: '112');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                  if (context.mounted) context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Call Police (112)',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  final message =
                      'Emergency! I am in a RoadRobos ride. Driver: ${state.roadroboName}. Vehicle: ${state.selectedOption?.title}. Location: https://maps.google.com/?q=${state.roadroboLocation?.latitude},${state.roadroboLocation?.longitude}';
                  await Share.share(message);
                  if (context.mounted) context.pop();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Share Live Status',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel',
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleAction(IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
