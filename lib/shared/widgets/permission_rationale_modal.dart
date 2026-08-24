import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'kinetic_motion.dart';

/// Enum representing Android permission categories with contextual metadata.
enum AppPermissionType {
  notifications,
  location,
  backgroundLocation,
  camera,
  photosMedia,
}

/// World-Class React-Style Permission Rationale Modal Sheet
class PermissionRationaleModal extends StatelessWidget {
  final AppPermissionType type;
  final VoidCallback onAllow;
  final VoidCallback? onDismiss;

  const PermissionRationaleModal({
    super.key,
    required this.type,
    required this.onAllow,
    this.onDismiss,
  });

  static Future<bool> show(
    BuildContext context, {
    required AppPermissionType type,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PermissionRationaleModal(
        type: type,
        onAllow: () => Navigator.of(ctx).pop(true),
        onDismiss: () => Navigator.of(ctx).pop(false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final meta = _getPermissionMetadata(type);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3D Squircle Icon with Radiant Gradient
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: meta.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: meta.gradient.first.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(meta.icon, color: Colors.white, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Center(
              child: Text(
                meta.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
            Center(
              child: Text(
                meta.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Key Benefit Points
            ...meta.benefits.map((benefit) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: const Icon(
                          Iconsax.tick_circle,
                          color: Color(0xFF006241),
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          benefit,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),

            // Primary Grant CTA Button
            ScaleOnTap(
              onTap: onAllow,
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006241), Color(0xFF10B981)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF006241).withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue & Allow',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Iconsax.arrow_right_3,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Secondary Dismiss Button
            Center(
              child: TextButton(
                onPressed: onDismiss ?? () => Navigator.of(context).pop(false),
                child: Text(
                  'Not Now',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _PermissionMeta _getPermissionMetadata(AppPermissionType type) {
    switch (type) {
      case AppPermissionType.notifications:
        return const _PermissionMeta(
          title: 'Enable Push Notifications',
          subtitle:
              'Stay informed with instant updates on your rides and orders',
          icon: Iconsax.notification_bing,
          gradient: [Color(0xFF0284C7), Color(0xFF38BDF8)],
          benefits: [
            'Real-time taxi arrival alerts & driver contact',
            'Service progress, inspection reports & spare parts updates',
            'Exclusive promotional discounts & wallet cashbacks',
          ],
        );
      case AppPermissionType.location:
        return const _PermissionMeta(
          title: 'Precise Location Access',
          subtitle: 'Required for doorstep pickups and vehicle navigation',
          icon: Iconsax.location,
          gradient: [Color(0xFF006241), Color(0xFF10B981)],
          benefits: [
            'Instant automatic pickup spot detection on map',
            'Accurate driver ETA and live route traffic estimation',
            'Nearby verified service hubs & rental pickup spots',
          ],
        );
      case AppPermissionType.backgroundLocation:
        return const _PermissionMeta(
          title: 'Background Location Access',
          subtitle: 'Required for driver dispatch and active navigation',
          icon: Iconsax.routing,
          gradient: [Color(0xFFD97706), Color(0xFFFBBF24)],
          benefits: [
            'Receive passenger pickup requests even when app is minimized',
            'Continuous route telemetry for passenger safety & tracking',
            'Automatic trip completion upon reaching drop destination',
          ],
        );
      case AppPermissionType.camera:
        return const _PermissionMeta(
          title: 'Camera Access',
          subtitle: 'For QR code scanning and vehicle checkups',
          icon: Iconsax.camera,
          gradient: [Color(0xFF0D9488), Color(0xFF14B8A6)],
          benefits: [
            'Instant QR scanner for rental vehicle unlocking',
            'Capture vehicle scratch/dent photos for job cards',
            'Quick photo upload for driving license & KYC verification',
          ],
        );
      case AppPermissionType.photosMedia:
        return const _PermissionMeta(
          title: 'Photos & Documents Access',
          subtitle: 'Required to upload vehicle records and save receipts',
          icon: Iconsax.gallery,
          gradient: [Color(0xFF334155), Color(0xFF64748B)],
          benefits: [
            'Select vehicle RC and insurance policies from gallery',
            'Save PDF tax invoices and service receipts directly to device',
          ],
        );
    }
  }
}

class _PermissionMeta {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final List<String> benefits;

  const _PermissionMeta({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.benefits,
  });
}
