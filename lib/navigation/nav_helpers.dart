import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';

/// Centralised navigation helpers with haptic feedback and styled SnackBars.
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

  // ── Styled SnackBar for non-navigation actions ──

  /// Shows a premium styled SnackBar with an icon and message.
  static void showSnackAction(
    BuildContext context,
    String message, {
    IconData icon = Icons.check_circle_rounded,
    Color? color,
    Duration duration = const Duration(seconds: 2),
  }) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color ?? AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: duration,
      ),
    );
  }

  /// Shows a "coming soon" styled SnackBar for features not yet implemented.
  static void showComingSoon(BuildContext context, [String? featureName]) {
    showSnackAction(
      context,
      featureName != null ? '$featureName — coming soon!' : 'Coming soon!',
      icon: Icons.rocket_launch_rounded,
      color: AppColors.accentOrange,
    );
  }

  /// Shows a success SnackBar.
  static void showSuccess(BuildContext context, String message) {
    showSnackAction(
      context,
      message,
      color: AppColors.successGreen,
    );
  }

  /// Shows an error SnackBar.
  static void showError(BuildContext context, String message) {
    showSnackAction(
      context,
      message,
      icon: Icons.error_outline_rounded,
      color: AppColors.dangerRed,
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
