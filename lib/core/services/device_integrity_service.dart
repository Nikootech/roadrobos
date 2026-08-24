import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';

/// Provider for Device Integrity & Security Service.
final deviceIntegrityServiceProvider = Provider<DeviceIntegrityService>((ref) {
  return DeviceIntegrityService();
});

/// Device Integrity, Biometrics & Anti-Fraud Security Service
class DeviceIntegrityService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports Biometric Authentication (Fingerprint / Face Unlock).
  Future<bool> isBiometricsAvailable() async {
    if (kIsWeb) return false;
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } catch (e) {
      debugPrint('Biometrics check error: $e');
      return false;
    }
  }

  /// Trigger native Android BiometricPrompt.
  Future<bool> authenticate({
    required String localizedReason,
    bool stickyAuth = true,
  }) async {
    if (kIsWeb) return true;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
        ),
      );
      return authenticated;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  /// Detect Mock / Fake GPS location spoofing for driver dispatch fraud prevention.
  bool isMockLocation(Position position) {
    return position.isMocked;
  }
}
