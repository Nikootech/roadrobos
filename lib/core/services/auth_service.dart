import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Listen to auth state changes across the app
final authStateProvider = StreamProvider<sb.User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

class AuthService {
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Use a broadcast stream controller to handle manual state overrides (like demo mode)
  final StreamController<sb.User?> _manualAuthStateController = StreamController<sb.User?>.broadcast();

  Stream<sb.User?> get authStateChanges {
    // Combine Supabase auth state changes with our manual overrides
    return _supabase.auth.onAuthStateChange.map((data) => data.session?.user);
  }

  sb.User? get currentUser => _supabase.auth.currentUser;

  /// Trigger a demo login state (Note: For Supabase, we might just return a mock user ID)
  void setDemoUser(String uid) {
    _manualAuthStateController.add(null); 
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
          ? 'http://localhost:8081' 
          : 'com.nikootech.roadrobos://login-callback',
        queryParams: {
          'prompt': 'select_account',
        },
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // --- Sign Out ---

  Future<void> signOut() async {
    if (!kIsWeb) await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }
}
