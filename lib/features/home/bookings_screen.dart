import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';

/// Bookings Screen - Shows ride/service booking history
/// Matches Figma Screen [21]: "My Rides History"
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = [
      _BookingItem('General Service', 'Hyundai Creta', 'Completed', '28 Feb 2026', '₹2,499', AppColors.successDark, Icons.build_rounded),
      _BookingItem('Monthly Rental', 'Mahindra Thar', 'Active', '01 Mar - 31 Mar', '₹45,000', AppColors.primaryBlue, Icons.car_rental_rounded),
      _BookingItem('Oil Change', 'Honda City', 'In Progress', '07 Mar 2026', '₹899', AppColors.warningAmber, Icons.build_rounded),
      _BookingItem('Daily Rental', 'Hyundai Venue', 'Scheduled', '12 Mar 2026', '₹2,500', AppColors.primaryBlue, Icons.car_rental_rounded),
      _BookingItem('AC Service', 'Hyundai Creta', 'Scheduled', '10 Mar 2026', '₹1,799', AppColors.primaryBlue, Icons.build_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.bgLightGrey,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => NavHelpers.showComingSoon(context, 'Booking filters'),
            icon: const Icon(Iconsax.filter, color: AppColors.textPrimary, size: 20),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: booking.statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    booking.icon,
                    color: booking.statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.service,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.vehicle} • ${booking.date}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      booking.price,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: booking.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: booking.statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              .animate(delay: Duration(milliseconds: 100 * index))
              .fadeIn(duration: 400.ms)
              .slideX(begin: 0.05, end: 0);
        },
      ),
    );
  }
}

class _BookingItem {
  final String service;
  final String vehicle;
  final String status;
  final String date;
  final String price;
  final Color statusColor;
  final IconData icon;

  _BookingItem(this.service, this.vehicle, this.status, this.date, this.price, this.statusColor, this.icon);
}

