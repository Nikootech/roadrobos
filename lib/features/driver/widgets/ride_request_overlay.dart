import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/driver_state_provider.dart';

class RideRequestOverlay extends StatefulWidget {
  final RideRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RideRequestOverlay({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<RideRequestOverlay> createState() => _RideRequestOverlayState();
}

class _RideRequestOverlayState extends State<RideRequestOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    _timerController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..forward().whenComplete(() {
            if (mounted) widget.onReject();
          });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 110,
      left: 16,
      right: 16,
      child: Dismissible(
        key: Key(widget.request.id),
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            widget.onAccept();
          } else {
            widget.onReject();
          }
        },
        background: _buildActionBg(
            AppColors.successGreen, Icons.check_circle_rounded, 'ACCEPT', true),
        secondaryBackground: _buildActionBg(
            AppColors.dangerRed, Icons.close_rounded, 'REJECT', false),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primaryBlue
                                            .withValues(alpha: 0.3),
                                        width: 1.5),
                                  ),
                                  child: const CircleAvatar(
                                      radius: 26,
                                      backgroundImage: NetworkImage(
                                          'https://i.pravatar.cc/150?u=rider')),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.request.riderName,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: AppColors.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: AppColors.bgLightGrey,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star_rounded,
                                                color: AppColors.accentAmber,
                                                size: 14),
                                            const SizedBox(width: 4),
                                            Text('${widget.request.rating}',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 13,
                                                    color:
                                                        AppColors.textPrimary)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₹${widget.request.fare.toInt()}',
                                  style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.successGreen,
                                      letterSpacing: -1)),
                              Text(widget.request.distance,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13)),
                            ],
                          )
                        ],
                      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 24),

                      // Route visualization
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.bgLightGrey.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            _buildCompactLocation(
                                Icons.radio_button_checked_rounded,
                                AppColors.primaryBlue,
                                widget.request.pickup),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 7),
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                      width: 2,
                                      height: 12,
                                      color: AppColors.textMuted
                                          .withValues(alpha: 0.3))),
                            ),
                            const SizedBox(height: 8),
                            _buildCompactLocation(Icons.location_on_rounded,
                                AppColors.dangerRed, widget.request.dropoff),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 24),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swipe_right_rounded,
                              size: 16, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Text('Swipe to Accept or Reject',
                              style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(width: 8),
                          Icon(Icons.swipe_left_rounded,
                              size: 16, color: AppColors.textMuted),
                        ],
                      )
                    ],
                  ),
                ),
                // Premium Progress Timer
                AnimatedBuilder(
                  animation: _timerController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: 1 - _timerController.value,
                      backgroundColor: AppColors.bgLightGrey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _timerController.value > 0.8
                              ? AppColors.dangerRed
                              : AppColors.primaryBlue),
                      minHeight: 2,
                    );
                  },
                )
              ],
            ),
          ),
        ),
      )
          .animate()
          .scale(
              begin: const Offset(0.9, 0.9),
              curve: Curves.easeOutBack,
              duration: 600.ms)
          .fadeIn(),
    );
  }

  Widget _buildActionBg(
      Color color, IconData icon, String label, bool isStart) {
    return Container(
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(32)),
      alignment: isStart ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 36),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildCompactLocation(IconData icon, Color color, String address) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Expanded(
            child: Text(address,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
