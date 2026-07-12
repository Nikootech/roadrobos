import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/technician/technician_provider.dart';
import 'home_providers.dart';

class SelectServiceTypeScreen extends ConsumerWidget {
  const SelectServiceTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(homeCategoriesProvider);
    final recentBookingsAsync = ref.watch(recentServiceBookingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: AppColors.textPrimary),
          ),
        ),
        title: const Text(
          'Select Service',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Professional Services\nfor your Vehicle',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 24),

              // Dynamic Service Categories
              categoriesAsync.when(
                data: (categories) {
                  final filtered = categories
                      .where((c) => [
                            'ev service',
                            'bike service',
                            'car service',
                            'water service'
                          ].contains(c.label.toLowerCase()))
                      .toList();

                  if (filtered.isEmpty) return const SizedBox.shrink();

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final cat = filtered[index];
                      final mapping = _getCategoryMapping(cat.label);
                      return _buildServiceCategoryCard(
                        context,
                        ref,
                        cat.label,
                        '${cat.count} packages available',
                        mapping['icon'] as IconData,
                        mapping['color'] as Color,
                        mapping['route'] as String,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
              ),

              const SizedBox(height: 16),
              _buildEmergencyServiceCard(
                context,
                'Emergency Help',
                'Roadside assistance 24/7',
                Icons.emergency_rounded,
                AppColors.dangerRed,
                '/live-tracking',
              ),
              const SizedBox(height: 32),
              const Text(
                'Recent Services',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary),
              ),
              const SizedBox(height: 16),

              // Dynamic Recent Bookings
              recentBookingsAsync.when(
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return const Text('No recent services found');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.length > 3 ? 3 : bookings.length,
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      return _buildRecentServiceTile(
                        b.packageName,
                        DateFormat('dd MMM yyyy').format(b.createdAt),
                        b.status.toUpperCase(),
                      );
                    },
                  );
                },
                loading: () => const ShimmerRecentServices(),
                error: (err, _) => Text('Error: $err'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyServiceCard(BuildContext context, String title,
      String desc, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.heavyImpact();
        context.push('/emergency-help');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.dangerRed.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.dangerRed.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildServiceCategoryCard(BuildContext context, WidgetRef ref,
      String title, String desc, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () {
        ref.read(bookingProvider.notifier).reset();
        ref.read(bookingProvider.notifier).setServiceType(title);
        context.push(route);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bgSkyLight,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: AppColors.textMuted.withValues(alpha: 0.5)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildRecentServiceTile(String name, String date, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.bgLightGrey,
            child:
                Icon(Icons.history, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(date,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(status,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.successGreen)),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryMapping(String label) {
    switch (label.toLowerCase()) {
      case 'repair':
      case 'service':
        return {
          'icon': Icons.build_rounded,
          'color': const Color(0xFF3B82F6),
          'route': '/select-service'
        };
      case 'rentals':
        return {
          'icon': Icons.car_rental_rounded,
          'color': const Color(0xFF8B5CF6),
          'route': '/rentals'
        };
      case 'ev service':
      case 'ev bike service':
        return {
          'icon': Icons.bolt_rounded,
          'color': const Color(0xFF06B6D4),
          'route': '/ev-bike-service-booking'
        };
      case 'bike service':
        return {
          'icon': Icons.pedal_bike_rounded,
          'color': AppColors.primaryBlue,
          'route': '/bike-service-booking'
        };
      case 'car service':
        return {
          'icon': Icons.directions_car_rounded,
          'color': AppColors.accentOrange,
          'route': '/car-service-booking'
        };
      case 'water service':
        return {
          'icon': Icons.local_car_wash_rounded,
          'color': const Color(0xFF0EA5E9),
          'route': '/water-service-booking'
        };
      case 'logistics':
        return {
          'icon': Icons.local_shipping_rounded,
          'color': const Color(0xFFF97316),
          'route': '/delivery-logistics'
        };
      default:
        return {
          'icon': Icons.category_rounded,
          'color': AppColors.primaryBlue,
          'route': '/select-service'
        };
    }
  }
}

class ShimmerRecentServices extends StatelessWidget {
  const ShimmerRecentServices({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
          2,
          (index) => Container(
                height: 60,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
              )),
    );
  }
}
