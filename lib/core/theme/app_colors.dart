import 'package:flutter/material.dart';

/// All color constants extracted from Figma design via API
class AppColors {
  AppColors._();

  // ── Brand Greens (RoAdRoBo's Logo Palette) ──
  static const Color brandGreen = Color(0xFF006241);      // Deep forest green — main logo color
  static const Color brandGreenMid = Color(0xFF1B8A5A);   // Mid green — swirl accent
  static const Color brandGreenLight = Color(0xFF10B981); // Bright green — electric bolt
  static const Color brandGreenBg = Color(0xFFF0FBF5);    // Soft green tint background
  static const LinearGradient brandGreenGradient = LinearGradient(
    colors: [brandGreen, brandGreenMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Primary Blues (Vibrant Sky/Premium palette) ──
  static const Color primaryBlue = Color(0xFF38BDF8); // Vibrant Sky Blue
  static const Color primaryBlueDark = Color(0xFF0EA5E9);
  static const Color primaryBlueLight = Color(0xFF7DD3FC);
  static const Color bgSkyLight = Color(0xFFF0F9FF);
  static const Color primaryNavy = Color(0xFF0C4A6E); // Deep Sky Navy
  static const Color deepNavy = Color(0xFF082F49);
  static const Color accentIndigo = Color(0xFF0284C7);

  // ── Accent / CTA (Vibrant Amber/Orange) ──
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color warmOrange = Color(0xFFFB923C);

  // ── Success / Positive ──
  static const Color successGreen = Color(0xFF13EC5B);
  static const Color successDark = Color(0xFF10B981);
  static const Color successMuted = Color(0xFF4CAF50);
  static const Color verifiedGreen = Color(0xFF22C55E);

  // ── Error / Danger ──
  static const Color errorRed = Color(0xFFF44336);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color alertRed = Color(0xFFDC2626);

  // ── Warning ──
  static const Color warningYellow = Color(0xFFFBBC05);
  static const Color warningAmber = Color(0xFFFACC15);

  // ── Light Theme Backgrounds (Glass-friendly) ──
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgLightAlt = Color(0xFFF1F5F9);
  static const Color bgLightWarm = Color(0xFFFFF7ED);
  static const Color bgLightCard = Color(0xFFFFFFFF);
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLightGrey = Color(0xFFF1F5F9);
  static const Color bgLightSurface = Color(0xFFF8FAFC);

  // ── Dark Theme Backgrounds (Modern Deep Navy/Black) ──
  // These are now legacy but redirected to maintain compatibility
  static const Color bgDark = Color(0xFFF8FAFC); 
  static const Color bgDarkAlt = Color(0xFFF1F5F9);
  static const Color bgDarkDeep = Color(0xFF0F1117);
  static const Color bgDarkSurface = Color(0xFF1A1D27);
  static const Color bgDarkCard = Color(0xFF222533);
  static const Color bgDarkNavy = Color(0xFF0EA5E9);
  static const Color bgDarkNav = Color(0xFFF8FAFC);
  static const Color bgDarkDeepest = Color(0xFFFFFFFF);
  static const Color bgDarkBottom = Color(0xFFFFFFFF);
  static const Color bgDarkProfile = Color(0xFFF1F5F9);
  static const Color bgDarkFeedback = Color(0xFFF0F9FF);
  static const Color bgDarkRevenue = Color(0xFFF0F9FF);

  // ── Text Colors ──
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFF9FAFB); 
  static const Color textOnDarkMuted = Color(0xFF9CA3AF);

  // ── Border / Divider ──
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF1F5F9);

  // ── Shadows ──
  static const Color shadowLight = Color(0x0D000000);
  static const Color shadowMedium = Color(0x1A000000);

  // ── Chip / Tag Colors ──
  static const Color chipBlue = Color(0xFFEFF6FF);
  static const Color chipGreen = Color(0xFFECFDF5);
  static const Color chipRed = Color(0xFFFEF2F2);
  static const Color chipYellow = Color(0xFFFEFCE8);
  static const Color chipPurple = Color(0xFFFAF5FF);

  // ── Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [primaryBlue, primaryBlueLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successGreen, successDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [accentOrange, warmOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
