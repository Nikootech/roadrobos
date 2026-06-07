import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider for checking if the device is rooted/jailbroken
final jailbreakProvider = Provider<bool>((ref) => JailbreakGuard.isCompromised);

/// Checks whether the device is rooted (Android) or jailbroken (iOS).
/// On detection, payment flow is blocked and a non-dismissible warning is shown.
class JailbreakGuard {
  JailbreakGuard._();

  static bool _isCompromised = false;

  /// true if device is rooted/jailbroken.
  static bool get isCompromised => _isCompromised;

  /// Call once in main() post-frame callback.
  /// Never blocks on detection failure — fail open.
  static Future<bool> check() async {
    if (kIsWeb) return false; // N/A on web
    try {
      _isCompromised = await FlutterJailbreakDetection.jailbroken;
    } catch (e, stack) {
      debugPrint('Jailbreak detection failed, defaulting to false. Error: $e\n$stack');
      _isCompromised = false;
    }
    return _isCompromised;
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

  /// Show non-dismissible warning dialog for rooted/jailbroken devices
  static void showDisallowedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Security Warning'),
          content: const Text(
            'This device appears to be rooted/jailbroken. Sensitive operations are disabled for your security.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecurityException implements Exception {
  final String message;
  const SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}
