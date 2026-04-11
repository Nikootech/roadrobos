import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

/// Ride & Service History matching Figma Screen [21]: My Rides History
class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        body: TabBarView(
          children: [
            // Rides Tab
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildHistoryCard(
                  type: 'Ride to Airport',
                  date: 'Oct 24, 2023 • 10:30 AM',
                  status: index == 0 ? 'Completed' : 'Cancelled',
                  price: '₹450',
                  car: 'White Swift Dzire',
                  isSuccess: index == 0,
                ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
              },
            ),

            // Services Tab
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildHistoryCard(
                  type: 'General Service',
                  date: 'Sep 10, 2023 • 09:00 AM',
                  status: 'Completed',
                  price: '₹2,499',
                  car: 'Hyundai Creta',
                  isSuccess: true,
                  isService: true,
                ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
              },
            ),

            // Rentals Tab
            ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: 2,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _buildHistoryCard(
                  type: index == 0 ? 'Monthly Rental' : 'Daily Rental',
                  date: index == 0 ? 'Oct 01 - Oct 31' : 'Nov 05, 2023',
                  status: 'Completed',
                  price: index == 0 ? '₹45,000' : '₹2,500',
                  car: index == 0 ? 'Mahindra Thar' : 'Hyundai Venue',
                  isSuccess: true,
                  isRental: true,
                ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, end: 0);
              },
            ),
          ],
        ),
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
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
                  color: isSuccess ? AppColors.successGreen.withOpacity(0.1) : AppColors.dangerRed.withOpacity(0.1),
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

