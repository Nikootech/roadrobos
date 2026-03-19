import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class DriverRidesScreen extends StatelessWidget {
  const DriverRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        title: const Text('My Rides', style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRideCard('Today, 10:30 AM', 'Anil K', '₹150.0', 'COMPLETED', AppColors.successGreen),
          _buildRideCard('Yesterday, 6:15 PM', 'Priya S', '₹220.0', 'COMPLETED', AppColors.successGreen),
          _buildRideCard('Yesterday, 2:00 PM', 'Rahul M', '₹85.0', 'CANCELLED', AppColors.dangerRed),
        ],
      ).animate().fadeIn(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        items: const [
          NavItemData(icon: Iconsax.home, activeIcon: Iconsax.home5, label: 'Home'),
          NavItemData(icon: Iconsax.car, activeIcon: Iconsax.car5, label: 'Rides'),
          NavItemData(icon: Iconsax.wallet, activeIcon: Iconsax.wallet5, label: 'Earnings'),
          NavItemData(icon: Iconsax.user, activeIcon: Iconsax.user, label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) context.pushReplacement('/driver-home');
          if (index == 2) context.pushReplacement('/driver-earnings');
          if (index == 3) context.pushReplacement('/driver-profile');
        },
      ),
    );
  }

  Widget _buildRideCard(String date, String passenger, String fare, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)))
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(color: AppColors.bgLightGrey, shape: BoxShape.circle), child: const Icon(Icons.person, color: AppColors.primaryBlue)),
                   const SizedBox(width: 12),
                   Text(passenger, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Text(fare, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primaryBlue)),
            ],
          )
        ],
      ),
    );
  }
}
