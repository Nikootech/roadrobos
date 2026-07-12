import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_item.dart';

final serviceCatalogRepositoryProvider =
    Provider((ref) => ServiceCatalogRepository());

class ServiceCatalogRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ServiceItem>> getServices() async {
    try {
      final response = await _supabase.from('services').select();
      return response
          .map((map) => ServiceItem.fromMap(map, map['id'].toString()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch services: $e');
    }
  }

  Future<ServiceItem?> getServiceById(String id) async {
    try {
      final response =
          await _supabase.from('services').select().eq('id', id).maybeSingle();

      if (response != null) {
        return ServiceItem.fromMap(response, response['id'].toString());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch service: $e');
    }
  }
}
