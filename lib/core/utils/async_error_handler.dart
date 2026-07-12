import 'dart:async';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../security/jailbreak_guard.dart';
import '../repositories/wallet_repository.dart';

/// Global utility to handle asynchronous errors by logging them to Sentry
/// and producing clean, user-friendly error messages.
class AsyncErrorHandler {
  AsyncErrorHandler._();

  /// Logs the [error] and optional [stackTrace] to Sentry and returns
  /// a user-friendly error description suitable for UI presentation.
  static String handleError(dynamic error, [StackTrace? stackTrace]) {
    // 1. Log to Sentry
    Sentry.captureException(error, stackTrace: stackTrace);

    // 2. Resolve user-friendly error message based on exception type
    if (error is PostgrestException) {
      if (error.code == 'P0001') {
        return 'Insufficient wallet balance. Please top up your wallet.';
      }
      return 'Database error occurred: ${error.message}';
    } else if (error is InsufficientBalanceException) {
      return 'Insufficient wallet balance. Please top up your wallet.';
    } else if (error is SocketException || error is TimeoutException) {
      return 'Network connection issue. Please check your internet connection and try again.';
    } else if (error is SecurityException) {
      return 'Operation blocked: device integrity check failed.';
    } else if (error is FormatException) {
      return 'Data processing error. Please try again.';
    } else {
      final msg = error.toString();
      if (msg.contains('SecurityException:')) {
        return msg
            .replaceFirst('SecurityException: ', '')
            .replaceFirst('SecurityException:', '');
      }
      if (msg.contains('Exception:')) {
        return msg
            .replaceFirst('Exception: ', '')
            .replaceFirst('Exception:', '');
      }
      return msg.isNotEmpty
          ? msg
          : 'An unexpected error occurred. Please try again.';
    }
  }
}
