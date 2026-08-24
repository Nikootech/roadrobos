import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kinetic touch-response widget that shrinks slightly on tap with spring feedback.
class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;

  const ScaleOnTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.96,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () {
        if (widget.onTap != null) {
          HapticFeedback.lightImpact();
          widget.onTap!();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Continuous glowing radar pulse ring for online beacons and live indicators.
class PulseBeacon extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const PulseBeacon({
    super.key,
    required this.color,
    this.size = 10,
    this.duration = const Duration(milliseconds: 1600),
  });

  @override
  State<PulseBeacon> createState() => _PulseBeaconState();
}

class _PulseBeaconState extends State<PulseBeacon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size * 2.4,
          height: widget.size * 2.4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer expanding ring
              Container(
                width: widget.size * (1.0 + _controller.value * 1.4),
                height: widget.size * (1.0 + _controller.value * 1.4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(
                    alpha: (1.0 - _controller.value) * 0.45,
                  ),
                ),
              ),
              // Inner solid dot
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.6),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Animated Counter Ticker for numeric amounts & KPIs.
class AnimatedCounterText extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final int fractionDigits;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCounterText({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.fractionDigits = 0,
    this.style,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        final formattedVal = fractionDigits == 0
            ? val.toInt().toString()
            : val.toStringAsFixed(fractionDigits);
        return Text(
          '$prefix$formattedVal$suffix',
          style: style ??
              GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
        );
      },
    );
  }
}
