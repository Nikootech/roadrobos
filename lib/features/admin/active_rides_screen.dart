import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/repositories/admin_ops_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/live_map_widget.dart';

final activeRidesStreamProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final supabase = Supabase.instance.client;
  return supabase
      .from('ride_bookings')
      .stream(primaryKey: ['id'])
      .order('created_at')
      .map((list) => list
          .where((item) =>
              ['searching', 'accepted', 'on_trip'].contains(item['status']))
          .toList());
});

class ActiveRidesScreen extends ConsumerStatefulWidget {
  const ActiveRidesScreen({super.key});

  @override
  ConsumerState<ActiveRidesScreen> createState() => _ActiveRidesScreenState();
}

class _ActiveRidesScreenState extends ConsumerState<ActiveRidesScreen> {
  bool _isMapMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Active Rides',
          style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: Icon(_isMapMode ? Iconsax.menu : Iconsax.map,
                color: AppColors.primaryBlue),
            onPressed: () => setState(() => _isMapMode = !_isMapMode),
          ),
          IconButton(
            icon: const Icon(Iconsax.filter, color: AppColors.primaryBlue),
            onPressed: () => _showRideFilterSheet(context),
          ),
        ],
      ),
      body: _isMapMode ? _buildMapView() : _buildListView(),
    );
  }

  void _showRideFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Rides',
              style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy),
            ),
            const SizedBox(height: 24),
            const Text('Status',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('All', true),
                _buildFilterChip('On Trip', false),
                _buildFilterChip('Pending', false),
                _buildFilterChip('Completed', false),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Ride Type',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildFilterChip('Bike', false),
                _buildFilterChip('Auto', false),
                _buildFilterChip('Mini', false),
                _buildFilterChip('Sedan', false),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Apply Filters',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue : AppColors.bgLightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildListView() {
    final activeRidesAsync = ref.watch(activeRidesStreamProvider);

    return activeRidesAsync.when(
      data: (rides) {
        final total = rides.length;
        final transit = rides.where((r) => r['status'] == 'on_trip').length;
        final pending = rides
            .where(
                (r) => r['status'] == 'searching' || r['status'] == 'accepted')
            .length;

        return Column(
          children: [
            // Summary bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('Total Active', total.toString()),
                  _buildSummaryItem('In Transit', transit.toString()),
                  _buildSummaryItem('Pending', pending.toString()),
                ],
              ),
            ),

            Expanded(
              child: rides.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.radar,
                              size: 80,
                              color:
                                  AppColors.textMuted.withValues(alpha: 0.2)),
                          const SizedBox(height: 16),
                          const Text('No active rides at the moment',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: rides.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildRideCard(rides[index], context);
                      },
                    ),
            ),
          ],
        );
      },
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      error: (err, stack) =>
          Center(child: Text('Error loading active rides: $err')),
    );
  }

  void _showAssignDriverDialog(
      BuildContext context, Map<String, dynamic> ride) async {
    final repo = ref.read(adminOpsRepositoryProvider);

    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryBlue)),
    ));

    List<Map<String, dynamic>> allDrivers = [];
    try {
      allDrivers = await repo.getAllDrivers();
      if (context.mounted) Navigator.pop(context); // Pop loading
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error loading drivers: $e')));
      }
      return;
    }

    final onlineDrivers =
        allDrivers.where((d) => d['is_online'] == true).toList();

    if (onlineDrivers.isEmpty) {
      if (context.mounted) {
        unawaited(showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('No Online Drivers'),
            content:
                const Text('There are currently no drivers online to assign.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ));
      }
      return;
    }

    if (context.mounted) {
      unawaited(showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Assign Driver'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: onlineDrivers.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final driver = onlineDrivers[index];
                final driverId = driver['id'].toString();
                final driverName = driver['name'] ?? 'Driver';
                final vehicleModel = driver['vehicle_model'] ?? 'N/A';

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.primaryBlue.withValues(alpha: 0.1),
                    child:
                        const Icon(Icons.person, color: AppColors.primaryBlue),
                  ),
                  title: Text(driverName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text('Vehicle: $vehicleModel',
                      style: const TextStyle(fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(context); // Close list dialog
                    unawaited(showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryBlue)),
                    ));

                    try {
                      await repo.assignDriverToRide(
                          ride['id'].toString(), driverId);
                      if (context.mounted) {
                        Navigator.pop(context); // Pop progress
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Driver assigned successfully!')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // Pop progress
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Failed to assign driver: $e')));
                      }
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ));
    }
  }

  Widget _buildMapView() {
    return Stack(
      children: [
        const LiveMapWidget(
          height: double.infinity,
        ),
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
              ],
            ),
            child: Row(
              children: [
                const Icon(Iconsax.radar,
                    color: AppColors.primaryBlue, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Tracking Live Rides',
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary),
                ),
              ],
            ),
          ).animate().slideY(begin: -0.5, end: 0).fadeIn(),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue)),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride, BuildContext context) {
    final status = ride['status']?.toString().toUpperCase() ?? 'SEARCHING';
    final isSearching = status == 'SEARCHING';
    final fare = ride['fare'] ?? '0';
    final vehicleType = ride['vehicle_type'] ?? 'Taxi';
    final pickup = ride['pickup_address'] ?? 'Pickup';
    final dest = ride['destination_address'] ?? 'Destination';
    final rideId = ride['id']?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border)),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                  backgroundColor: Color(0xFFF0F4FF),
                  child: Icon(Icons.person, color: AppColors.primaryBlue)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ride Request',
                        style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text(
                        'ID: RID-${rideId.length > 8 ? rideId.substring(0, 8).toUpperCase() : rideId.toUpperCase()}',
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: isSearching
                        ? AppColors.warningAmber.withValues(alpha: 0.1)
                        : AppColors.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6)),
                child: Text(status,
                    style: TextStyle(
                        color: isSearching
                            ? AppColors.warningAmber
                            : AppColors.successGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildLocationRow(
              Icons.radio_button_checked, AppColors.primaryBlue, pickup),
          const SizedBox(height: 12),
          _buildLocationRow(
              Icons.location_on_rounded, AppColors.dangerRed, dest),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicleType.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500)),
                  Text('Fare: ₹$fare',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
              Row(
                children: [
                  if (isSearching) ...[
                    ElevatedButton(
                      onPressed: () => _showAssignDriverDialog(context, ride),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Assign Driver',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  TextButton(
                    onPressed: () => context.push('/live-tracking'),
                    child: Text(
                      'View Live',
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildLocationRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
