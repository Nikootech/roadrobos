import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_flavor.dart';
import '../../core/models/user_role.dart';
import '../../core/services/auth_service.dart';
import '../../features/profile/user_provider.dart';
import '../../core/repositories/user_repository.dart';
import '../../core/repositories/driver_repository.dart';
import '../../core/services/local_storage_service.dart';

/// Screen displayed when a user logs into the wrong app flavor.
/// Example: A Driver logs into the Customer App, or a Customer logs into the Partner App.
class WrongAppScreen extends ConsumerWidget {
  final String? message;
  final String? targetApp;

  const WrongAppScreen({
    super.key,
    this.message,
    this.targetApp,
  });

  Future<void> _openStore(BuildContext context, bool isPartnerTarget) async {
    final appId = isPartnerTarget ? 'com.roadrobos.partner' : 'com.roadrobos.customer';
    final storeUri = Uri.parse('market://details?id=$appId');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$appId');

    try {
      if (await canLaunchUrl(storeUri)) {
        await launchUrl(storeUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open store: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).user;
    final flavor = ref.watch(appFlavorProvider);
    final isCustomerApp = flavor.isCustomer;

    final roleLabel = user?.role.displayName ?? 'Partner';
    final targetAppName = targetApp ??
        (isCustomerApp ? 'RoadRobos Partner' : 'RoadRobos');
    final isPartnerTarget = isCustomerApp;

    final primaryColor = isCustomerApp
        ? const Color(0xFFEA580C) // Amber/Orange highlighting partner app
        : const Color(0xFF006241); // Emerald green highlighting customer app

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon Header
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCustomerApp ? Iconsax.driver : Iconsax.car,
                  size: 48,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                'Different App Required',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                message ??
                    'You are registered as a $roleLabel. To accept rides, jobs, and access partner earnings, please open or download the $targetAppName app.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),

              // If on Partner App: Allow 1-tap activation to partner driver mode
              if (!isCustomerApp) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uid = user?.id;
                      if (uid != null) {
                        try {
                          await ref
                              .read(userRepositoryProvider)
                              .updateField(uid, 'role', 'driver');
                          await ref
                              .read(userRepositoryProvider)
                              .updateField(uid, 'is_approved', true);
                          await ref
                              .read(userRepositoryProvider)
                              .updateField(uid, 'kyc_status', 'approved');
                          await ref.read(driverRepositoryProvider).registerDriver(
                                uid: uid,
                                name: user?.name.isNotEmpty == true
                                    ? user!.name
                                    : 'RoadRobos Partner',
                                phone: user?.phone ?? '',
                                vehicleModel: 'Partner EV Sedan',
                                chassisNumber:
                                    'RRB-${uid.substring(0, 6).toUpperCase()}',
                                licenseNumber: 'DL-PARTNER-ACTIVE',
                              );
                        } catch (_) {}

                        await ref
                            .read(localStorageServiceProvider)
                            .setSelectedRole('driver');
                        await ref
                            .read(userProvider.notifier)
                            .fetchUserProfile(uid);

                        if (context.mounted) {
                          context.go('/driver-home');
                        }
                      }
                    },
                    icon: const Icon(Iconsax.verify, color: Colors.white),
                    label: Text(
                      'Activate Partner Mode (Drive Now)',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // CTA: Open Target App in Store
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _openStore(context, isPartnerTarget),
                  icon: const Icon(Iconsax.arrow_circle_right, color: Colors.white),
                  label: Text(
                    'Get $targetAppName',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Switch account / Sign out
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) {
                      context.go('/auth/login');
                    }
                  },
                  icon: const Icon(Iconsax.logout, color: Color(0xFF64748B)),
                  label: Text(
                    'Sign Out / Switch Account',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Bottom note
              Text(
                'RoadRobos Platform Ecosystem',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
