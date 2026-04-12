import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';

class ServiceTeamAlertMonitor extends ConsumerWidget {
  const ServiceTeamAlertMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('technician_emergency_broadcast')
          .where('isAcknowledge', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final alert = snapshot.data!.docs.first;
        final data = alert.data() as Map<String, dynamic>;
        final location = data['location'] as Map<String, dynamic>;
        final lat = location['lat'];
        final lng = location['lng'];

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.dangerRed, Color(0xFF8B0000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.dangerRed.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _PulseIcon(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ROADSIDE EMERGENCY',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Nearby Customer SOS Triggered',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                      icon: const Icon(Iconsax.location, size: 18, color: AppColors.dangerRed),
                      label: const Text('NAVIGATE NOW', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.dangerRed,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('technician_emergency_broadcast')
                          .doc(alert.id)
                          .update({'isAcknowledge': true});
                    },
                    icon: const Icon(Iconsax.close_circle, color: Colors.white70),
                    tooltip: 'Dismiss Alert',
                  ),
                ],
              ),
            ],
          ),
        ).animate().slideY(begin: -1, end: 0).fadeIn().shimmer(duration: 2.seconds, color: Colors.white24);
      },
    );
  }
}

class _PulseIcon extends StatefulWidget {
  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
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
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2 + (_controller.value * 0.2)),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(_controller.value), width: 2),
          ),
          child: const Icon(Iconsax.danger, color: Colors.white, size: 28),
        );
      },
    );
  }
}
