import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

/// Rapido Captain Slide-to-Go-Online Switch
/// Features interactive haptic dragging, high-contrast outdoor visibility,
/// and smooth status transitions.
class RapidoSlideToOnline extends StatefulWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;
  final String? presentAddress;
  final bool isFetchingAddress;

  const RapidoSlideToOnline({
    super.key,
    required this.isOnline,
    required this.onToggle,
    this.presentAddress,
    this.isFetchingAddress = false,
  });

  @override
  State<RapidoSlideToOnline> createState() => _RapidoSlideToOnlineState();
}

class _RapidoSlideToOnlineState extends State<RapidoSlideToOnline>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  bool _isDragging = false;
  late AnimationController _pulseController;

  static const double _sliderHeight = 64.0;
  static const double _thumbSize = 54.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxDrag) {
    if (widget.isOnline) return;
    setState(() {
      _isDragging = true;
      _dragPosition = (_dragPosition + details.delta.dx).clamp(0.0, maxDrag);
    });

    if ((_dragPosition / 25).floor() != ((_dragPosition - details.delta.dx) / 25).floor()) {
      HapticFeedback.selectionClick();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxDrag) {
    if (widget.isOnline) return;
    if (_dragPosition >= maxDrag * 0.75) {
      HapticFeedback.heavyImpact();
      widget.onToggle(true);
      setState(() {
        _dragPosition = 0.0;
        _isDragging = false;
      });
    } else {
      HapticFeedback.lightImpact();
      setState(() {
        _dragPosition = 0.0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final maxDrag = totalWidth - _thumbSize - 10;

        if (widget.isOnline) {
          // --- ONLINE COCKPIT BANNER ---
          return Container(
            height: _sliderHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981), // Rapido Emerald Green
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Pulsing Green Indicator
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.25);
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 8 * scale,
                            spreadRadius: 2 * scale,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.radar_rounded,
                          color: Color(0xFF10B981),
                          size: 22,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ONLINE & READY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Scanning nearby rides in real-time',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rapido Tap to Go Offline button
                InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    widget.onToggle(false);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937), // Dark slate
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.power_settings_new_rounded,
                            color: Color(0xFFEF4444), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'GO OFFLINE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // --- OFFLINE: RAPIDO SWIPE TO GO ONLINE ---
        return GestureDetector(
          onHorizontalDragUpdate: (details) =>
              _onHorizontalDragUpdate(details, maxDrag),
          onHorizontalDragEnd: (details) => _onHorizontalDragEnd(details, maxDrag),
          child: Container(
            height: _sliderHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E24), // Rapido Charcoal Dark
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Track Text & Animated Chevrons
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'SWIPE TO GO ONLINE',
                        style: TextStyle(
                          color: Color(0xFFF59E0B), // Rapido Yellow
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: 0.4 + (_pulseController.value * 0.6),
                            child: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFF59E0B),
                              size: 14,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Drag Thumb (Vibrant Rapido Yellow with Steering / Lightning Icon)
                Positioned(
                  left: 5 + _dragPosition,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isDragging ? Iconsax.flash_1 : Icons.arrow_forward_rounded,
                        color: const Color(0xFF1E1E24),
                        size: 26,
                      ),
                    ),
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
