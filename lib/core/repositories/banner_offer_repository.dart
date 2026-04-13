import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/banner_offer.dart';

final bannerOfferRepositoryProvider = Provider((ref) => BannerOfferRepository());

class BannerOfferRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<BannerOffer>> getActiveBanners() async {
    try {
      final response = await _supabase.from('banners').select();
      return response.map((map) => BannerOffer.fromMap(map, map['id'].toString())).toList();
    } catch (e) {
      throw Exception('Failed to fetch banners: $e');
    }
  }
}
