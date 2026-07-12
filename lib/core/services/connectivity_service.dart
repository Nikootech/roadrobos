import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized network connectivity service.
/// Wraps `connectivity_plus` to provide a single source of truth for online/offline state.
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Stream provider that emits true/false based on network availability.
final isOnlineProvider = StreamProvider<bool>((ref) {
  return ref.watch(connectivityServiceProvider).onConnectivityChanged;
});

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  /// Check current connectivity status synchronously
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (kDebugMode) {
        debugPrint('Connectivity: ${online ? "ONLINE" : "OFFLINE"}');
      }
      return online;
    });
  }

  /// Guard wrapper: throws a user-friendly error if offline
  Future<T> requireOnline<T>(Future<T> Function() action) async {
    final online = await isOnline;
    if (!online) {
      throw OfflineException(
          'No internet connection. Please check your network and try again.');
    }
    return action();
  }
}

class OfflineException implements Exception {
  final String message;
  OfflineException(this.message);

  @override
  String toString() => message;
}
