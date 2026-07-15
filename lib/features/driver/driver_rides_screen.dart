import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../core/repositories/ride_booking_repository.dart';
import '../../core/models/ride_booking.dart';
import '../../features/profile/user_provider.dart';

/// Driver Rides Screen showing My Rides History (Driver View) from Supabase
class DriverRidesScreen extends ConsumerStatefulWidget {
  const DriverRidesScreen({super.key});

  @override
  ConsumerState<DriverRidesScreen> createState() => _DriverRidesScreenState();
}

class _DriverRidesScreenState extends ConsumerState<DriverRidesScreen> {
  bool _isLoading = true;
  List<RideBooking> _rides = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = ref.read(userProvider);
      final driverId = user.user?.id ?? 'demo';
      final rides = await ref
          .read(rideBookingRepositoryProvider)
          .getPagedDriverRides(driverId, limit: 50);
      if (mounted) {
        setState(() {
          _rides = rides;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedRides =
        _rides.where((r) => r.status == 'completed').toList();
    final cancelledRides =
        _rides.where((r) => r.status == 'cancelled').toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.bgLightGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: const Text(
            'My Rides',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.deepNavy,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.refresh, color: AppColors.textPrimary),
              onPressed: () {
                HapticFeedback.lightImpact();
                _fetchRides();
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.bgLightGrey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: AppColors.deepNavy,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(text: 'Completed'),
                  Tab(text: 'Cancelled'),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Failed to load rides: $_error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchRides,
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    children: [
                      // Completed Tab
                      completedRides.isEmpty
                          ? const Center(child: Text('No completed rides.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: completedRides.length,
                              itemBuilder: (context, index) {
                                final r = completedRides[index];
                                final timeStr =
                                    "${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year} ${r.createdAt.hour.toString().padLeft(2, '0')}:${r.createdAt.minute.toString().padLeft(2, '0')}";
                                return _buildPremiumRideCard(
                                  context,
                                  passenger:
                                      'Customer ${r.customerId.substring(0, 4).toUpperCase()}',
                                  date: timeStr,
                                  fare: '₹${r.fare.toStringAsFixed(2)}',
                                  status: 'COMPLETED',
                                  statusColor: AppColors.successGreen,
                                  pickup: r.pickupAddress,
                                  drop: r.destinationAddress,
                                );
                              },
                            ).animate().fadeIn(duration: 400.ms),

                      // Cancelled Tab
                      cancelledRides.isEmpty
                          ? const Center(child: Text('No cancelled rides.'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: cancelledRides.length,
                              itemBuilder: (context, index) {
                                final r = cancelledRides[index];
                                final timeStr =
                                    "${r.createdAt.day}/${r.createdAt.month}/${r.createdAt.year} ${r.createdAt.hour.toString().padLeft(2, '0')}:${r.createdAt.minute.toString().padLeft(2, '0')}";
                                return _buildPremiumRideCard(
                                  context,
                                  passenger:
                                      'Customer ${r.customerId.substring(0, 4).toUpperCase()}',
                                  date: timeStr,
                                  fare: '₹${r.fare.toStringAsFixed(2)}',
                                  status: 'CANCELLED',
                                  statusColor: AppColors.dangerRed,
                                  pickup: r.pickupAddress,
                                  drop: r.destinationAddress,
                                );
                              },
                            ).animate().fadeIn(duration: 400.ms),
                    ],
                  ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 2,
          items: const [
            NavItemData(
                icon: Iconsax.home, activeIcon: Iconsax.home5, label: 'Home'),
            NavItemData(
                icon: Iconsax.wallet,
                activeIcon: Iconsax.wallet5,
                label: 'Earnings'),
            NavItemData(
                icon: Iconsax.star,
                activeIcon: Iconsax.star5,
                label: 'Ratings'),
            NavItemData(
                icon: Iconsax.user, activeIcon: Iconsax.user, label: 'Account'),
          ],
          onTap: (index) {
            if (index == 0) context.pushReplacement('/driver-home');
            if (index == 1) context.pushReplacement('/driver-earnings');
            if (index == 2) return;
            if (index == 3) context.pushReplacement('/driver-profile');
          },
        ),
      ),
    );
  }

  Widget _buildPremiumRideCard(
    BuildContext context, {
    required String passenger,
    required String date,
    required String fare,
    required String status,
    required Color statusColor,
    required String pickup,
    required String drop,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row: Avatar, Info, Fare
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Iconsax.user,
                            color: AppColors.primaryBlue, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            passenger,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      fare,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.deepNavy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.bgLightGrey, height: 1),
                const SizedBox(height: 16),
                // Trip Trail
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.circle,
                            color: AppColors.primaryBlue, size: 8),
                        Container(
                            width: 1.5,
                            height: 28,
                            color: AppColors.border.withValues(alpha: 0.5)),
                        const Icon(Icons.location_on_rounded,
                            color: AppColors.dangerRed, size: 14),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pickup,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 18),
                          Text(
                            drop,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: statusColor.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: statusColor,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
  }
}
