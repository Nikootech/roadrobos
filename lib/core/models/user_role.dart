enum UserRole {
  customer,
  driver,
  technician,
  admin,
  superAdmin,
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
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      name: map['name'] ?? 'Unknown User',
      phone: map['phone'] ?? map['phone_number'] ?? map['mobile'] ?? '',
      email: map['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${map['role']}',
        orElse: () => UserRole.customer,
      ),
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.toString().split('.').last,
      'profile_pic': profilePic,
      // Note: Other fields like saved_locations, points, etc. are currently 
      // managed locally or in separate tables to avoid profiles schema errors.
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
    List<SavedLocation>? savedLocations,
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
    );
  }
}
