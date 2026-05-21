import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/banner_offer.dart';
import '../data/local_database.dart';
import 'package:drift/drift.dart' as drift;

final bannerOfferRepositoryProvider = Provider((ref) => BannerOfferRepository(ref.watch(localDatabaseProvider)));

class BannerOfferRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AppDatabase _db;

  BannerOfferRepository(this._db);

  Future<List<BannerOffer>> getActiveBanners() async {
    try {
      // 1. Fetch from local SQLite DB first
      final localBanners = await _db.select(_db.cachedBanners).get();
      if (localBanners.isNotEmpty) {
        // Sync in background and return local data immediately
        _syncBannersFromRemote().catchError((e) {
          debugPrint('Background banner sync failed: $e');
          return <BannerOffer>[];
        });
        return localBanners.map((b) => BannerOffer(
          id: b.id,
          title: b.title,
          subtitle: b.subtitle,
          image: b.image,
          cta: b.cta,
        )).toList();
      }

      // 2. If no local data, await network fetch
      return await _syncBannersFromRemote();
    } catch (e) {
      throw Exception('Failed to fetch banners: $e');
    }
  }

  Future<List<BannerOffer>> _syncBannersFromRemote() async {
    final response = await _supabase
        .from('banners')
        .select()
        .eq('is_active', true);
    
    final banners = response.map((map) => BannerOffer.fromMap(map, map['id'].toString())).toList();

    // Cache to Drift
    await _db.transaction(() async {
      await _db.delete(_db.cachedBanners).go(); // Clear old cache
      for (final banner in banners) {
        await _db.into(_db.cachedBanners).insert(
          CachedBanner(
            id: banner.id,
            title: banner.title,
            subtitle: banner.subtitle,
            image: banner.image,
            cta: banner.cta,
          ),
          mode: drift.InsertMode.insertOrReplace,
        );
      }
    });

    return banners;
  }

  Future<BannerOffer> createOffer({
    required String title,
    required String subtitle,
    required String image,
    required String cta,
  }) async {
    try {
      final response = await _supabase.from('banners').insert({
        'title': title,
        'subtitle': subtitle,
        'image': image,
        'cta': cta,
        'is_active': true,
      }).select().single();
      
      final newBanner = BannerOffer.fromMap(response, response['id'].toString());
      
      // Update local cache
      await _db.into(_db.cachedBanners).insert(
        CachedBanner(
          id: newBanner.id,
          title: newBanner.title,
          subtitle: newBanner.subtitle,
          image: newBanner.image,
          cta: newBanner.cta,
        ),
        mode: drift.InsertMode.insertOrReplace,
      );
      
      return newBanner;
    } catch (e) {
      debugPrint('Create Offer Error: $e');
      throw Exception('Failed to create offer');
    }
  }
}
