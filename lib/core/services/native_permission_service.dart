import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../shared/widgets/permission_rationale_modal.dart';

/// Provider for Android Native Permission Service.
final nativePermissionServiceProvider =
    Provider<NativePermissionService>((ref) {
  return NativePermissionService();
});

/// Android Native Permission Service managing Android 13/14+ permission dialogs with contextual rationales.
class NativePermissionService {
  /// Request Android 13+ Notification Permission with contextual rationale.
  Future<bool> requestNotificationPermission(BuildContext context) async {
    if (kIsWeb) return true;

    // Show contextual rationale sheet first
    final userConfirmed = await PermissionRationaleModal.show(
      context,
      type: AppPermissionType.notifications,
    );

    if (!userConfirmed) return false;

    if (Firebase.apps.isEmpty) {
      debugPrint('Firebase not initialized for notifications.');
      return false;
    }

    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        criticalAlert: true,
      );

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;
      debugPrint('Notification permission granted: $granted');
      return granted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Request Precise Location Permission with contextual rationale.
  Future<LocationPermission> requestLocationPermission(
      BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return permission;
    }

    if (!context.mounted) return permission;

    // Show rationale modal
    final userConfirmed = await PermissionRationaleModal.show(
      context,
      type: AppPermissionType.location,
    );

    if (!userConfirmed) return permission;

    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        _showSettingsRedirectDialog(
          context,
          title: 'Location Permission Required',
          message:
              'Location permission is permanently disabled. Please enable it in Android Settings to book rides and detect nearby services.',
        );
      }
    }

    return permission;
  }

  /// Request Background Location for Drivers/Technicians.
  Future<LocationPermission> requestBackgroundLocationPermission(
      BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.always) {
      return permission;
    }

    // First ensure Foreground location is granted
    if (permission != LocationPermission.whileInUse) {
      if (!context.mounted) return permission;
      permission = await requestLocationPermission(context);
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return permission;
      }
    }

    // Show background location rationale modal
    if (context.mounted) {
      final userConfirmed = await PermissionRationaleModal.show(
        context,
        type: AppPermissionType.backgroundLocation,
      );

      if (!userConfirmed) return permission;
    }

    permission = await Geolocator.requestPermission();
    return permission;
  }

  /// Show standard dialog redirecting user to Android App Settings.
  void _showSettingsRedirectDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006241),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
