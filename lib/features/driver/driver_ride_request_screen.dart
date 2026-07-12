import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'providers/driver_state_provider.dart';

/// Driver Ride Request Screen — Fully wired to live Supabase ride data.
/// Receives a [RideRequest] via GoRouter extra and accepts/declines atomically.
class DriverRideRequestScreen extends ConsumerStatefulWidget {
  const DriverRideRequestScreen({super.key});

  @override
  ConsumerState<DriverRideRequestScreen> createState() => _DriverRideRequestScreenState();
}

class _DriverRideRequestScreenState extends ConsumerState<DriverRideRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isProcessing = false;

  static const _timeoutSeconds = 60;

  @override
  void initState() {
    super.initState();
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: _timeoutSeconds))
          ..forward().then((_) {
            if (mounted) context.pop();
          });
    Future.delayed(const Duration(milliseconds: 300), () => HapticFeedback.vibrate());
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _onAccept(RideRequest ride) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    unawaited(HapticFeedback.heavyImpact());
    _progressController.stop();
    try {
      await ref.read(rideRequestsActionProvider.notifier).acceptRequest(ride.id);
      if (mounted) context.pushReplacement('/driver-assigned');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        context.pop();
      }
    }
  }

  void _onDecline() {
    HapticFeedback.lightImpact();
    _progressController.stop();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final ride = GoRouterState.of(context).extra as RideRequest?;

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.85),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.5,
                  colors: [AppColors.primaryBlue.withValues(alpha: 0.2), Colors.black],
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('NEW RIDE REQUEST',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primaryBlue, letterSpacing: 1.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(8)),
                        child: Text('₹${ride?.fare.toStringAsFixed(0) ?? '---'}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.deepNavy)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 100, width: double.infinity,
                        decoration: BoxDecoration(color: AppColors.bgLightGrey, borderRadius: BorderRadius.circular(20)),
                        child: Icon(Iconsax.map_1, color: AppColors.primaryBlue.withValues(alpha: 0.3), size: 50),
                      ),
                      const Icon(Icons.circle, color: AppColors.primaryBlue, size: 12)
                          .animate(onPlay: (c) => c.repeat())
                          .scale(duration: 1.seconds, begin: const Offset(1, 1), end: const Offset(3, 3))
                          .fadeOut(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildLocation(Icons.radio_button_checked_rounded, AppColors.primaryBlue, 'PICKUP', ride?.pickup ?? '...'),
                  const SizedBox(height: 6),
                  Container(width: 2, height: 14, color: AppColors.bgLightGrey, margin: const EdgeInsets.only(left: 9)),
                  const SizedBox(height: 6),
                  _buildLocation(Icons.location_on_rounded, AppColors.dangerRed, 'DROP OFF', ride?.dropoff ?? '...'),
                  const SizedBox(height: 24),
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat('CUSTOMER', ride?.riderName ?? '---'),
                      _buildStat('DISTANCE', ride?.distance ?? '---'),
                      _buildStat('FARE', '₹${ride?.fare.toStringAsFixed(0) ?? '0'}', isMain: true),
                    ],
                  ),
                  const SizedBox(height: 24),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, _) {
                      final remaining = (_timeoutSeconds * (1 - _progressController.value)).ceil();
                      final isUrgent = remaining <= 10;
                      return Column(
                        children: [
                          LinearProgressIndicator(
                            value: 1 - _progressController.value,
                            backgroundColor: AppColors.bgLightGrey,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isUrgent ? AppColors.dangerRed : AppColors.primaryBlue,
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Auto-declining in ${remaining}s',
                            style: TextStyle(
                              fontSize: 10,
                              color: isUrgent ? AppColors.dangerRed : AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _isProcessing ? null : _onDecline,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Decline',
                              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _isProcessing
                            ? const Center(child: CircularProgressIndicator())
                            : CustomButton(
                                label: 'ACCEPT',
                                onPressed: ride != null ? () => _onAccept(ride) : null,
                                backgroundColor: AppColors.successGreen,
                              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(delay: 1.seconds),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ).animate().scale(begin: const Offset(0.85, 0.85), duration: 500.ms, curve: Curves.easeOutBack).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildLocation(IconData icon, Color color, String label, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              Text(address, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, {bool isMain = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: isMain ? 22 : 14, fontWeight: FontWeight.w900, color: isMain ? AppColors.deepNavy : AppColors.textPrimary)),
      ],
    );
  }
}