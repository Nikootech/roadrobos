import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/service_catalog_repository.dart';
import '../../core/repositories/banner_offer_repository.dart';
import '../../core/repositories/category_repository.dart';
import '../../core/models/service_item.dart';
import '../../core/models/banner_offer.dart';
import '../../core/models/service_category.dart';

final homeServicesProvider = FutureProvider<List<ServiceItem>>((ref) async {
  return ref.watch(serviceCatalogRepositoryProvider).getServices();
});

final homeOffersProvider = FutureProvider<List<BannerOffer>>((ref) async {
  return ref.watch(bannerOfferRepositoryProvider).getActiveBanners();
});

final homeCategoriesProvider = FutureProvider<List<ServiceCategory>>((ref) async {
  return ref.watch(categoryRepositoryProvider).getCategories();
});
