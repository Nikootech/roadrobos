import 'package:screen_protector/screen_protector.dart';
import 'package:flutter/foundation.dart';

/// Controls FLAG_SECURE (Android) / screen-recording prevention.
/// Apply to payment, booking-confirmation, and profile screens.
class ScreenSecurity {
  ScreenSecurity._();

  static Future<void> secure() async {
    if (!kIsWeb) {
      await ScreenProtector.preventScreenshotOn();
    }
  }

  static Future<void> unsecure() async {
    if (!kIsWeb) {
      await ScreenProtector.preventScreenshotOff();
    }
  }
}
