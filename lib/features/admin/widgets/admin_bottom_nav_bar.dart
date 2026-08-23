import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

/// Executive Mobile Bottom Navigation Bar for Admin Operations
/// powered by the unified CustomBottomNavBar matching Customer animations.
class AdminBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  static const List<NavItemData> items = [
    NavItemData(
      icon: Iconsax.category,
      activeIcon: Iconsax.category5,
      label: 'Home',
    ),
    NavItemData(
      icon: Iconsax.truck_fast,
      activeIcon: Iconsax.truck_fast,
      label: 'Dispatch',
    ),
    NavItemData(
      icon: Iconsax.task_square,
      activeIcon: Iconsax.task_square5,
      label: 'Approvals',
    ),
    NavItemData(
      icon: Iconsax.profile_2user,
      activeIcon: Iconsax.profile_2user5,
      label: 'Directory',
    ),
    NavItemData(
      icon: Iconsax.chart_2,
      activeIcon: Iconsax.chart_21,
      label: 'Analytics',
    ),
  ];

  static const List<String> _routes = [
    '/admin-home',
    '/admin-service-dispatch',
    '/admin-approvals',
    '/admin-customer-database',
    '/admin-revenue-referral',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: currentIndex,
      items: items,
      activeColor: AppColors.brandGreen,
      onTap: (index) {
        if (index == currentIndex) return;
        if (index >= 0 && index < _routes.length) {
          context.go(_routes[index]);
        }
      },
    );
  }
}


