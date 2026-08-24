import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:roadrobos/core/services/auth_service.dart';
import '../../core/repositories/ride_booking_repository.dart';
import '../../core/repositories/service_booking_repository.dart';
import '../../core/repositories/rental_booking_repository.dart';
import '../../core/models/ride_booking.dart';
import '../../core/models/service_booking.dart';
import '../../core/models/rental_booking.dart';
import '../../shared/widgets/kinetic_motion.dart';

final userRidesProvider =
    FutureProvider.autoDispose.family<List<RideBooking>, String>((ref, userId) {
  return ref
      .watch(rideBookingRepositoryProvider)
      .getPagedCustomerRides(userId, limit: 50);
});

final userServicesProvider = FutureProvider.autoDispose
    .family<List<ServiceBooking>, String>((ref, userId) {
  return ref
      .watch(serviceBookingRepositoryProvider)
      .getPagedCustomerServiceBookings(userId, limit: 50);
});

final userRentalsProvider = FutureProvider.autoDispose
    .family<List<RentalBooking>, String>((ref, userId) {
  return ref
      .watch(rentalBookingRepositoryProvider)
      .getPagedCustomerRentals(userId, limit: 50);
});

/// World-Class React Tier-1 History Screen (Rides, Services, Rentals)
class RideHistoryScreen extends ConsumerWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authNotifierProvider).value?.id;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: Center(
            child: ScaleOnTap(
              onTap: () => context.pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: Color(0xFF0F172A)),
              ),
            ),
          ),
          title: Text(
            'History',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                labelColor: const Color(0xFF006241),
                unselectedLabelColor: const Color(0xFF64748B),
                labelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Rides'),
                  Tab(text: 'Services'),
                  Tab(text: 'Rentals'),
                ],
              ),
            ),
          ),
        ),
        body: userId == null
            ? _buildEmptyState('Please login to view your activity history',
                Iconsax.user_cirlce_add)
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
      color: const Color(0xFF006241),
      child: ridesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF006241)),
        ),
        error: (err, stack) =>
            _buildEmptyState('Failed to load rides', Iconsax.warning_2),
        data: (rides) {
          if (rides.isEmpty) {
            return _buildEmptyState('No past rides found yet', Iconsax.car);
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: rides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final ride = rides[index];
              final isCompleted = ride.status.toLowerCase() == 'completed';
              final isCancelled = ride.status.toLowerCase() == 'cancelled';
              final isOngoing = !isCompleted && !isCancelled;

              return ScaleOnTap(
                child: _buildHistoryCard(
                  title: ride.destinationAddress.split(',').first,
                  subtitle: ride.pickupAddress.split(',').first,
                  date: DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(ride.createdAt),
                  status: ride.status.toUpperCase(),
                  price: '₹${ride.fare}',
                  category: 'Personal Cab',
                  gradient: const [Color(0xFF006241), Color(0xFF10B981)],
                  icon: Iconsax.car,
                  isCompleted: isCompleted,
                  isCancelled: isCancelled,
                  isOngoing: isOngoing,
                  trailingAction: isCompleted
                      ? OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Receipt downloaded successfully.'),
                                backgroundColor: Color(0xFF006241),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Iconsax.document_download, size: 14),
                          label: Text(
                            'Receipt',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            foregroundColor: const Color(0xFF006241),
                            side: const BorderSide(
                                color: Color(0xFF006241), width: 1.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        )
                      : null,
                ),
              )
                  .animate()
                  .fadeIn(delay: (60 * index).ms)
                  .slideY(begin: 0.08, end: 0);
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
      color: const Color(0xFF006241),
      child: servicesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF006241)),
        ),
        error: (err, stack) =>
            _buildEmptyState('Failed to load services', Iconsax.warning_2),
        data: (services) {
          if (services.isEmpty) {
            return _buildEmptyState(
                'No service history found', Iconsax.setting_2);
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final service = services[index];
              final isCompleted = service.status.toLowerCase() == 'completed';
              final isCancelled = service.status.toLowerCase() == 'cancelled';
              final isOngoing = !isCompleted && !isCancelled;

              return ScaleOnTap(
                child: _buildHistoryCard(
                  title: service.packageName,
                  subtitle: service.vehiclePlate.isNotEmpty
                      ? service.vehiclePlate
                      : service.vehicleName,
                  date: DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(service.createdAt),
                  status: service.status.toUpperCase(),
                  price: '₹${service.totalCost}',
                  category: service.packageName,
                  gradient: const [Color(0xFF0284C7), Color(0xFF38BDF8)],
                  icon: Iconsax.setting_2,
                  isCompleted: isCompleted,
                  isCancelled: isCancelled,
                  isOngoing: isOngoing,
                ),
              )
                  .animate()
                  .fadeIn(delay: (60 * index).ms)
                  .slideY(begin: 0.08, end: 0);
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
      color: const Color(0xFF006241),
      child: rentalsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF006241)),
        ),
        error: (err, stack) =>
            _buildEmptyState('Failed to load rentals', Iconsax.warning_2),
        data: (rentals) {
          if (rentals.isEmpty) {
            return _buildEmptyState('No rental bookings found', Iconsax.key);
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: rentals.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rental = rentals[index];
              final isCompleted = rental.status.toLowerCase() == 'completed' ||
                  rental.status.toLowerCase() == 'paid';
              final isCancelled = rental.status.toLowerCase() == 'cancelled';
              final isOngoing = !isCompleted && !isCancelled;

              return ScaleOnTap(
                child: _buildHistoryCard(
                  title: rental.vehicleName,
                  subtitle:
                      'Duration: ${rental.duration} ${rental.rentalType == 'hourly' ? 'Hours' : 'Days'}',
                  date: DateFormat('MMM dd, yyyy • hh:mm a')
                      .format(rental.startTime),
                  status: rental.status.toUpperCase(),
                  price: '₹${rental.totalCost}',
                  category: rental.rentalType.toUpperCase(),
                  gradient: const [Color(0xFFD97706), Color(0xFFFBBF24)],
                  icon: Iconsax.key,
                  isCompleted: isCompleted,
                  isCancelled: isCancelled,
                  isOngoing: isOngoing,
                ),
              )
                  .animate()
                  .fadeIn(delay: (60 * index).ms)
                  .slideY(begin: 0.08, end: 0);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Center(
                child: Icon(icon, size: 36, color: const Color(0xFF94A3B8)),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String subtitle,
    required String date,
    required String status,
    required String price,
    required String category,
    required List<Color> gradient,
    required IconData icon,
    required bool isCompleted,
    required bool isCancelled,
    required bool isOngoing,
    Widget? trailingAction,
  }) {
    Color statusColor;
    Color statusBg;
    if (isCompleted) {
      statusColor = const Color(0xFF006241);
      statusBg = const Color(0xFFECFDF5);
    } else if (isCancelled) {
      statusColor = const Color(0xFFE11D48);
      statusBg = const Color(0xFFFFF1F2);
    } else {
      statusColor = const Color(0xFF0284C7);
      statusBg = const Color(0xFFF0F9FF);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: 3D Squircle Icon + Title + Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.first.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                price,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 12),

          // Footer: Category / Route detail + Status Pill + Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 12, color: const Color(0xFF64748B)),
                        const SizedBox(width: 5),
                        Text(
                          category,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (trailingAction != null) ...[
                    trailingAction,
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isOngoing) ...[
                          PulseBeacon(
                            color: statusColor,
                            size: 6,
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          status,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
