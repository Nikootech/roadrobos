import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/services/local_storage_service.dart';

/// Rapido Captain inspired welcome and induction landing for new RoadRobos Partners.
class PartnerWelcomeScreen extends ConsumerWidget {
  const PartnerWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFDBA74)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              size: 16, color: Color(0xFFEA580C)),
                          const SizedBox(width: 6),
                          Text(
                            'ROADROBOS PARTNER PROGRAM',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFEA580C),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Hero Headline
                    Text(
                      'Drive, Service & Earn\nOn Your Terms.',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Join over 10,000+ drivers and verified technicians enjoying daily payouts and complete flexibility.',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Feature 1: Daily Instant Cashout
                    _buildFeatureCard(
                      icon: Iconsax.wallet_3,
                      iconBg: const Color(0xFF10B981),
                      title: 'Instant Bank Payouts',
                      description:
                          'Withdraw your daily earnings directly to your bank account or UPI within seconds.',
                    ),
                    const SizedBox(height: 14),

                    // Feature 2: High Demand & Surge
                    _buildFeatureCard(
                      icon: Iconsax.radar_2,
                      iconBg: const Color(0xFFEA580C),
                      title: 'Demand Hubs & Surge',
                      description:
                          'Live commuter map overlay directs you to peak surge hubs for up to 1.6x earnings.',
                    ),
                    const SizedBox(height: 14),

                    // Feature 3: Technician Workshop & Parts
                    _buildFeatureCard(
                      icon: Iconsax.setting_2,
                      iconBg: const Color(0xFF0D9488),
                      title: 'Verified Spare Parts & Job Cards',
                      description:
                          'Receive digital job cards, genuine parts supply, and upfront pricing for vehicle repairs.',
                    ),
                    const SizedBox(height: 14),

                    // Feature 4: Partner Insurance & Safety
                    _buildFeatureCard(
                      icon: Iconsax.shield_tick,
                      iconBg: const Color(0xFF6366F1),
                      title: '24/7 Accidental Insurance',
                      description:
                          'Every on-duty ride and emergency service breakdown is insured up to ₹5,00,000.',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        await HapticFeedback.lightImpact();
                        await ref
                            .read(localStorageServiceProvider)
                            .setSelectedRole('driver');
                        if (context.mounted) {
                          context.go('/auth/register');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEA580C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Register as Driver / Pilot',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        await HapticFeedback.lightImpact();
                        await ref
                            .read(localStorageServiceProvider)
                            .setSelectedRole('technician');
                        if (context.mounted) {
                          context.go('/auth/register');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Register as Service Technician',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () async {
                      await ref
                          .read(localStorageServiceProvider)
                          .setSelectedRole('driver');
                      if (context.mounted) {
                        context.go('/auth/login');
                      }
                    },
                    child: Text(
                      'Already a partner? Sign In',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconBg, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
