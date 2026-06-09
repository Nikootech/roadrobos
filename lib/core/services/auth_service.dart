// IMPORTANT: All StreamSubscription fields must be cancelled in dispose/onDispose.

import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

import '../../main.dart' show navigatorKey;
import '../security/secure_token_storage.dart';
import 'package:go_router/go_router.dart';

part 'auth_service.g.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<sb.User?> build() async {
    try {
      final client = sb.Supabase.instance.client;

      // 1. Cold start — restore session from Supabase's secure storage
      final initialUser = client.auth.currentSession?.user;

      // 2. Listen to all Supabase auth state changes
      final subscription = client.auth.onAuthStateChange.listen((data) {
        if (kDebugMode) {
          debugPrint('AuthNotifier: ${data.event}');
        }

        // ── S7: Forced logout on JWT expiry / 401 ──────────────────────────────
        // Supabase fires signedOut when refresh fails. We must clear all state
        // to prevent the user staying logged in with stale data.
        if (data.event == sb.AuthChangeEvent.signedOut &&
            state.value != null) {
          unawaited(
            SecureTokenStorage.instance.clearAll().catchError((_) {}),
          );
          state = const AsyncData(null);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            navigatorKey.currentContext?.go('/auth/login');
          });
          return;
        }

        state = AsyncData(data.session?.user);
      });

      ref.onDispose(() => subscription.cancel());
      return initialUser;
    } catch (e, stack) {
      debugPrint('AuthNotifier: Supabase initialization error: $e\n$stack');
      return null;
    }
  }
}

/// Google Client ID injected at compile time via --dart-define-from-file
const _googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

class AuthService {
  sb.SupabaseClient get _supabase => sb.Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // The web/server client ID is required on Android to get an ID token
    // that can be verified by Supabase (backend).
    serverClientId: kIsWeb ? null : '542549978836-l55rm9ftucubic1ibc3domifpgc8ikst.apps.googleusercontent.com',
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

  // --- Google Sign-In (Native in-app, no browser redirect) ---

  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web: use Supabase OAuth redirect. Point to /login-callback so the
        // PKCE code lands on a dedicated, validated route (not the root URL).
        final redirectUrl = '${Uri.base.origin}/login-callback';
        return await _supabase.auth.signInWithOAuth(
          sb.OAuthProvider.google,
          redirectTo: redirectUrl,
          queryParams: {'prompt': 'select_account'},
        );
      }

      // Mobile: use native Google Sign-In (shows in-app account picker)
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google Sign-In failed: No ID token received.');
      }

      // Exchange Google tokens with Supabase
      await _supabase.auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Fetch and sync profile details from Google Account
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        final googlePhotoUrl = googleUser.photoUrl;
        final googleName = googleUser.displayName;

        // 1. Update Supabase Auth metadata
        final Map<String, dynamic> metadata = Map<String, dynamic>.from(currentUser.userMetadata ?? {});
        bool needsMetaUpdate = false;
        if (googlePhotoUrl != null && metadata['avatar_url'] == null) {
          metadata['avatar_url'] = googlePhotoUrl;
          needsMetaUpdate = true;
        }
        if (googleName != null && metadata['full_name'] == null) {
          metadata['full_name'] = googleName;
          needsMetaUpdate = true;
        }

        if (needsMetaUpdate) {
          try {
            await _supabase.auth.updateUser(
              sb.UserAttributes(data: metadata),
            );
          } catch (e) {
            if (kDebugMode) debugPrint('Google Sign-In: Failed to update auth metadata: $e');
          }
        }

        // 2. Direct database profiles table sync (to bypass delay or edge cases)
        final updates = <String, dynamic>{};
        if (googlePhotoUrl != null) {
          updates['profile_pic'] = googlePhotoUrl;
        }
        if (googleName != null) {
          updates['name'] = googleName;
        }

        if (updates.isNotEmpty) {
          try {
            final profileResponse = await _supabase
                .from('profiles')
                .select('profile_pic, name')
                .eq('id', currentUser.id)
                .maybeSingle();

            if (profileResponse != null) {
              final existingPic = profileResponse['profile_pic'] as String?;
              final existingName = profileResponse['name'] as String?;
              
              final dbUpdates = <String, dynamic>{};
              if ((existingPic == null || existingPic.isEmpty) && googlePhotoUrl != null) {
                dbUpdates['profile_pic'] = googlePhotoUrl;
              }
              if ((existingName == null || existingName.isEmpty || existingName == 'New User') && googleName != null) {
                dbUpdates['name'] = googleName;
              }

              if (dbUpdates.isNotEmpty) {
                await _supabase.from('profiles').update(dbUpdates).eq('id', currentUser.id);
              }
            } else {
              await _supabase.from('profiles').insert({
                'id': currentUser.id,
                'name': googleName ?? 'New User',
                'email': currentUser.email,
                'profile_pic': googlePhotoUrl,
              });
            }
          } catch (e) {
            if (kDebugMode) debugPrint('Google Sign-In: Failed to sync database profile: $e');
          }
        }
      }

      return true;
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
