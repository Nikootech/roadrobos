import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter/foundation.dart';
import '../../core/models/user_role.dart';
import '../../core/services/auth_service.dart';
import '../../core/repositories/user_repository.dart';

/// State wrapper for user data to maintain UI compatibility
class UserState {
  final AppUser? user;
  final bool isLoading;
  final bool isDemo;
  final String? error;

  UserState({
    this.user,
    this.isLoading = false,
    this.isDemo = false,
    this.error,
  });

  // Helper getters for stable UI access
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
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isDemo: isDemo ?? this.isDemo,
      error: error ?? this.error,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final AuthService _authService;
  final UserRepository _userRepository;

  UserNotifier(this._authService, this._userRepository) : super(UserState(isLoading: true)) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((sb.User? sbUser) async {
      // If we are in demo mode, ignore null auth states
      if (state.isDemo && sbUser == null) return;
      
      if (sbUser == null) {
        state = UserState(user: null, isLoading: false);
      } else {
        await fetchUserProfile(sbUser.id);
      }
    });
  }

  Future<void> loginDemo(String uid, {UserRole role = UserRole.customer}) async {
    state = state.copyWith(isLoading: true, isDemo: true);
    
    final demoUser = AppUser(
      id: uid,
      name: role == UserRole.admin ? 'System Admin' 
          : role == UserRole.superAdmin ? 'Root SuperAdmin'
          : role == UserRole.driver ? 'John Doe (Rider)'
          : role == UserRole.technician ? 'Alex Tech'
          : 'Demo Customer',
      phone: '9876543210',
      email: role == UserRole.customer ? 'demo@roadrobos.com' : '${role.name}@roadrobos.com',
      role: role,
      points: role == UserRole.customer ? 2450 : 0,
      totalRides: role == UserRole.customer ? 12 : 84,
      referralCode: 'ROAD${role.name.toUpperCase()}007',
      profilePic: 'https://ui-avatars.com/api/?name=${role.name == 'customer' ? 'Demo' : role.name}&background=random',
    );
    
    state = UserState(user: demoUser, isLoading: false, isDemo: true);
    debugPrint('loginDemo: [SAFE] State set in-memory for role: ${role.name}');
  }

  Future<void> fetchUserProfile(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final currentSupabaseUser = _authService.currentUser;
      final isDemoId = uid.startsWith('demo_');
      AppUser? user = await _userRepository.getUser(uid);

      if (user != null) {
        // Auto-sync: If the existing profile has generic data, update from OAuth metadata
        bool needsUpdate = false;
        String updatedName = user.name;
        String? updatedPic = user.profilePic;

        final oauthName = currentSupabaseUser?.userMetadata?['full_name'];
        final oauthPic = currentSupabaseUser?.userMetadata?['avatar_url'] ?? 
                        currentSupabaseUser?.userMetadata?['picture'];

        debugPrint('Supabase Auth Sync: [Name: $oauthName, Pic: $oauthPic]');

        if ((user.name == 'New User' || user.name.isEmpty) && oauthName != null) {
          updatedName = oauthName;
          needsUpdate = true;
        }

        // Update if missing or if it's a generic UI avatar (Safely check for null)
        final isGenericAvatar = user.profilePic == null || 
                               user.profilePic!.isEmpty || 
                               user.profilePic!.contains('ui-avatars.com');
                               
        if (isGenericAvatar && oauthPic != null) {
          debugPrint('Syncing Image from OAuth: $oauthPic');
          updatedPic = oauthPic;
          needsUpdate = true;
        }

        if (needsUpdate && !isDemoId) {
          user = user.copyWith(name: updatedName, profilePic: updatedPic);
          await _userRepository.saveUser(user);
        }
        
        state = state.copyWith(user: user, isLoading: false, isDemo: isDemoId);
      } else {
        // Handle case where auth exists but profile doesn't
        final oauthPic = currentSupabaseUser?.userMetadata?['avatar_url'] ?? 
                        currentSupabaseUser?.userMetadata?['picture'];

        final newUser = AppUser(
          id: uid,
          name: isDemoId ? 'Demo User' : (currentSupabaseUser?.userMetadata?['full_name'] ?? 'New User'),
          phone: isDemoId ? '9876543210' : (currentSupabaseUser?.phone ?? ''),
          email: isDemoId ? 'demo@roadrobos.com' : currentSupabaseUser?.email,
          role: UserRole.customer,
          profilePic: isDemoId ? '' : (oauthPic ?? ''),
        );
        
        // ONLY save to Supabase if NOT a demo user
        if (!isDemoId) {
          await _userRepository.saveUser(newUser);
        }
        
        state = state.copyWith(user: newUser, isLoading: false, isDemo: isDemoId);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile({String? name, String? email, String? phone}) async {
    final currentAppUser = state.user;
    if (currentAppUser == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final updatedUser = currentAppUser.copyWith(
        name: name,
        email: email,
        phone: phone,
      );
      
      // Safeguard: Do not attempt database write for Demo Users
      if (!state.isDemo) {
        await _userRepository.saveUser(updatedUser);
      }
      
      state = UserState(user: updatedUser, isLoading: false, isDemo: state.isDemo);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    state = UserState(user: null, isLoading: false);
  }

  Future<void> deleteAccountRequest() async {
    final currentAppUser = state.user;
    if (currentAppUser == null) return;

    state = state.copyWith(isLoading: true);
    try {
      if (!state.isDemo) {
        await _userRepository.updateField(currentAppUser.id, 'deletion_requested', true);
        await _userRepository.updateField(currentAppUser.id, 'deletion_requested_at', DateTime.now().toIso8601String());
      }
      await logout();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(
    ref.watch(authServiceProvider),
    ref.watch(userRepositoryProvider),
  );
});
