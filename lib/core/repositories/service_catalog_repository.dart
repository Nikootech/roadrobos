import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_item.dart';

final serviceCatalogRepositoryProvider = Provider((ref) => ServiceCatalogRepository());

class ServiceCatalogRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ServiceItem>> getServices() async {
    try {
      // Prioritize cache for fast loads, fall back to server
      final snapshot = await _firestore.collection('services').get(const GetOptions(source: Source.serverAndCache));
      return snapshot.docs.map((doc) => ServiceItem.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  Future<ServiceItem?> getServiceById(String id) async {
    try {
      final doc = await _firestore.collection('services').doc(id).get(const GetOptions(source: Source.serverAndCache));
      if (doc.exists) {
        return ServiceItem.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch service: $e');
    }
  }
}
