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
  return ref.watch(categoryRepositoryProvider).getCategories();
});

final quickActionsProvider = FutureProvider<List<QuickAction>>((ref) async {
  ref.cacheFor(const Duration(minutes: 5));
  return ref.watch(quickActionRepositoryProvider).getQuickActions();
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
