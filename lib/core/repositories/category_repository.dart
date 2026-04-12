import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_category.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ServiceCategory>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get(const GetOptions(source: Source.serverAndCache));
      return snapshot.docs.map((doc) => ServiceCategory.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
