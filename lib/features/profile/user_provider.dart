import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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
        // Optimization: Skip fetching if the profile for this user is already loaded
        // BUT: Re-fetch if we are missing a profile picture (to allow sync from OAuth)
        final hasProfilePic = state.user?.profilePic != null && state.user!.profilePic!.isNotEmpty;
        if (state.user?.id == sbUser.id && !state.isLoading && hasProfilePic) return;
        
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

        final oauthName = currentSupabaseUser?.userMetadata?['full_name'] ?? 
                         currentSupabaseUser?.userMetadata?['name'];
        final oauthPic = currentSupabaseUser?.userMetadata?['avatar_url'] ?? 
                        currentSupabaseUser?.userMetadata?['picture'] ?? 
                        currentSupabaseUser?.userMetadata?['image'] ?? 
                        currentSupabaseUser?.userMetadata?['photo_url'];

        debugPrint('Supabase Auth Sync: [OAuth Name: $oauthName, OAuth Pic: $oauthPic]');

        // Update name if it's missing or generic
        if ((user.name == 'New User' || user.name.isEmpty || user.name == 'Demo Customer') && oauthName != null) {
          updatedName = oauthName;
          needsUpdate = true;
        }

        // Update phone if it's missing (sync from Supabase Auth if available)
        final authPhone = currentSupabaseUser?.phone;
        if ((user.phone == '' || user.phone == '9876543210') && authPhone != null && authPhone.isNotEmpty) {
          debugPrint('Syncing Phone from Auth: $authPhone');
          user = user.copyWith(phone: authPhone);
          needsUpdate = true;
        }

        // Update if missing or if it's a generic UI avatar
        final isGenericAvatar = user.profilePic == null || 
                               user.profilePic!.isEmpty || 
                               user.profilePic!.contains('ui-avatars.com');

        if (isGenericAvatar && oauthPic != null) {
          debugPrint('Syncing Image from OAuth: $oauthPic');
          updatedPic = oauthPic;
          needsUpdate = true;
        }

        // Optimization: Only write to database if data actually changed
        final changesDetected = updatedName != user.name || updatedPic != user.profilePic;
        if (needsUpdate && changesDetected && !isDemoId) {
          user = user.copyWith(name: updatedName, profilePic: updatedPic);
          await _userRepository.saveUser(user);
        }
        
        state = state.copyWith(user: user, isLoading: false, isDemo: isDemoId);
      } else {
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

    // Reset error state before attempt
    state = state.copyWith(isLoading: true, error: null);
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
      
      state = state.copyWith(user: updatedUser, isLoading: false, error: null);
    } catch (e) {
      debugPrint('Profile Update Error: $e');
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

  Future<void> pickAndUploadProfilePicture() async {
    final currentAppUser = state.user;
    if (currentAppUser == null) return;

    final ImagePicker picker = ImagePicker();
    
    try {
      // Pick image (Camera/Gallery selection usually handled by UI or by default here)
      // For simplicity in this logic, we use standard picking. 
      // The UI can specify source to this method instead if preferred.
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery, // Default to gallery for reliability on all platforms
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image == null) return;

      state = state.copyWith(isLoading: true, error: null);

      final bytes = await image.readAsBytes();
      final extension = image.path.split('.').last.toLowerCase();

      final publicUrl = await _userRepository.uploadProfilePicture(
        currentAppUser.id, 
        bytes, 
        extension.isEmpty ? 'jpg' : extension
      );

      // Update Database
      await _userRepository.updateField(currentAppUser.id, 'profile_pic', publicUrl);
      
      // Update State
      final updatedUser = currentAppUser.copyWith(profilePic: publicUrl);
      state = state.copyWith(user: updatedUser, isLoading: false);
      
      debugPrint('Profile Picture Uploaded: $publicUrl');
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
  );
});
