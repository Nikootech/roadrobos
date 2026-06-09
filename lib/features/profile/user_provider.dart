// IMPORTANT: All StreamSubscription fields must be cancelled in dispose/onDispose.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../core/models/user_role.dart';
import '../../core/repositories/user_repository.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/extensions/datetime_extensions.dart';
import '../../core/services/two_factor_auth_service.dart';

// Helper: map a loaded user's role to their home route
String _homeRouteForUser(AppUser user) {
  if (user.role.isAdmin) return '/admin-home';
  switch (user.role) {
    case UserRole.driver:
      return '/driver-home';
    case UserRole.technician:
      return '/tech-dashboard';
    default:
      return '/main/home';
  }
}

// ── Web Platform Note ─────────────────────────────────────────────────────────
// On web (Vercel), Google OAuth redirects the entire browser tab, so the
// device-ID update that normally runs after signInWithOAuth never executes.
// The device-ID session check is therefore SKIPPED on web to prevent the
// forced logout that was trapping authenticated users on the login screen.


/// State wrapper for user data to maintain UI compatibility
class UserState {
  final AppUser? user;
  final bool isLoading;
  final bool isDemo;
  final String? error;
  final bool showSessionMismatchPrompt;
  final AppUser? pendingUser;
  /// Whether TOTP 2FA is currently active for this user
  final bool mfaEnabled;

  UserState({
    this.user,
    this.isLoading = false,
    this.isDemo = false,
    this.error,
    this.showSessionMismatchPrompt = false,
    this.pendingUser,
    this.mfaEnabled = false,
  });

  // Helper getters for stable UI access
  String get id => user?.id ?? '';
  String get name => user?.name ?? 'Guest User';
  String get email => user?.email ?? '';
  String get phone => user?.phone ?? '';
  String get profileImageUrl => user?.profilePic ?? '';
  int get points => user?.points ?? 0;
  int get totalRides => user?.totalRides ?? 0;

  UserState copyWith({
    AppUser? user,
    bool? isLoading,
    bool? isDemo,
    String? error,
    bool? showSessionMismatchPrompt,
    AppUser? pendingUser,
    bool? mfaEnabled,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isDemo: isDemo ?? this.isDemo,
      error: error ?? this.error,
      showSessionMismatchPrompt: showSessionMismatchPrompt ?? this.showSessionMismatchPrompt,
      pendingUser: pendingUser ?? this.pendingUser,
      mfaEnabled: mfaEnabled ?? this.mfaEnabled,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final AuthService _authService;
  final UserRepository _userRepository;
  final Ref _ref;
  StreamSubscription<AppUser?>? _profileSubscription;
  StreamSubscription? _authSubscription;

  UserNotifier(this._authService, this._userRepository, this._ref) : super(UserState(isLoading: true)) {
    _init();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }

  void _init() {
    // Cold start: Check for an existing valid session before the stream fires
    final restoredUser = _authService.restoredUser;
    if (restoredUser != null) {
      fetchUserProfile(restoredUser.id).then((_) {
        _setupRealtimeListener(restoredUser.id);
      });
    }

    _authSubscription = _authService.authStateChanges.listen((sb.User? sbUser) async {
      // If we are in demo mode, ignore null auth states
      if (state.isDemo && sbUser == null) return;
      
      if (sbUser == null) {
        // ignore: unawaited_futures
        _profileSubscription?.cancel();
        state = UserState();
        Sentry.configureScope((scope) => scope.setUser(null));
      } else {
        // Optimization: Skip fetching if the profile for this user is already loaded
        // BUT: Re-fetch if we are missing a profile picture (to allow sync from OAuth)
        final hasProfilePic = state.user?.profilePic != null && state.user!.profilePic!.isNotEmpty;
        if (state.user?.id == sbUser.id && !state.isLoading && hasProfilePic) return;
        
        await fetchUserProfile(sbUser.id);
        _setupRealtimeListener(sbUser.id);
      }
    });
  }

  void _setupRealtimeListener(String uid) {
    if (uid.startsWith('demo_')) return;
    
    _profileSubscription?.cancel();
    _profileSubscription = _userRepository.getUserStream(uid).listen((updatedUser) async {
      if (updatedUser != null && !state.isLoading) {
        final isValid = await _checkDeviceSession(updatedUser);
        if (!isValid) return;

        // Only update if data actually changed to avoid UI flickers
        if (updatedUser.profilePic != state.user?.profilePic || 
            updatedUser.points != state.user?.points ||
            updatedUser.name != state.user?.name ||
            updatedUser.phone != state.user?.phone ||
            updatedUser.email != state.user?.email ||
            !listEquals(updatedUser.savedLocations, state.user?.savedLocations) ||
            updatedUser.currentDeviceId != state.user?.currentDeviceId) {
          state = state.copyWith(user: updatedUser);
          debugPrint('Real-time Profile Update Received: ${updatedUser.name}');
        }
      }
    });
  }

  Future<bool> _checkDeviceSession(AppUser user) async {
    if (user.id.startsWith('demo_')) return true;

    final localDeviceId = await _ref.read(localStorageServiceProvider).getLocalDeviceId();

    // If no device ID is registered yet in DB, set it automatically to current device ID
    if (user.currentDeviceId == null || user.currentDeviceId!.isEmpty) {
      if (kDebugMode) {
        debugPrint('UserNotifier: No device ID registered. Registering $localDeviceId');
      }
      await _userRepository.updateField(user.id, 'current_device_id', localDeviceId);
      return true;
    }

    if (user.currentDeviceId != localDeviceId) {
      if (kDebugMode) {
        debugPrint('UserNotifier: Device mismatch! DB DeviceID: ${user.currentDeviceId}, Local DeviceID: $localDeviceId');
      }

      // Check if we are already logged in and active on this device (meaning we were hijacked)
      if (state.user != null && state.user!.id == user.id && state.user!.currentDeviceId == localDeviceId) {
        if (kDebugMode) {
          debugPrint('UserNotifier: Active session hijacked! Forcing logout.');
        }
        await _ref.read(localStorageServiceProvider).setMultiDeviceLogout(true);
        await logout();
        return false;
      }

      // Otherwise, this is a login or cold-start attempt on a new device. Prompt the user!
      state = state.copyWith(
        isLoading: false,
        showSessionMismatchPrompt: true,
        pendingUser: user,
      );
      return false;
    }
    return true;
  }

  Future<void> confirmSessionTakeover() async {
    final pending = state.pendingUser;
    if (pending == null) return;

    state = UserState(isLoading: true, isDemo: state.isDemo);
    try {
      final localDeviceId = await _ref.read(localStorageServiceProvider).getLocalDeviceId();
      await _userRepository.updateField(pending.id, 'current_device_id', localDeviceId);
      
      final updatedUser = pending.copyWith(currentDeviceId: localDeviceId);
      state = UserState(
        user: updatedUser,
        isDemo: state.isDemo,
      );
      
      // Resume notifications sync
      unawaited(NotificationService().syncTokenToBackend(pending.id));
    } catch (e) {
      state = UserState(
        isDemo: state.isDemo,
        error: e.toString(),
      );
    }
  }

  Future<void> cancelSessionTakeover() async {
    state = UserState(
      user: state.user,
      isDemo: state.isDemo,
    );
    await logout();
  }



  Future<void> fetchUserProfile(String uid) async {
    state = state.copyWith(isLoading: true);
    if (kDebugMode) {
      debugPrint('UserNotifier: fetchUserProfile started for uid=$uid');
    }
    try {
      final currentSupabaseUser = _authService.currentUser;
      final isDemoId = uid.startsWith('demo_');
      
      if (kDebugMode) {
        debugPrint('UserNotifier: Fetching user profile from repository...');
      }
      AppUser? user = await _userRepository.getUser(uid);
      if (kDebugMode) {
        debugPrint('UserNotifier: getUser returned user=${user?.name} (id=${user?.id}, role=${user?.role})');
      }

      if (user != null) {
        final isValid = await _checkDeviceSession(user);
        if (!isValid) return;

        // Auto-sync: If the existing profile has generic data, update from OAuth metadata
        bool needsUpdate = false;
        String updatedName = user.name;
        String? updatedPic = user.profilePic;

        final oauthName = currentSupabaseUser?.userMetadata?['full_name'] ?? 
                         currentSupabaseUser?.userMetadata?['name'];
        final oauthPic = currentSupabaseUser?.userMetadata?['avatar_url'] ?? 
                        currentSupabaseUser?.userMetadata?['picture'] ?? 
                        currentSupabaseUser?.userMetadata?['image'] ?? 
                        currentSupabaseUser?.userMetadata?['photo_url'];

        if (kDebugMode) {
          debugPrint('UserNotifier: Supabase Auth Sync: [OAuth Name: $oauthName, OAuth Pic: $oauthPic]');
        }

        // Update name if it's missing or generic
        if ((user.name == 'New User' || user.name.isEmpty || user.name == 'Demo Customer') && oauthName != null) {
          updatedName = oauthName;
          needsUpdate = true;
        }

        // Update phone if it's missing (sync from Supabase Auth if available)
        final authPhone = currentSupabaseUser?.phone;
        if ((user.phone == '' || user.phone == '9876543210') && authPhone != null && authPhone.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('UserNotifier: Syncing Phone from Auth: $authPhone');
          }
          user = user.copyWith(phone: authPhone);
          needsUpdate = true;
        }

        // Update if missing or if it's a generic UI avatar
        final isGenericAvatar = user.profilePic == null || 
                               user.profilePic!.isEmpty || 
                               user.profilePic!.contains('ui-avatars.com');

        if (isGenericAvatar && oauthPic != null) {
          if (kDebugMode) {
            debugPrint('UserNotifier: Syncing Image from OAuth: $oauthPic');
          }
          updatedPic = oauthPic;
          needsUpdate = true;
        }

        // Optimization: Only write to database if data actually changed
        final changesDetected = updatedName != user.name || updatedPic != user.profilePic;
        if (kDebugMode) {
          debugPrint('UserNotifier: Sync check - needsUpdate=$needsUpdate, changesDetected=$changesDetected, isDemoId=$isDemoId');
        }
        if (needsUpdate && changesDetected && !isDemoId) {
          user = user.copyWith(name: updatedName, profilePic: updatedPic);
          if (kDebugMode) {
            debugPrint('UserNotifier: Saving updated profile to database: ${user.toMap()}');
          }
          await _userRepository.saveUser(user);
          if (kDebugMode) {
            debugPrint('UserNotifier: Save profile successful.');
          }
        }
        
        // Load mfa_enabled from the profiles DB row
        bool mfaEnabledFromDb = false;
        if (!isDemoId) {
          try {
            final mfaRow = await sb.Supabase.instance.client
                .from('profiles')
                .select('mfa_enabled')
                .eq('id', uid)
                .maybeSingle();
            mfaEnabledFromDb = (mfaRow?['mfa_enabled'] as bool?) ?? false;
          } catch (_) {}
        }
        state = state.copyWith(user: user, isLoading: false, isDemo: isDemoId, mfaEnabled: mfaEnabledFromDb);
        
        // Cache the home route for instant redirect on next splash
        if (!isDemoId) {
          final route = _homeRouteForUser(user);
          unawaited(_ref.read(localStorageServiceProvider).saveLastHomeRoute(route));
        }
        
        // Sync FCM token to backend (P0 Integration)
        if (!isDemoId) {
          // ignore: unawaited_futures
          NotificationService().syncTokenToBackend(uid);
        }
      } else {
        if (kDebugMode) {
          debugPrint('UserNotifier: Profile is null. Creating new profile for uid=$uid');
        }
        // Handle case where auth exists but profile doesn't
        final oauthName = currentSupabaseUser?.userMetadata?['full_name'] ?? 
                         currentSupabaseUser?.userMetadata?['name'] ?? 'New User';
        final oauthPic = currentSupabaseUser?.userMetadata?['avatar_url'] ?? 
                        currentSupabaseUser?.userMetadata?['picture'] ?? 
                        currentSupabaseUser?.userMetadata?['image'] ??
                        currentSupabaseUser?.userMetadata?['photo_url'];

        final newUser = AppUser(
          id: uid,
          name: isDemoId ? 'Demo User' : oauthName,
          phone: isDemoId ? '9876543210' : (currentSupabaseUser?.phone ?? ''),
          email: isDemoId ? 'demo@roadrobos.com' : currentSupabaseUser?.email,
          role: UserRole.customer,
          profilePic: isDemoId ? '' : (oauthPic ?? ''),
        );
        
        // ONLY save to Supabase if NOT a demo user
        if (!isDemoId) {
          if (kDebugMode) {
            debugPrint('UserNotifier: Saving new user profile to database: ${newUser.toMap()}');
          }
          await _userRepository.saveUser(newUser);
          if (kDebugMode) {
            debugPrint('UserNotifier: Save new profile successful.');
          }
        }
        
        state = state.copyWith(user: newUser, isLoading: false, isDemo: isDemoId);

        // Cache the home route for instant redirect on next splash
        if (!isDemoId) {
          final route = _homeRouteForUser(newUser);
          unawaited(_ref.read(localStorageServiceProvider).saveLastHomeRoute(route));
        }
      }
      if (state.user != null) {
        final u = state.user!;
        Sentry.configureScope((scope) => scope.setUser(SentryUser(id: u.id, email: u.email)));
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('UserNotifier: ERROR in fetchUserProfile: $e');
        debugPrint('UserNotifier: StackTrace: $stackTrace');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile({String? name, String? email, String? phone}) async {
    final currentAppUser = state.user;
    if (currentAppUser == null) return;

    // Reset error state before attempt
    state = state.copyWith(isLoading: true);
    try {
      final updatedUser = currentAppUser.copyWith(
        name: name,
        email: email,
        phone: phone,
      );
      
      debugPrint('Updating Profile: [Name: ${updatedUser.name}, Phone: ${updatedUser.phone}, Email: ${updatedUser.email}]');
      
      // Safeguard: Do not attempt database write for Demo Users
      if (!state.isDemo) {
        await _userRepository.saveUser(updatedUser);
        debugPrint('Profile saved to database successfully.');
      }
      
      state = state.copyWith(user: updatedUser, isLoading: false);
    } catch (e) {
      debugPrint('Profile Update Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    // Clear the cached home route so the next user doesn't get a stale redirect
    unawaited(_ref.read(localStorageServiceProvider).clearLastHomeRoute());
    state = UserState();
    Sentry.configureScope((scope) => scope.setUser(null));
  }

  Future<void> deleteAccountRequest() async {
    final currentAppUser = state.user;
    if (currentAppUser == null) return;

    state = state.copyWith(isLoading: true);
    try {
      if (!state.isDemo) {
        await _userRepository.updateField(currentAppUser.id, 'deletion_requested', true);
        await _userRepository.updateField(currentAppUser.id, 'deletion_requested_at', DateTime.now().utcIso);
      }
      await logout();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── 2FA helpers ──────────────────────────────────────────────────────────────

  /// Called after successful TOTP enrollment + verification.
  /// Marks `mfa_enabled = true` in DB and refreshes local state.
  Future<void> enable2FA() async {
    final uid = state.user?.id;
    if (uid == null || state.isDemo) return;
    try {
      await _ref.read(twoFactorAuthServiceProvider).markMfaEnabledInProfile(uid);
      state = state.copyWith(mfaEnabled: true);
      debugPrint('UserNotifier: 2FA enabled for user $uid');
    } catch (e) {
      debugPrint('UserNotifier.enable2FA error: $e');
    }
  }

  /// Called after unenrolling TOTP factor.
  /// Marks `mfa_enabled = false` in DB and refreshes local state.
  Future<void> disable2FA() async {
    final uid = state.user?.id;
    if (uid == null || state.isDemo) return;
    try {
      await _ref.read(twoFactorAuthServiceProvider).markMfaDisabledInProfile(uid);
      state = state.copyWith(mfaEnabled: false);
      debugPrint('UserNotifier: 2FA disabled for user $uid');
    } catch (e) {
      debugPrint('UserNotifier.disable2FA error: $e');
    }
  }

  Future<void> pickAndUploadProfilePicture([ImageSource source = ImageSource.gallery]) async {
    final currentAppUser = state.user;
    if (currentAppUser == null) return;

    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      state = state.copyWith(isLoading: true);

      final bytes = await image.readAsBytes();
      final extension = image.path.split('.').last.toLowerCase();

      final publicUrl = await _userRepository.uploadProfilePicture(
        currentAppUser.id, 
        bytes, 
        extension.isEmpty ? 'jpg' : extension
      );

      // Update Database
      await _userRepository.updateField(currentAppUser.id, 'profile_pic', publicUrl);
      
      // Update State immediately for real-time UI feel
      final updatedUser = currentAppUser.copyWith(profilePic: publicUrl);
      state = state.copyWith(user: updatedUser, isLoading: false);
      
      debugPrint('Profile Picture Uploaded & State Updated: $publicUrl');
    } catch (e) {
      debugPrint('Upload Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    ref.watch(authServiceProvider),
    ref.watch(userRepositoryProvider),
    ref,
  );
});
