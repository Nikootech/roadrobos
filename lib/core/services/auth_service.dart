import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../../core/config/app_config.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Listen to auth state changes across the app
final authStateProvider = StreamProvider<sb.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Google Client ID injected at compile time via --dart-define-from-file
const _googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

class AuthService {
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb && _googleClientId.isNotEmpty ? _googleClientId : null,
  );
  


  Stream<sb.User?> get authStateChanges {
    // Emit current session immediately on subscribe, then listen for changes
    return _supabase.auth.onAuthStateChange.map((data) {
      if (kDebugMode) {
        if (data.event == sb.AuthChangeEvent.tokenRefreshed) {
          debugPrint('Supabase Auth: Token Refreshed successfully.');
        } else if (data.event == sb.AuthChangeEvent.signedIn) {
          debugPrint('Supabase Auth: User Signed In.');
        } else if (data.event == sb.AuthChangeEvent.signedOut) {
          debugPrint('Supabase Auth: User Signed Out.');
        }
      }
      return data.session?.user;
    });
  }

  /// Check if we have an existing valid session (cold start restore)
  sb.User? get restoredUser => _supabase.auth.currentSession?.user;

  sb.User? get currentUser => _supabase.auth.currentUser;

  /// Trigger a demo login state (Note: For Supabase, this is a no-op marker)
  void setDemoUser(String uid) {
    // Demo mode is handled by UserNotifier state, not auth stream
  }

  // --- Email/Password Authentication ---

  Future<sb.AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<sb.AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  // --- Google Sign-In ---

  Future<bool> signInWithGoogle() async {
    try {
      // Use Supabase native OAuth for the best cross-platform compatibility
      return await _supabase.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: kIsWeb 
          ? Uri.base.origin
          : 'com.roadrobos.app://login-callback',
        queryParams: {
          'prompt': 'select_account',
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // --- Sign Out ---

  Future<void> signOut() async {
    if (!kIsWeb) await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }
}
