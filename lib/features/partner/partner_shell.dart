import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/models/user_role.dart';
import '../driver/providers/driver_state_provider.dart';
import '../profile/user_provider.dart';
import '../technician/technician_dashboard_screen.dart';

/// Unified Partner Shell that wraps either Driver or Technician views
/// with an omnipresent On-Duty / Off-Duty status bar and role-tailored navigation.
class PartnerShell extends ConsumerStatefulWidget {
  final Widget child;

  const PartnerShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<PartnerShell> createState() => _PartnerShellState();
}

class _PartnerShellState extends ConsumerState<PartnerShell> {
  int _calculateSelectedIndex(BuildContext context, bool isDriver) {
    final location = GoRouterState.of(context).matchedLocation;
    if (isDriver) {
      if (location.startsWith('/driver/rides')) return 1;
      if (location.startsWith('/driver/earnings')) return 2;
      if (location.startsWith('/driver/profile')) return 3;
      return 0; // /driver-home
    } else {
      if (location.startsWith('/tech-tasks')) return 1;
      if (location.startsWith('/tech-spare-parts') ||
          location.startsWith('/tech-jobs')) {
        return 2;
      }
      if (location.startsWith('/tech-profile')) return 3;
      return 0; // /tech-dashboard
    }
  }

  void _onTabSelected(int index, bool isDriver) {
    HapticFeedback.selectionClick();
    if (isDriver) {
      switch (index) {
        case 0:
          context.go('/driver-home');
          break;
        case 1:
          context.go('/driver/rides');
          break;
        case 2:
          context.go('/driver/earnings');
          break;
        case 3:
          context.go('/driver/profile');
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go('/tech-dashboard');
          break;
        case 1:
          context.go('/tech-tasks');
          break;
        case 2:
          context.go('/tech-spare-parts');
          break;
        case 3:
          context.go('/tech-profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final isDriver = userState.user?.role == UserRole.driver;

    final isDriverOnline = ref.watch(mapStateProvider).isOnline;
    final isTechOnline = ref.watch(techOnlineProvider);
    final isOnline = isDriver ? isDriverOnline : isTechOnline;

    final selectedIndex = _calculateSelectedIndex(context, isDriver);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // App Branding Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDriver
                          ? const Color(0xFFFFF7ED)
                          : const Color(0xFFF0FDFA),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDriver
                            ? const Color(0xFFFDBA74)
                            : const Color(0xFF5EEAD4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isDriver ? Iconsax.car : Iconsax.setting_2,
                          size: 16,
                          color: isDriver
                              ? const Color(0xFFEA580C)
                              : const Color(0xFF0D9488),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isDriver ? 'PILOT / DRIVER' : 'SERVICE TECH',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isDriver
                                ? const Color(0xFFEA580C)
                                : const Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Mega Duty Availability Toggle
                  InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (isDriver) {
                        ref.read(mapStateProvider.notifier).toggleOnline();
                      } else {
                        ref.read(techOnlineProvider.notifier).state = !isTechOnline;
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isOnline
                            ? const Color(0xFF10B981)
                            : const Color(0xFF64748B),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: isOnline
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.white : Colors.grey.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isOnline ? 'ON DUTY' : 'OFF DUTY',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onTabSelected(index, isDriver),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: isDriver
              ? const Color(0xFFEA580C)
              : const Color(0xFF0D9488),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          items: isDriver
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.radar_2),
                    activeIcon: Icon(Iconsax.radar_2),
                    label: 'Radar',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.routing),
                    activeIcon: Icon(Iconsax.routing),
                    label: 'Trips',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.wallet_3),
                    activeIcon: Icon(Iconsax.wallet_3),
                    label: 'Earnings',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.user),
                    activeIcon: Icon(Iconsax.user),
                    label: 'Profile',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.category),
                    activeIcon: Icon(Iconsax.category),
                    label: 'Workshop',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.task_square),
                    activeIcon: Icon(Iconsax.task_square),
                    label: 'Job Cards',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.box),
                    activeIcon: Icon(Iconsax.box),
                    label: 'Spares',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Iconsax.user),
                    activeIcon: Icon(Iconsax.user),
                    label: 'Profile',
                  ),
                ],
        ),
      ),
    );
  }
}
