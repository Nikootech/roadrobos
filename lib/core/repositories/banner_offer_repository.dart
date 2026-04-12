import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/banner_offer.dart';

final bannerOfferRepositoryProvider = Provider((ref) => BannerOfferRepository());

class BannerOfferRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<BannerOffer>> getActiveBanners() async {
    try {
      final snapshot = await _firestore.collection('banners').get(const GetOptions(source: Source.serverAndCache));
      return snapshot.docs.map((doc) => BannerOffer.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to fetch banners: $e');
    }
  }
}
