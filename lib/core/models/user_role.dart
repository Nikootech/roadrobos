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
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory AppUser.customer({required String id, required String name, required String phone}) {
    return AppUser(id: id, name: name, phone: phone, role: UserRole.customer);
  }

  factory AppUser.empty() {
    return const AppUser(id: '', name: 'Guest', phone: '', role: UserRole.customer);
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? phone,
    UserRole? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
    );
  }
}
