import 'package:flutter/foundation.dart';

/// Checks whether the device is rooted (Android) or jailbroken (iOS).
/// On detection, payment flow is blocked and a non-dismissible warning is shown.
///
/// NOTE: flutter_jailbreak_detection must be added to pubspec.yaml:
///   flutter_jailbreak_detection: ^1.9.0
///
/// This stub provides the guard structure. To activate:
///   1. Add the package.
///   2. Uncomment the import and detection line below.
class JailbreakGuard {
  JailbreakGuard._();

  static bool _isCompromised = false;

  /// true if device is rooted/jailbroken.
  static bool get isCompromised => _isCompromised;

  /// Call once in main() post-frame callback.
  /// Never blocks on detection failure — fail open.
  static Future<void> check() async {
    if (kIsWeb) return; // N/A on web
    try {
      // Uncomment after adding flutter_jailbreak_detection to pubspec.yaml:
      // _isCompromised = await FlutterJailbreakDetection.jailbroken;
      // For now we safely default to false (not compromised).
      _isCompromised = false;
    } catch (_) {
      _isCompromised = false;
    }
  }

  /// Throws a [SecurityException] if the device is compromised.
  /// Call this at the start of any payment or sensitive operation.
  static void assertSecure() {
    if (_isCompromised) {
      throw const SecurityException(
        'Operation blocked: device integrity compromised.',
      );
    }
  }
}

class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
