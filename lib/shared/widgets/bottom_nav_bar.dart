import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Data model for a bottom navigation item.
class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItemData({required this.icon, required this.activeIcon, required this.label});
}

/// Premium animated bottom navigation bar with a sliding pill indicator.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Sliding pill indicator
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              left: _pillLeft(context),
              top: 6,
              child: Container(
                width: _pillWidth(context),
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Nav items row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTap(index),
                    child: _NavItemWidget(
                      icon: item.icon,
                      activeIcon: item.activeIcon,
                      label: item.label,
                      isActive: isActive,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  double _pillWidth(BuildContext context) {
    if (items.isEmpty) return 0;
    return MediaQuery.of(context).size.width / items.length * 0.4;
  }

  double _pillLeft(BuildContext context) {
    if (items.isEmpty) return 0;
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / items.length;
    final pillW = tabWidth * 0.4;
    return tabWidth * currentIndex + (tabWidth - pillW) / 2;
  }
}

class _NavItemWidget extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;

  const _NavItemWidget({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              isActive ? activeIcon : icon,
              key: ValueKey<bool>(isActive),
              size: 24,
              color: isActive ? AppColors.primaryBlue : AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? AppColors.primaryBlue : AppColors.textMuted,
          ),
          child: Text(label),
        ),
      ],
    );
  }
}

