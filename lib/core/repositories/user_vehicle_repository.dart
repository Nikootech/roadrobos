import 'package:supabase_flutter/supabase_flutter.dart';
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
      userId: map['user_id'] ?? map['userId'] ?? '',
      name: map['name'] ?? '',
      plate: map['plate'] ?? '',
      fuel: map['fuel'] ?? '',
      year: map['year'] ?? '',
      type: map['type'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'plate': plate,
      'fuel': fuel,
      'year': year,
      'type': type,
    };
  }
}

class UserVehicleRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserVehicle>> getUserVehicles(String userId) async {
    try {
      final response = await _supabase
          .from('user_vehicles')
          .select()
          .eq('user_id', userId);
      return response.map((map) => UserVehicle.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch user vehicles: $e');
    }
  }

  Future<void> addVehicle(UserVehicle vehicle) async {
    try {
      await _supabase.from('user_vehicles').insert(vehicle.toMap());
    } catch (e) {
      throw Exception('Failed to add user vehicle: $e');
    }
  }
}
