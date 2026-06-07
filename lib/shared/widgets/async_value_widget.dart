import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'shimmer/shimmer_widgets.dart';

/// A generic widget that handles all three AsyncValue states uniformly:
///   • loading  → shimmer skeleton (never a white flash)
///   • error    → retry button with user-safe message
///   • data     → builder, with optional empty-state support
///
/// Do NOT use AsyncValue.requireValue or .value! in UI. Use this instead.
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function()? loading;
  final Widget Function(Object err, VoidCallback retry)? error;
  final Widget Function()? empty;
  final bool Function(T)? isEmpty;
  final VoidCallback? onRetry;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.error,
    this.empty,
    this.isEmpty,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading?.call() ?? const ShimmerCard(),
      error: (err, _) {
        final retry = onRetry ?? () {};
        if (error != null) return error!(err, retry);
        return _DefaultErrorWidget(
          // Only show technical error in debug mode
          message: kDebugMode
              ? err.toString()
              : 'Something went wrong. Please try again.',
          onRetry: retry,
        );
      },
      data: (d) {
        if (isEmpty != null && isEmpty!(d)) {
          return empty?.call() ?? const _DefaultEmptyWidget();
        }
        return data(d);
      },
    );
  }
}

// ─── Default error widget ─────────────────────────────────────────────────────

class _DefaultErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// ─── Default empty widget ─────────────────────────────────────────────────────

class _DefaultEmptyWidget extends StatelessWidget {
  const _DefaultEmptyWidget();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Nothing here yet.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
