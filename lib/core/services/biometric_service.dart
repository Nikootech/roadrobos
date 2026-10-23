import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

enum BiometricAuthResult {
  success,
  failed,
  notEnrolled,
  notSupported,
}

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();
  static const MethodChannel _settingsChannel =
      MethodChannel('com.roadrobos.roadrobos/device_settings');

  /// Open phone's security / lock screen / biometric settings directly
  static Future<void> openSecuritySettings() async {
    try {
      await _settingsChannel.invokeMethod('openSecuritySettings');
    } catch (_) {
      // fallback
    }
  }

  /// Check if biometrics is supported on this device
  Future<bool> isAvailable() async {
    final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Get list of available biometrics (Fingerprint, Face, etc)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  /// Perform biometric authentication returning boolean
  Future<bool> authenticate(
      {String localizedReason = 'Please authenticate to continue'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check if device has biometrics enrolled (fingerprint, face, etc)
  Future<bool> isEnrolled() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      if (biometrics.isNotEmpty) return true;
      final canCheck = await _auth.canCheckBiometrics;
      return canCheck && biometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Perform biometric authentication with explicit result enum to detect un-enrolled device credentials
  Future<BiometricAuthResult> authenticateWithResult({
    String localizedReason = 'Please authenticate to continue',
  }) async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      if (!isSupported) {
        return BiometricAuthResult.notSupported;
      }

      final canCheck = await _auth.canCheckBiometrics;
      final biometrics = await _auth.getAvailableBiometrics();

      // If no biometrics (fingerprint/face) are enrolled on this phone, prompt setup first
      if (!canCheck || biometrics.isEmpty) {
        return BiometricAuthResult.notEnrolled;
      }

      final success = await _auth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (!success) {
        final currentBiometrics = await _auth.getAvailableBiometrics();
        if (currentBiometrics.isEmpty) {
          return BiometricAuthResult.notEnrolled;
        }
      }
      return success ? BiometricAuthResult.success : BiometricAuthResult.failed;
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();
      final msg = (e.message ?? '').toLowerCase();
      if (code.contains('notenrolled') ||
          code.contains('notavailable') ||
          code.contains('passcode') ||
          code.contains('nobiometrics') ||
          code.contains('nodevicecredential') ||
          code.contains('keyguard') ||
          msg.contains('not enrolled') ||
          msg.contains('not available') ||
          msg.contains('no fingerprints') ||
          msg.contains('no biometrics') ||
          e.code == 'NotEnrolled' ||
          e.code == 'NotAvailable' ||
          e.code == 'PasscodeNotSet') {
        return BiometricAuthResult.notEnrolled;
      }
      return BiometricAuthResult.failed;
    } catch (_) {
      return BiometricAuthResult.failed;
    }
  }
}
