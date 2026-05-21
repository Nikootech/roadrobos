import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import 'package:roadrobos/core/services/auth_service.dart';
import '../../core/repositories/ride_booking_repository.dart';
import '../../core/repositories/service_booking_repository.dart';
import '../../core/repositories/rental_booking_repository.dart';
import '../../core/models/ride_booking.dart';
import '../../core/models/service_booking.dart';
import '../../core/models/rental_booking.dart';

final userRidesProvider = FutureProvider.autoDispose.family<List<RideBooking>, String>((ref, userId) {
  return ref.watch(rideBookingRepositoryProvider).getPagedCustomerRides(userId, limit: 50);
});

final userServicesProvider = FutureProvider.autoDispose.family<List<ServiceBooking>, String>((ref, userId) {
  return ref.watch(serviceBookingRepositoryProvider).getPagedCustomerServiceBookings(userId, limit: 50);
});

final userRentalsProvider = FutureProvider.autoDispose.family<List<RentalBooking>, String>((ref, userId) {
  return ref.watch(rentalBookingRepositoryProvider).getPagedCustomerRentals(userId, limit: 50);
});

/// Ride & Service History matching Figma Screen [21]: My Rides History
class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateProvider).value?.id;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.bgLightGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          bottom: const TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryBlue,
            dividerColor: AppColors.border,
            tabs: [
              Tab(text: 'Rides'),
              Tab(text: 'Services'),
              Tab(text: 'Rentals'),
            ],
          ),
        ),
        body: userId == null 
          ? const Center(child: Text('Please login to view history'))
          : TabBarView(
              children: [
                _buildRidesTab(ref, userId),
                _buildServicesTab(ref, userId),
                _buildRentalsTab(ref, userId),
              ],
            ),
      ),
    );
  }

  Widget _buildRidesTab(WidgetRef ref, String userId) {
    final ridesAsync = ref.watch(userRidesProvider(userId));
    
    return RefreshIndicator(
      onRefresh: () async => ref.refresh(userRidesProvider(userId).future),
      color: AppColors.primaryBlue,
      child: ridesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildEmptyState('Failed to load rides'),
        data: (rides) {
          if (rides.isEmpty) return _buildEmptyState('No rides found');
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ride = rides[index];
              return _buildHistoryCard(
                type: ride.destinationAddress.split(',').first,
                date: DateFormat('MMM dd, yyyy • hh:mm a').format(ride.createdAt),
                status: ride.status.toUpperCase(),
                price: '₹${ride.fare}',
                car: 'Personal Cab',
                isSuccess: ride.status.toLowerCase() == 'completed',
              ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildServicesTab(WidgetRef ref, String userId) {
    final servicesAsync = ref.watch(userServicesProvider(userId));

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(userServicesProvider(userId).future),
      color: AppColors.primaryBlue,
      child: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildEmptyState('Failed to load services'),
        data: (services) {
          if (services.isEmpty) return _buildEmptyState('No services found');
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildHistoryCard(
                type: service.packageName,
                date: DateFormat('MMM dd, yyyy').format(service.createdAt),
                status: service.status.toUpperCase(),
                price: '₹${service.totalCost}',
                car: service.vehicleName,
                isSuccess: service.status.toLowerCase() == 'completed',
                isService: true,
              ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildRentalsTab(WidgetRef ref, String userId) {
    final rentalsAsync = ref.watch(userRentalsProvider(userId));

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(userRentalsProvider(userId).future),
      color: AppColors.primaryBlue,
      child: rentalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildEmptyState('Failed to load rentals'),
        data: (rentals) {
          if (rentals.isEmpty) return _buildEmptyState('No rentals found');
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rentals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rental = rentals[index];
              return _buildHistoryCard(
                type: rental.vehicleName,
                date: DateFormat('MMM dd, yyyy').format(rental.startTime),
                status: rental.status.toUpperCase(),
                price: '₹${rental.totalCost}',
                car: rental.rentalType.toUpperCase(),
                isSuccess: rental.status.toLowerCase() == 'completed' || rental.status.toLowerCase() == 'paid',
                isRental: true,
              ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildHistoryCard({
    required String type,
    required String date,
    required String status,
    required String price,
    required String car,
    required bool isSuccess,
    bool isService = false,
    bool isRental = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.bgLightGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRental
                          ? Icons.car_rental_rounded
                          : isService
                              ? Icons.build_rounded
                              : Icons.local_taxi_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(date, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              Text(price, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.directions_car_rounded, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(car, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSuccess ? AppColors.successGreen.withValues(alpha: 0.1) : AppColors.dangerRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSuccess ? AppColors.successGreen : AppColors.dangerRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

