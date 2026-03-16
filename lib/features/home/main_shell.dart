import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared/widgets/bottom_nav_bar.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    '/main/home',
    '/main/bookings',
    '/main/explore',
    '/main/profile',
  ];

  static const List<NavItemData> _customerNavItems = [
    NavItemData(icon: Iconsax.home_2, activeIcon: Iconsax.home_25, label: 'Home'),
    NavItemData(icon: Iconsax.calendar_1, activeIcon: Iconsax.calendar, label: 'Bookings'),
    NavItemData(icon: Iconsax.search_normal_1, activeIcon: Iconsax.search_normal, label: 'Explore'),
    NavItemData(icon: Iconsax.user, activeIcon: Iconsax.user, label: 'Profile'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      final location = GoRouterState.of(context).uri.toString();
      final index = _tabs.indexWhere((tab) => location.startsWith(tab));
      if (index != -1 && index != _currentIndex) {
        setState(() => _currentIndex = index);
      }
    } catch (_) {}
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      context.go(_tabs[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: _customerNavItems,
      ),
    );
  }
}
