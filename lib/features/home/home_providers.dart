import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/service_catalog_repository.dart';
import '../../core/repositories/banner_offer_repository.dart';
import '../../core/repositories/category_repository.dart';
import '../../core/repositories/quick_action_repository.dart';
import '../../core/repositories/service_booking_repository.dart';
import '../../core/models/service_item.dart';
import '../../core/models/banner_offer.dart';
import '../../core/models/service_category.dart';
import '../../core/models/service_booking.dart';
import '../profile/user_provider.dart';

extension CacheExtension on Ref {
  void cacheFor(Duration duration) {
    final link = keepAlive();
    final timer = Timer(duration, link.close);
    onDispose(timer.cancel);
  }
}

final homeServicesProvider = FutureProvider<List<ServiceItem>>((ref) async {
  ref.cacheFor(const Duration(minutes: 5));
  return ref.watch(serviceCatalogRepositoryProvider).getServices();
});

final homeOffersProvider = FutureProvider<List<BannerOffer>>((ref) async {
  ref.cacheFor(const Duration(minutes: 5));
  return ref.watch(bannerOfferRepositoryProvider).getActiveBanners();
});

final homeCategoriesProvider =
    FutureProvider<List<ServiceCategory>>((ref) async {
  ref.cacheFor(const Duration(minutes: 5));
  final categories =
      await ref.watch(categoryRepositoryProvider).getCategories();

  // Sort categories by: taxi, rental, service, insurance
  final order = ['taxi', 'rental', 'service', 'insurance'];
  categories.sort((a, b) {
    final labelA = a.label.toLowerCase();
    final labelB = b.label.toLowerCase();

    int indexA = order.indexWhere((o) => labelA.contains(o));
    int indexB = order.indexWhere((o) => labelB.contains(o));

    if (indexA == -1) indexA = 999;
    if (indexB == -1) indexB = 999;

    return indexA.compareTo(indexB);
  });

  return categories;
});

final quickActionsProvider = FutureProvider<List<QuickAction>>((ref) async {
  ref.cacheFor(const Duration(minutes: 5));
  final actions =
      await ref.watch(quickActionRepositoryProvider).getQuickActions();

  // Sort quick actions by: taxi, rental, service, insurance
  final order = ['taxi', 'rental', 'service', 'insurance'];
  actions.sort((a, b) {
    final labelA = a.label.toLowerCase();
    final labelB = b.label.toLowerCase();

    int indexA = order.indexWhere((o) => labelA.contains(o));
    int indexB = order.indexWhere((o) => labelB.contains(o));

    if (indexA == -1) indexA = 999;
    if (indexB == -1) indexB = 999;

    return indexA.compareTo(indexB);
  });

  return actions;
});

final recentServiceBookingsProvider =
    FutureProvider<List<ServiceBooking>>((ref) {
  final user = ref.watch(userProvider).user;
  if (user == null || user.id.startsWith('demo') || user.id == 'demo') {
    return Future.value([]);
  }
  return ref
      .watch(serviceBookingRepositoryProvider)
      .getPagedCustomerServiceBookings(user.id, limit: 3);
});
