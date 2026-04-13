enum UserRole {
  customer,
  driver,
  technician,
  admin,
  superAdmin,
}

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? profilePic;
  final DateTime? createdAt;
  
  // Stats & Loyalty (from old mock state)
  final int points;
  final int totalRides;
  final List<String> emergencyContacts;
  final String referralCode;

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
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      name: map['name'] ?? 'Unknown User',
      phone: map['phone'] ?? '',
      email: map['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.customer,
      ),
      profilePic: map['profile_pic'],
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      points: map['points'] ?? 0,
      totalRides: map['total_rides'] ?? 0,
      emergencyContacts: List<String>.from(map['emergency_contacts'] ?? []),
      referralCode: map['referral_code'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.toString().split('.').last,
      'profile_pic': profilePic,
      'created_at': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'points': points,
      'total_rides': totalRides,
      'emergency_contacts': emergencyContacts,
      'referral_code': referralCode,
    };
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
    );
  }
}
