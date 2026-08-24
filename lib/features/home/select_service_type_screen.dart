import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:go_router/go_router.dart';
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
                size: 18, color: Color(0xFF0F172A)),
          ),
        ),
        title: Text(
          'Select Service',
          style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Professional Services\nfor your Vehicle',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.5,
                  height: 1.25,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'Certified doorstep technicians & genuine OEM spare parts',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
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
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
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

              const SizedBox(height: 14),
              _buildEmergencyServiceCard(
                context,
                'Emergency Help',
                'Roadside assistance 24/7 with live GPS dispatch',
                Iconsax.call_calling,
                const Color(0xFFE11D48),
                '/live-tracking',
              ),
              const SizedBox(height: 32),
              Text(
                'Recent Services',
                style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3),
              ),
              const SizedBox(height: 14),

              // Dynamic Recent Bookings
              recentBookingsAsync.when(
                data: (bookings) {
                  if (bookings.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(Iconsax.clock,
                                size: 20, color: Color(0xFF94A3B8)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No recent services found',
                            style: GoogleFonts.inter(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    );
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFECDD3)),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: GoogleFonts.inter(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '24/7 SOS',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFE11D48),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(desc,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3,
                size: 16, color: Color(0xFFE11D48)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildServiceCategoryCard(BuildContext context, WidgetRef ref,
      String title, String desc, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(bookingProvider.notifier).reset();
        ref.read(bookingProvider.notifier).setServiceType(title);
        context.push(route);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A))),
                  const SizedBox(height: 3),
                  Text(desc,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3,
                size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildRecentServiceTile(String name, String date, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Iconsax.clock, size: 18, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(date,
                    style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getCategoryMapping(String label) {
    switch (label.toLowerCase()) {
      case 'repair':
      case 'service':
        return {
          'icon': Iconsax.setting_2,
          'color': const Color(0xFF0284C7),
          'route': '/select-service'
        };
      case 'rentals':
        return {
          'icon': Iconsax.car,
          'color': const Color(0xFF006241),
          'route': '/rentals'
        };
      case 'ev service':
      case 'ev bike service':
        return {
          'icon': Iconsax.flash_1,
          'color': const Color(0xFF0D9488),
          'route': '/ev-bike-service-booking'
        };
      case 'bike service':
        return {
          'icon': Icons.pedal_bike_rounded,
          'color': const Color(0xFF006241),
          'route': '/bike-service-booking'
        };
      case 'car service':
        return {
          'icon': Iconsax.car,
          'color': const Color(0xFFEA580C),
          'route': '/car-service-booking'
        };
      case 'water service':
        return {
          'icon': Iconsax.drop,
          'color': const Color(0xFF0284C7),
          'route': '/water-service-booking'
        };
      case 'logistics':
        return {
          'icon': Iconsax.truck_fast,
          'color': const Color(0xFFD97706),
          'route': '/delivery-logistics'
        };
      default:
        return {
          'icon': Iconsax.category,
          'color': const Color(0xFF006241),
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
              )),
    );
  }
}
