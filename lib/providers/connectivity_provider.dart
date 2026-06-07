import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  
  // Emit initial state
  final initialResult = await connectivity.checkConnectivity();
  yield initialResult.contains(ConnectivityResult.none);

  // Yield subsequent changes
  await for (final results in connectivity.onConnectivityChanged) {
    yield results.contains(ConnectivityResult.none);
  }
});
