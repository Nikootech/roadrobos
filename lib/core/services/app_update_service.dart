import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../main.dart' show scaffoldMessengerKey;

/// Provider for Google Play In-App Updates.
final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});

/// Android In-App Update Engine (Flexible & Immediate Google Play flows)
class AppUpdateService {
  AppUpdateInfo? _updateInfo;
  bool _isChecking = false;

  AppUpdateInfo? get updateInfo => _updateInfo;

  /// Check if an update is available on Google Play Store.
  Future<AppUpdateInfo?> checkForUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      debugPrint('AppUpdateService: In-App Updates only supported on Android.');
      return null;
    }

    if (_isChecking) return _updateInfo;
    _isChecking = true;

    try {
      final info = await InAppUpdate.checkForUpdate();
      _updateInfo = info;
      debugPrint(
          'AppUpdateService: Update availability: ${info.updateAvailability}');
      return info;
    } catch (e) {
      debugPrint('AppUpdateService: Check for update failed: $e');
      return null;
    } finally {
      _isChecking = false;
    }
  }

  /// Trigger Flexible Background Update (non-blocking, user can keep using app).
  Future<bool> startFlexibleUpdate(BuildContext context) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;

    try {
      final info = _updateInfo ?? await checkForUpdate();
      if (info == null ||
          info.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }

      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) {
        _showRestartBanner();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('AppUpdateService: Flexible update failed: $e');
      return false;
    }
  }

  /// Trigger Immediate Blocking Update (for critical security/breaking changes).
  Future<bool> performImmediateUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;

    try {
      final info = _updateInfo ?? await checkForUpdate();
      if (info == null ||
          info.updateAvailability != UpdateAvailability.updateAvailable) {
        return false;
      }

      final result = await InAppUpdate.performImmediateUpdate();
      return result == AppUpdateResult.success;
    } catch (e) {
      debugPrint('AppUpdateService: Immediate update failed: $e');
      return false;
    }
  }

  /// Complete Flexible Update by restarting the app.
  Future<void> completeFlexibleUpdate() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e) {
      debugPrint('AppUpdateService: Complete flexible update failed: $e');
    }
  }

  void _showRestartBanner() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
    scaffoldMessengerKey.currentState?.showMaterialBanner(
      MaterialBanner(
        backgroundColor: const Color(0xFF006241),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Iconsax.arrow_circle_down,
              color: Colors.white, size: 22),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Ready to Install',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'A new version of RoadRobos has finished downloading.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
            },
            child: Text(
              'LATER',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
              completeFlexibleUpdate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF006241),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text(
              'RESTART',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
