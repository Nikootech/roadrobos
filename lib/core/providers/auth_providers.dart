import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../services/auth_service.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(AuthServiceRef ref) {
  return AuthService();
}

@Riverpod(keepAlive: true)
Stream<sb.User?> authState(AuthStateRef ref) {
  return ref.watch(authServiceProvider).authStateChanges;
}
