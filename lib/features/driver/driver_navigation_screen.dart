import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';
import '../../shared/widgets/sos_button.dart';

class DriverNavigationScreen extends StatefulWidget {
  final String destination;
  final String phase; // 'pickup' or 'dropoff'

  const DriverNavigationScreen({
    super.key,
    this.destination = 'Pickup Location',
    this.phase = 'pickup',
  });

  @override
  State<DriverNavigationScreen> createState() =>
      _DriverNavigationScreenState();
}

class _DriverNavigationScreenState
    extends State<DriverNavigationScreen> {
  // Simulated turn-by-turn instruction cycling
  int _turnIndex = 0;
  late Timer _turnTimer;
  bool _arrived = false;

  static const _turns = [
    {'icon': Icons.straight_rounded, 'text': 'Continue on MG Road', 'dist': '1.2 km'},
    {'icon': Icons.turn_right_rounded, 'text': 'Turn right onto Brigade Road', 'dist': '800 m'},
    {'icon': Icons.turn_left_rounded, 'text': 'Turn left at the signal', 'dist': '300 m'},
    {'icon': Icons.place_rounded, 'text': 'Destination on your right', 'dist': '50 m'},
  ];

  @override
  void initState() {
    super.initState();
    // Cycle through turn instructions every 6 seconds (demo mode)
    _turnTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && _turnIndex < _turns.length - 1) {
        setState(() => _turnIndex++);
        HapticFeedback.lightImpact();
      }
    });
  }

  @override
  void dispose() {
    _turnTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final turn = _turns[_turnIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full-screen map
          Positioned.fill(
            child: LiveMapWidget(
              height: MediaQuery.of(context).size.height,
            ),
          ),

          // Top: Navigation phase pill + back
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8)
                      ],
                    ),
                    child: const Icon(Icons.arrow_back_rounded,
                        color: Colors.black87, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12)
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.phase == 'pickup'
                              ? Icons.person_pin_circle_rounded
                              : Icons.location_on_rounded,
                          color: widget.phase == 'pickup'
                              ? AppColors.brandGreen
                              : const Color(0xFFF43F5E),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Navigating to ${widget.destination}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SOSButton(onTrigger: () {}),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          // Turn instruction card
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 16,
            right: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(0, -0.3), end: Offset.zero)
                    .animate(CurvedAnimation(
                        parent: anim, curve: Curves.easeOutCubic)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: Container(
                key: ValueKey(_turnIndex),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1628),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.brandGreen, AppColors.brandGreenMid],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        turn['icon'] as IconData,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            turn['text'] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'In ${turn['dist']}',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AppColors.brandGreenLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress dots
                    Column(
                      children: List.generate(_turns.length, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          width: 6,
                          height: i == _turnIndex ? 18 : 6,
                          decoration: BoxDecoration(
                            color: i <= _turnIndex
                                ? AppColors.brandGreenLight
                                : Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom: ETA + Arrived CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1628),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stats row
                  Row(
                    children: [
                      _statChip(
                          Icons.access_time_rounded,
                          '${(_turns.length - _turnIndex) * 2} min',
                          'ETA'),
                      const SizedBox(width: 12),
                      _statChip(
                          Icons.speed_rounded,
                          '${(_turns.length - _turnIndex) * 0.4 + 0.3} km',
                          'Distance'),
                      const SizedBox(width: 12),
                      _statChip(
                          Icons.navigation_rounded,
                          widget.phase == 'pickup'
                              ? 'Pickup'
                              : 'Dropoff',
                          'Phase'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _arrived
                          ? null
                          : () {
                              HapticFeedback.heavyImpact();
                              setState(() => _arrived = true);
                              _turnTimer.cancel();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    widget.phase == 'pickup'
                                        ? '✅ Arrived at pickup! Notify customer.'
                                        : '✅ Trip completed!',
                                  ),
                                  backgroundColor: AppColors.brandGreen,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                              final nav = Navigator.of(context);
                              Future.delayed(const Duration(seconds: 2), () {
                                if (!mounted) return;
                                nav.pop();
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _arrived ? Colors.white12 : AppColors.brandGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _arrived
                                ? Icons.check_circle_rounded
                                : Icons.place_rounded,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _arrived
                                ? 'Arrived!'
                                : "I've Arrived at ${widget.phase == 'pickup' ? 'Pickup' : 'Destination'}",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 500.ms,
              curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.brandGreenLight, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            Text(label,
                style: GoogleFonts.outfit(
                    fontSize: 10, color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}
