import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/models/user_role.dart';
import '../../core/services/auth_service.dart';
import '../../core/repositories/user_repository.dart';

/// State wrapper for user data to maintain UI compatibility
class UserState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  UserState({
    this.user,
    this.isLoading = false,
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
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
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
    _authService.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        state = UserState(user: null, isLoading: false);
      } else {
        await fetchUserProfile(firebaseUser.uid);
      }
    });
  }

  Future<void> fetchUserProfile(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _userRepository.getUser(uid);
      if (user != null) {
        state = UserState(user: user, isLoading: false);
      } else {
        // Handle case where auth exists but Firestore profile doesn't (rare)
        final newUser = AppUser(
          id: uid,
          name: _authService.currentUser?.displayName ?? 'New User',
          phone: _authService.currentUser?.phoneNumber ?? '',
          email: _authService.currentUser?.email,
          role: UserRole.customer,
        );
        await _userRepository.saveUser(newUser);
        state = UserState(user: newUser, isLoading: false);
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
      await _userRepository.saveUser(updatedUser);
      state = UserState(user: updatedUser, isLoading: false);
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
      // Log deletion request to Firestore for admin processing
      await _userRepository.updateField(currentAppUser.id, 'deletionRequested', true);
      await _userRepository.updateField(currentAppUser.id, 'deletionRequestedAt', DateTime.now().toIso8601String());
      
      // Logout the user after request
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
