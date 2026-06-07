import 'package:shared_preferences/shared_preferences.dart';

enum UserRole {
  customer,
  driver,
  technician,
  superAdmin,
  founderAdmin,
  opsHead,
  cityManager,
  areaManager,
  financeManager,
  supportManager,
  marketingAdmin,
  auditor,
  analyst,
  admin, // Legacy support
}

class SavedLocation {
  final String id;
  final String title;
  final String address;
  final double? latitude;
  final double? longitude;

  const SavedLocation({
    required this.id,
    required this.title,
    required this.address,
    this.latitude,
    this.longitude,
  });

  factory SavedLocation.fromMap(Map<String, dynamic> map) {
    return SavedLocation(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      address: map['address'] ?? '',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? profilePic;
  final DateTime? createdAt;
  final String kycStatus;
  
  // Stats & Loyalty
  final int points;
  final int totalRides;
  final List<String> emergencyContacts;
  final String referralCode;
  final List<SavedLocation> savedLocations;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.profilePic,
    this.createdAt,
    this.points = 0,
    this.totalRides = 0,
    this.emergencyContacts = const [],
    this.referralCode = '',
    this.savedLocations = const [],
    this.kycStatus = 'not_started',
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      name: map['name'] ?? 'Unknown User',
      phone: map['phone'] ?? map['phone_number'] ?? map['mobile'] ?? '',
      email: map['email'],
      role: _parseRole(map['role']),
      profilePic: map['profile_pic'] ?? map['avatar_url'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      points: map['points'] ?? 0,
      totalRides: map['total_rides'] ?? 0,
      emergencyContacts: List<String>.from(map['emergency_contacts'] ?? []),
      referralCode: map['referral_code'] ?? '',
      savedLocations: (map['saved_locations'] as List?)
              ?.map((x) => SavedLocation.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      kycStatus: map['kyc_status'] ?? 'not_started',
    );
  }

  static UserRole _parseRole(String? role) {
    if (role == null) return UserRole.customer;
    final normalized = role.toLowerCase().replaceAll('_', '');
    return UserRole.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => UserRole.customer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': _roleToDb(role),
      'profile_pic': profilePic,
    };
  }

  static String _roleToDb(UserRole role) {
    switch (role) {
      case UserRole.superAdmin: return 'super_admin';
      case UserRole.founderAdmin: return 'founder_admin';
      case UserRole.opsHead: return 'ops_head';
      case UserRole.cityManager: return 'city_manager';
      case UserRole.areaManager: return 'area_manager';
      case UserRole.financeManager: return 'finance_manager';
      case UserRole.supportManager: return 'support_manager';
      case UserRole.marketingAdmin: return 'marketing_admin';
      default: return role.name;
    }
  }

  factory AppUser.empty() {
    return const AppUser(id: '', name: 'Guest User', phone: '', role: UserRole.customer);
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? profilePic,
    DateTime? createdAt,
    int? points,
    int? totalRides,
    List<String>? emergencyContacts,
    String? referralCode,
    List<SavedLocation>? savedLocations,
    String? kycStatus,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePic: profilePic ?? this.profilePic,
      createdAt: createdAt ?? this.createdAt,
      points: points ?? this.points,
      totalRides: totalRides ?? this.totalRides,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      referralCode: referralCode ?? this.referralCode,
      savedLocations: savedLocations ?? this.savedLocations,
      kycStatus: kycStatus ?? this.kycStatus,
    );
  }
}

extension UserRoleExtension on UserRole {
  bool get isAdmin => [
    UserRole.admin,
    UserRole.superAdmin,
    UserRole.founderAdmin,
    UserRole.opsHead,
    UserRole.cityManager,
    UserRole.areaManager,
    UserRole.financeManager,
    UserRole.supportManager,
    UserRole.marketingAdmin,
  ].contains(this);

  bool get isFieldStaff => [
    UserRole.driver,
    UserRole.technician,
  ].contains(this);

  Future<bool> hasPermission(String permission) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList('user_permissions') ?? [];
    return cached.contains(permission);
  }
}
