import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserState {
  final String name;
  final String email;
  final String phone;
  final String profileImageUrl;
  final bool isLoading;

  final int points;
  final int totalRides;

  UserState({
    this.name = 'Rahul Sharma',
    this.email = 'rahul.s@example.com',
    this.phone = '+91 98765 43210',
    this.profileImageUrl = 'https://i.pravatar.cc/300',
    this.points = 1250,
    this.totalRides = 48,
    this.isLoading = false,
  });

  UserState copyWith({
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    int? points,
    int? totalRides,
    bool? isLoading,
  }) {
    return UserState(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      points: points ?? this.points,
      totalRides: totalRides ?? this.totalRides,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(UserState());

  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true);
    
    // Simulate API/Supabase call
    await Future.delayed(const Duration(seconds: 1));
    
    state = state.copyWith(
      name: name ?? state.name,
      email: email ?? state.email,
      phone: phone ?? state.phone,
      isLoading: false,
    );
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
