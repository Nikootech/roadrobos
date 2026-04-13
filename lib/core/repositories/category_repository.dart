import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_category.dart';

final categoryRepositoryProvider = Provider((ref) => CategoryRepository());

class CategoryRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ServiceCategory>> getCategories() async {
    try {
      final response = await _supabase.from('categories').select();
      return response.map((map) => ServiceCategory.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }
}
