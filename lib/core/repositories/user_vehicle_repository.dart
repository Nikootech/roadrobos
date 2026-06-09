import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userVehicleRepositoryProvider = Provider((ref) => UserVehicleRepository());

class UserVehicle {
  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String plateNumber;
  final String vehicleType;
  final bool isPrimary;
  final DateTime? createdAt;
  final DateTime? deletedAt;

  UserVehicle({
    required this.id,
    required this.userId,
    String make = '',
    this.model = '',
    dynamic year = 2020,
    String plateNumber = '',
    String vehicleType = 'car',
    this.isPrimary = false,
    this.createdAt,
    this.deletedAt,
    // Legacy named parameters for backward compatibility
    String? name,
    String? plate,
    String? fuel,
    String? type,
  })  : make = make.isNotEmpty ? make : (name ?? ''),
        year = year is int ? year : (int.tryParse(year.toString()) ?? 2020),
        plateNumber = plateNumber.isNotEmpty ? plateNumber : (plate ?? ''),
        vehicleType = vehicleType.isNotEmpty ? vehicleType : (type ?? 'car');

  factory UserVehicle.fromMap(Map<String, dynamic> map, String id) {
    return UserVehicle(
      id: id,
      userId: map['user_id'] ?? map['userId'] ?? '',
      make: map['make'] ?? map['name'] ?? '',
      model: map['model'] ?? '',
      year: map['year'] is int ? map['year'] : int.tryParse(map['year'].toString()) ?? 2020,
      plateNumber: map['plate_number'] ?? map['plateNumber'] ?? map['plate'] ?? '',
      vehicleType: map['vehicle_type'] ?? map['vehicleType'] ?? map['type'] ?? 'car',
      isPrimary: map['is_primary'] ?? map['isPrimary'] ?? false,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      deletedAt: map['deleted_at'] != null ? DateTime.tryParse(map['deleted_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'make': make,
      'model': model,
      'year': year,
      'plate_number': plateNumber,
      'vehicle_type': vehicleType,
      'is_primary': isPrimary,
      if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
      if (deletedAt != null) 'deleted_at': deletedAt!.toUtc().toIso8601String(),
    };
  }

  // Getters for backward compatibility
  String get name => make.isNotEmpty && model.isNotEmpty ? '$make $model' : make;
  String get plate => plateNumber;
  String get fuel => 'Petrol';
  String get type => vehicleType;

  UserVehicle copyWith({
    String? id,
    String? userId,
    String? make,
    String? model,
    int? year,
    String? plateNumber,
    String? vehicleType,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? deletedAt,
  }) {
    return UserVehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

class UserVehicleRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<UserVehicle>> getUserVehicles(String userId) async {
    try {
      final response = await _supabase
          .from('user_vehicles')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null);
      
      return response.map<UserVehicle>((map) => UserVehicle.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      if (e.toString().contains('404')) {
        return [];
      }
      return [];
    }
  }

  Stream<List<UserVehicle>> getUserVehiclesStream(String userId) {
    return _supabase
        .from('user_vehicles')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          return data
              .where((map) => map['deleted_at'] == null)
              .map<UserVehicle>((map) => UserVehicle.fromMap(map, map['id'].toString()))
              .toList();
        });
  }

  Future<void> addVehicle(UserVehicle vehicle) async {
    try {
      final map = vehicle.toMap();
      if (vehicle.id.isEmpty) {
        map.remove('id');
      }
      await _supabase.from('user_vehicles').insert(map);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateVehicle(UserVehicle vehicle) async {
    try {
      await _supabase
          .from('user_vehicles')
          .update(vehicle.toMap())
          .eq('id', vehicle.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> setPrimaryVehicle(String userId, String vehicleId) async {
    try {
      await _supabase
          .from('user_vehicles')
          .update({'is_primary': false})
          .eq('user_id', userId);

      await _supabase
          .from('user_vehicles')
          .update({'is_primary': true})
          .eq('id', vehicleId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    try {
      await _supabase
          .from('user_vehicles')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', vehicleId);
    } catch (e) {
      rethrow;
    }
  }
}
