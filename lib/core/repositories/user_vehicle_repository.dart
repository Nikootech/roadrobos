import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userVehicleRepositoryProvider = Provider((ref) => UserVehicleRepository());

class UserVehicle {
  final String id;
  final String userId;
  final String name;
  final String plate;
  final String fuel;
  final String year;
  final String type;

  UserVehicle({
    required this.id,
    required this.userId,
    required this.name,
    required this.plate,
    required this.fuel,
    required this.year,
    required this.type,
  });

  factory UserVehicle.fromMap(Map<String, dynamic> map, String id) {
    return UserVehicle(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      plate: map['plate'] ?? '',
      fuel: map['fuel'] ?? '',
      year: map['year'] ?? '',
      type: map['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'plate': plate,
      'fuel': fuel,
      'year': year,
      'type': type,
    };
  }
}

class UserVehicleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UserVehicle>> getUserVehicles(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_vehicles')
          .where('userId', isEqualTo: userId)
          .get(const GetOptions(source: Source.serverAndCache));
      return snapshot.docs.map((doc) => UserVehicle.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user vehicles: $e');
    }
  }

  Future<void> addVehicle(UserVehicle vehicle) async {
    try {
      await _firestore.collection('user_vehicles').doc(vehicle.id).set(vehicle.toMap());
    } catch (e) {
      throw Exception('Failed to add user vehicle: $e');
    }
  }
}
