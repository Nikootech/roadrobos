import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Android 15 Edge-to-Edge and Dynamic System Bar Controller
class SystemUiService {
  /// Configure full Edge-to-Edge transparent navigation bar and crisp status bar.
  static void configureEdgeToEdge({bool isDarkMode = false}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarContrastEnforced: false,
      ),
    );

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }
}
