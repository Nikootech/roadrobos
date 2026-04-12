import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rental_vehicle.dart';

final rentalCatalogRepositoryProvider = Provider((ref) => RentalCatalogRepository());

class RentalCatalogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<RentalVehicle>> getRentalFleet() async {
    try {
      final snapshot = await _firestore.collection('rental_fleet').get(const GetOptions(source: Source.serverAndCache));
      return snapshot.docs.map((doc) => RentalVehicle.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch rental fleet: $e');
    }
  }

  Future<List<RentalVehicle>> getBikesOnly() async {
    try {
      final snapshot = await _firestore
          .collection('rental_fleet')
          .where('isBike', isEqualTo: true)
          .get(const GetOptions(source: Source.serverAndCache));
      return snapshot.docs.map((doc) => RentalVehicle.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch rental bikes: $e');
    }
  }

  Future<List<RentalVehicle>> getCarsOnly() async {
    try {
      final snapshot = await _firestore
          .collection('rental_fleet')
          .where('isBike', isEqualTo: false)
          .get(const GetOptions(source: Source.serverAndCache));
      return snapshot.docs.map((doc) => RentalVehicle.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch rental cars: $e');
    }
  }
}
