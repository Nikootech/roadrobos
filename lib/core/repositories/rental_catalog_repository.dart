import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rental_vehicle.dart';

final rentalCatalogRepositoryProvider = Provider((ref) => RentalCatalogRepository());

class RentalCatalogRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<RentalVehicle>> getRentalFleet() async {
    try {
      final response = await _supabase.from('rental_vehicles').select();
      return response.map((map) => RentalVehicle.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch rental fleet: $e');
    }
  }

  Future<List<RentalVehicle>> getBikesOnly() async {
    try {
      final response = await _supabase
          .from('rental_vehicles')
          .select()
          .eq('is_bike', true);
      return response.map((map) => RentalVehicle.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch rental bikes: $e');
    }
  }

  Future<List<RentalVehicle>> getCarsOnly() async {
    try {
      final response = await _supabase
          .from('rental_vehicles')
          .select()
          .eq('is_bike', false);
      return response.map((map) => RentalVehicle.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch rental cars: $e');
    }
  }
}
