import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    NavItemData(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Bookings'),
    NavItemData(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Explore'),
    NavItemData(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
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
