import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/widgets/location_disclosure_dialog.dart';

/// Centralized Location Permission & Google Play Policy Disclosure Helper.
///
/// Ensures compliance with Google Play's Prominent Disclosure & Consent requirements
/// before requesting system runtime permissions.
class LocationPermissionHelper {
  static const String _kLocationDisclosureAcceptedKey =
      'location_prominent_disclosure_accepted_v1';

  /// Check if the user has previously accepted the in-app prominent disclosure.
  static Future<bool> hasAcceptedDisclosure() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_kLocationDisclosureAcceptedKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Mark the in-app prominent disclosure as accepted.
  static Future<void> markDisclosureAccepted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kLocationDisclosureAcceptedKey, true);
    } catch (_) {}
  }

  /// Requests location permissions with prior Prominent Disclosure if not already granted.
  ///
  /// Flow:
  /// 1. Checks if GPS / Location Services are enabled.
  /// 2. Checks current permission status (if already granted, returns true).
  /// 3. If not granted, shows [LocationDisclosureDialog].
  /// 4. If user agrees, triggers the system [Geolocator.requestPermission()] dialog.
  /// 5. Returns `true` if permission is granted, `false` otherwise.
  static Future<bool> requestLocationWithDisclosure({
    BuildContext? context,
    bool isBackgroundRequired = true,
  }) async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }

    // If context is available, show the Prominent Disclosure dialog first
    if (context != null && context.mounted) {
      final bool userConsented = await LocationDisclosureDialog.show(
        context,
        isBackgroundRequired: isBackgroundRequired,
      );

      if (!userConsented) {
        return false;
      }

      await markDisclosureAccepted();
    }

    // Trigger Android / iOS system runtime permission dialog
    permission = await Geolocator.requestPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Simple permission check without UI triggers.
  static Future<bool> hasLocationPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
