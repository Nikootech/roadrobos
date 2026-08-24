import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme/app_colors.dart';

/// Centralised navigation helpers with haptic feedback and React Sonner-style floating Toasts.
class NavHelpers {
  NavHelpers._();

  // ── Navigate with haptic feedback ──

  /// Replace current route stack (e.g. auth → home).
  static void go(BuildContext context, String route) {
    HapticFeedback.lightImpact();
    context.go(route);
  }

  /// Push a new route onto the stack.
  static void push(BuildContext context, String route) {
    HapticFeedback.lightImpact();
    context.push(route);
  }

  /// Pop the current route safely.
  static void pop(BuildContext context) {
    HapticFeedback.lightImpact();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/main/home');
    }
  }

  // ── React Sonner-Style Floating Glassmorphic Toast Notifications ──

  /// Shows a modern, floating glassmorphic toast notification.
  static void showToast(
    BuildContext context, {
    required String title,
    String? description,
    required Color accentColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        padding: EdgeInsets.zero,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark slate glassmorphism
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Glowing Accent Icon Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Description
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF94A3B8),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Clean raw error messages into user-friendly sentences.
  static String cleanErrorMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred. Please try again.';
    String raw = error.toString().trim();

    // Specific Supabase / Auth exception translations
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login credentials') ||
        lower.contains('invalid_credentials') ||
        lower.contains('invalid credential')) {
      return 'Incorrect email or password. Please verify and try again.';
    }
    if (lower.contains('user already registered') ||
        lower.contains('email_exists') ||
        lower.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('password should be at least') ||
        lower.contains('weak_password')) {
      return 'Password must be at least 6 characters long.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email address before signing in.';
    }
    if (lower.contains('rate limit') ||
        lower.contains('too many requests') ||
        lower.contains('over_email_send_rate_limit')) {
      return 'Too many attempts. Please wait a few moments and try again.';
    }
    if (lower.contains('socketexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('network') ||
        lower.contains('connection refused') ||
        lower.contains('clientexception')) {
      return 'Network connection issue. Please check your internet connection.';
    }
    if (lower.contains('user not found')) {
      return 'No account found matching this email address.';
    }

    // Strip Exception class prefixes if present
    if (raw.startsWith('Exception: ')) {
      raw = raw.substring('Exception: '.length);
    }
    if (raw.startsWith('AuthApiException(message: ')) {
      final endIdx = raw.indexOf(', statusCode:');
      if (endIdx != -1) {
        raw = raw.substring('AuthApiException(message: '.length, endIdx);
      }
    }
    if (raw.startsWith('AuthException: ')) {
      raw = raw.substring('AuthException: '.length);
    }
    if (raw.startsWith('PostgrestException(message: ')) {
      final endIdx = raw.indexOf(', code:');
      if (endIdx != -1) {
        raw = raw.substring('PostgrestException(message: '.length, endIdx);
      }
    }

    // Capitalize first letter if needed
    if (raw.isNotEmpty) {
      raw = raw[0].toUpperCase() + raw.substring(1);
    }

    return raw;
  }

  /// Shows a React-style Error Toast with automatic error message sanitization.
  static void showError(BuildContext context, dynamic error, [String? title]) {
    String rawMsg = error.toString().trim();
    String toastTitle = title ?? 'Action Failed';

    // If the error message already has a title prefix like "Login Failed: ..."
    if (rawMsg.contains(':')) {
      final parts = rawMsg.split(':');
      if (parts.length >= 2 && title == null) {
        toastTitle = parts[0].trim();
        rawMsg = parts.sublist(1).join(':').trim();
      }
    }

    final humanMessage = cleanErrorMessage(rawMsg);

    showToast(
      context,
      title: toastTitle,
      description: humanMessage,
      accentColor: const Color(0xFFEF4444), // Coral Red
      icon: Icons.error_outline_rounded,
    );
  }

  /// Shows a React-style Success Toast.
  static void showSuccess(BuildContext context, String message,
      [String? title]) {
    showToast(
      context,
      title: title ?? 'Success',
      description: message,
      accentColor: const Color(0xFF10B981), // Emerald
      icon: Icons.check_circle_rounded,
      duration: const Duration(seconds: 3),
    );
  }

  /// Shows a React-style Warning Toast.
  static void showWarning(BuildContext context, String message,
      [String? title]) {
    showToast(
      context,
      title: title ?? 'Notice',
      description: message,
      accentColor: const Color(0xFFF59E0B), // Amber
      icon: Iconsax.warning_2,
    );
  }

  /// Shows a React-style "Coming Soon" Toast.
  static void showComingSoon(BuildContext context, [String? featureName]) {
    showToast(
      context,
      title: 'Coming Soon',
      description: featureName != null
          ? '$featureName is arriving in the next release.'
          : 'This feature is arriving in the next release.',
      accentColor: const Color(0xFF3B82F6), // Royal Blue
      icon: Icons.rocket_launch_rounded,
    );
  }

  /// Backward-compatible action snackbar.
  static void showSnackAction(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    Color? color,
    Duration duration = const Duration(seconds: 3),
  }) {
    showToast(
      context,
      title: message,
      accentColor: color ?? AppColors.primaryBlue,
      icon: icon,
      duration: duration,
    );
  }

  /// Shows a confirmation dialog and executes the action if confirmed.
  static Future<void> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    // ignore: unawaited_futures
    HapticFeedback.lightImpact();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(cancelText,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    if (result == true) onConfirm();
  }
}
