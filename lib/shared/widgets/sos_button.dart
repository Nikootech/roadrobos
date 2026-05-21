import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onTrigger;
  final String label;

  const SOSButton({
    super.key,
    required this.onTrigger,
    this.label = 'SOS',
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleLongPress() {
    widget.onTrigger();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency Alert Sent!'),
        backgroundColor: AppColors.alertRed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _handleLongPress,
      onLongPressStart: (_) => setState(() => _isPressed = true),
      onLongPressEnd: (_) => setState(() => _isPressed = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.alertRed,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.alertRed.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Iconsax.danger,
                color: Colors.white,
                size: 32,
              ),
            ),
          )
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2.seconds, color: Colors.white24)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 1.seconds,
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.1, 1.1),
            end: const Offset(1, 1),
            duration: 1.seconds,
            curve: Curves.easeInOut,
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: const TextStyle(
              color: AppColors.alertRed,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          if (_isPressed)
            const Text(
               'HOLD TO TRIGGER',
               style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
            ).animate().fadeIn(),
        ],
      ),
    );
  }
}
