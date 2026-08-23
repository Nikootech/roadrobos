// All permissions are compile-time constants.
// The shared_preferences import was removed (S4 security fix):
// permission checks must never rely on client-modifiable storage.

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
  final String? currentDeviceId;
  final bool isApproved;

  // Stats & Loyalty
  final int points;
  final int totalRides;
  final List<String> emergencyContacts;
  final String referralCode;
  final List<SavedLocation> savedLocations;
  final String? cityId;
  final String? zoneId;
  final Map<String, dynamic> notificationPreferences;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.profilePic,
    this.createdAt,
    this.cityId,
    this.zoneId,
    this.points = 0,
    this.totalRides = 0,
    this.emergencyContacts = const [],
    this.referralCode = '',
    this.savedLocations = const [],
    this.kycStatus = 'not_started',
    this.currentDeviceId,
    this.isApproved = true,
    this.notificationPreferences = const {
      'push': true,
      'email': true,
      'sms': false,
      'whatsapp': true,
      'rides': true,
      'offers': true,
      'maintenance': true,
      'wallet': false,
      'quiet': false,
      'sound': true
    },
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      name: map['name'] ?? 'Unknown User',
      phone: map['phone'] ?? map['phone_number'] ?? map['mobile'] ?? '',
      email: map['email'],
      role: _parseRole(map['role']),
      profilePic: map['profile_pic'] ?? map['avatar_url'],
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      cityId: map['city_id'],
      zoneId: map['zone_id'],
      points: map['points'] ?? 0,
      totalRides: map['total_rides'] ?? 0,
      emergencyContacts: List<String>.from(map['emergency_contacts'] ?? []),
      referralCode: map['referral_code'] ?? '',
      savedLocations: (map['saved_locations'] as List?)
              ?.map((x) => SavedLocation.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      kycStatus: map['kyc_status'] ?? 'not_started',
      currentDeviceId: map['current_device_id'],
      isApproved: map['is_approved'] ?? true,
      notificationPreferences:
          Map<String, dynamic>.from(map['notification_preferences'] ??
              {
                'push': true,
                'email': true,
                'sms': false,
                'whatsapp': true,
                'rides': true,
                'offers': true,
                'maintenance': true,
                'wallet': false,
                'quiet': false,
                'sound': true
              }),
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
      'city_id': cityId,
      'zone_id': zoneId,
      'current_device_id': currentDeviceId,
      'is_approved': isApproved,
      'saved_locations': savedLocations.map((x) => x.toMap()).toList(),
      'notification_preferences': notificationPreferences,
    };
  }

  static String _roleToDb(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.founderAdmin:
        return 'founder_admin';
      case UserRole.opsHead:
        return 'ops_head';
      case UserRole.cityManager:
        return 'city_manager';
      case UserRole.areaManager:
        return 'area_manager';
      case UserRole.financeManager:
        return 'finance_manager';
      case UserRole.supportManager:
        return 'support_manager';
      case UserRole.marketingAdmin:
        return 'marketing_admin';
      default:
        return role.name;
    }
  }

  factory AppUser.empty() {
    return const AppUser(
        id: '', name: 'Guest User', phone: '', role: UserRole.customer);
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? profilePic,
    DateTime? createdAt,
    String? cityId,
    String? zoneId,
    int? points,
    int? totalRides,
    List<String>? emergencyContacts,
    String? referralCode,
    List<SavedLocation>? savedLocations,
    String? kycStatus,
    String? currentDeviceId,
    bool? isApproved,
    Map<String, dynamic>? notificationPreferences,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePic: profilePic ?? this.profilePic,
      createdAt: createdAt ?? this.createdAt,
      cityId: cityId ?? this.cityId,
      zoneId: zoneId ?? this.zoneId,
      points: points ?? this.points,
      totalRides: totalRides ?? this.totalRides,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      referralCode: referralCode ?? this.referralCode,
      savedLocations: savedLocations ?? this.savedLocations,
      kycStatus: kycStatus ?? this.kycStatus,
      currentDeviceId: currentDeviceId ?? this.currentDeviceId,
      isApproved: isApproved ?? this.isApproved,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }
}

extension UserRoleExtension on UserRole {
  // -- Role groupings -------------------------------------------------------

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
        UserRole.auditor,
        UserRole.analyst,
      ].contains(this);

  bool get isFieldStaff => [
        UserRole.driver,
        UserRole.technician,
      ].contains(this);

  bool get isEmployee => this != UserRole.customer && this != UserRole.driver;

  // -- Read-only roles ------------------------------------------------------

  /// Auditor and analyst roles are strictly read-only.
  /// All write action buttons must be hidden when this is true. (Fix S1/S6)
  bool get isReadOnly => this == UserRole.auditor || this == UserRole.analyst;

  // -- Permission gates (compile-time, no async I/O) ------------------------
  // SECURITY: Replaces the removed SharedPreferences-based hasPermission()
  // (Fix S4). Client-side permission storage is tamper-prone; compile-time
  // role checks are the only safe gate for UI-level access control.

  /// Can see revenue, payouts, and financial KPIs.
  bool get canAccessFinancials => [
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.admin,
        UserRole.financeManager,
        UserRole.auditor,
        UserRole.analyst,
      ].contains(this);

  /// Can see and act on emergency SOS alerts.
  bool get canSeeEmergencies => [
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.admin,
        UserRole.opsHead,
        UserRole.cityManager,
        UserRole.areaManager,
        UserRole.supportManager,
      ].contains(this);

  /// Can dispatch technicians and manage service jobs.
  bool get canDispatch => [
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.admin,
        UserRole.opsHead,
        UserRole.cityManager,
        UserRole.areaManager,
      ].contains(this);

  /// Can approve drivers, staff, and KYC requests.
  bool get canApprove => [
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.admin,
        UserRole.opsHead,
        UserRole.cityManager,
        UserRole.areaManager,
      ].contains(this);

  /// Can see and manage offers, campaigns, and referrals.
  bool get canAccessMarketing => [
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.admin,
        UserRole.marketingAdmin,
      ].contains(this);

  /// Can see audit log feeds and compliance data.
  bool get canAccessAudit => [
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.admin,
        UserRole.auditor,
        UserRole.analyst,
      ].contains(this);

  /// Can see analytics dashboards, reports, and data exports.
  bool get canAccessAnalytics => [
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.admin,
        UserRole.analyst,
        UserRole.opsHead,
        UserRole.financeManager,
        UserRole.cityManager,
        UserRole.areaManager,
      ].contains(this);

  /// Can manage system settings, RBAC, and staff permissions.
  bool get canManageSystem => [
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.admin,
      ].contains(this);

  /// Can handle support tickets, disputes, and feedback.
  bool get canHandleSupport => [
        UserRole.superAdmin,
        UserRole.founderAdmin,
        UserRole.admin,
        UserRole.supportManager,
        UserRole.opsHead,
      ].contains(this);

  // -- UI helpers ------------------------------------------------------------

  /// Human-readable badge label shown in the dashboard AppBar. (Fix S3)
  String get roleLabel {
    return switch (this) {
      UserRole.superAdmin     => 'SUPER ADMIN',
      UserRole.founderAdmin   => 'FOUNDER',
      UserRole.opsHead        => 'OPS COMMAND',
      UserRole.cityManager    => 'CITY MANAGER',
      UserRole.areaManager    => 'AREA MANAGER',
      UserRole.financeManager => 'FINANCE CONSOLE',
      UserRole.supportManager => 'SUPPORT HUB',
      UserRole.marketingAdmin => 'MARKETING HUB',
      UserRole.auditor        => 'AUDIT VIEW',
      UserRole.analyst        => 'ANALYTICS',
      UserRole.admin          => 'ADMIN CONSOLE',
      UserRole.driver         => 'DRIVER',
      UserRole.technician     => 'TECHNICIAN',
      UserRole.customer       => 'CUSTOMER',
    };
  }
}
