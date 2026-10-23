import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/bottom_nav_bar.dart';
import '../../shared/widgets/offline_banner.dart';
import 'providers/driver_state_provider.dart';

/// Unified persistent navigation shell for the RoadRobos Partner App (Driver).
/// Houses the 4 primary tabs: Home, Earnings, Ratings/Rides, and Account.
class DriverMainShell extends ConsumerStatefulWidget {
  final Widget child;

  const DriverMainShell({super.key, required this.child});

  @override
  ConsumerState<DriverMainShell> createState() => _DriverMainShellState();
}

class _DriverMainShellState extends ConsumerState<DriverMainShell> {
  int _currentIndex = 0;

  static const _driverTabs = [
    '/driver-home',
    '/driver-earnings',
    '/driver-rides',
    '/driver-profile',
  ];

  static const List<NavItemData> _driverNavItems = [
    NavItemData(
      icon: Iconsax.home,
      activeIcon: Iconsax.home_15,
      label: 'Home',
    ),
    NavItemData(
      icon: Iconsax.wallet,
      activeIcon: Iconsax.wallet_35,
      label: 'Earnings',
    ),
    NavItemData(
      icon: Iconsax.star,
      activeIcon: Iconsax.star5,
      label: 'Ratings',
    ),
    NavItemData(
      icon: Iconsax.user,
      activeIcon: Iconsax.profile_circle5,
      label: 'Account',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncCurrentIndex();
  }

  void _syncCurrentIndex() {
    try {
      final location = GoRouterState.of(context).uri.toString();
      final index = _driverTabs.indexWhere((tab) => location.startsWith(tab));
      if (index != -1 && index != _currentIndex) {
        setState(() => _currentIndex = index);
      }
    } catch (_) {}
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      HapticFeedback.selectionClick();
      setState(() => _currentIndex = index);
      context.go(_driverTabs[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch active trip to show return-to-trip banner if browsing other tabs
    final activeTripAsync = ref.watch(driverActiveTripProvider);
    final hasActiveTrip = activeTripAsync.value != null;
    final isOnHome = _currentIndex == 0;

    return Stack(
      children: [
        Scaffold(
          body: widget.child,
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rapido-style Floating Active Trip Banner when viewing non-home tabs
              if (hasActiveTrip && !isOnHome)
                InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    context.go('/driver-home');
                  },
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.accentOrange,
                    ),
                    child: const Row(
                      children: [
                        Icon(Iconsax.car, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Active Trip in progress • Tap to return to navigation',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 14),
                      ],
                    ),
                  ),
                ),
              CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                items: _driverNavItems,
                backgroundColor: const Color(0xFF18181B),
                activeColor: const Color(0xFFF59E0B),
                inactiveColor: const Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
        const OfflineBanner(),
      ],
    );
  }
}
