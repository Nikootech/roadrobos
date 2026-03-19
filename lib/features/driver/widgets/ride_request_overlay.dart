import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_card.dart';
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

class _RideRequestOverlayState extends State<RideRequestOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();
    // 8 second timeout
    _timerController = AnimationController(vsync: this, duration: const Duration(seconds: 8))
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
      bottom: 110, // Float above bottom navigation
      left: 16,
      right: 16,
      child: Dismissible(
        key: Key(widget.request.id),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            widget.onAccept();
          } else {
            widget.onReject();
          }
        },
        background: Container(
          decoration: BoxDecoration(color: AppColors.successGreen, borderRadius: BorderRadius.circular(24)),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 32),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 40),
              Text('ACCEPT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ]
          )
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(color: AppColors.dangerRed, borderRadius: BorderRadius.circular(24)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 32),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Icon(Icons.cancel_outlined, color: Colors.white, size: 40),
               Text('REJECT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
            ]
          )
        ),
        child: GlassCard(
          blur: 15,
          opacity: 0.8, // Slightly more translucent
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppColors.deepNavy.withValues(alpha: 0.1), shape: BoxShape.circle),
                              child: const Icon(Icons.person, color: AppColors.deepNavy),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.request.riderName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.deepNavy)),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: AppColors.warningAmber, size: 14),
                                    const SizedBox(width: 4),
                                    Text('${widget.request.rating}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                )
                              ],
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('₹${widget.request.fare.toInt()}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.successGreen)),
                            Text(widget.request.distance, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.bgLightGrey.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.my_location_rounded, color: AppColors.primaryBlue, size: 16),
                              const SizedBox(width: 12),
                              Expanded(child: Text(widget.request.pickup, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 7),
                            child: Align(alignment: Alignment.centerLeft, child: Container(width: 2, height: 16, color: AppColors.textMuted)),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.dangerRed, size: 16),
                              const SizedBox(width: 12),
                              Expanded(child: Text(widget.request.dropoff, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('« Swipe Left to Reject', style: TextStyle(color: AppColors.dangerRed, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Swipe Right to Accept »', style: TextStyle(color: AppColors.successGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
              // Time bar
              AnimatedBuilder(
                animation: _timerController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: 1 - _timerController.value,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _timerController.value > 0.7 ? AppColors.dangerRed : AppColors.primaryBlue
                    ),
                    minHeight: 6,
                  );
                },
              )
            ],
          ),
        ),
      ).animate().scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack, duration: 500.ms).fadeIn(),
    );
  }
}
