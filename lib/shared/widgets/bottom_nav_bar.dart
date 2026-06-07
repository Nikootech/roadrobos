import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// Data model for a bottom navigation item.
class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItemData({required this.icon, required this.activeIcon, required this.label});
}

/// Premium Unified Driver Bottom Navigation Bar — Sliding Indicator Edition
/// Resolves centering issues and provides a highly interactive "Technician-Plus" UI.
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F2F4))),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Stack(
          children: [
            // ─── Sliding Indicator Pill ───
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / items.length;
                return AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  alignment: Alignment(-1 + (currentIndex * (2 / (items.length - 1))), -0.3),
                  child: Container(
                    width: 65,
                    height: 38,
                    margin: EdgeInsets.only(
                      left: (itemWidth - 65) / 2,
                      right: (itemWidth - 65) / 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              },
            ),
            
            // ─── Nav Items ───
            Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isActive = currentIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isActive) {
                        HapticFeedback.lightImpact();
                        onTap(index);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Section
                        SizedBox(
                          height: 40,
                          child: Center(
                            child: Transform.translate(
                              // PRECISION VISUAL COMPENSATION:
                              // The Filled Wallet (wallet5) is more lopsided than the Unfilled Wallet (wallet).
                              // We apply a 7px shift only when active to maintain perfect centering across states.
                              offset: Offset(
                                item.label == 'Earnings' 
                                    ? (isActive ? 7.0 : 0.0) 
                                    : 0.0, 
                                0.0
                              ),
                              child: Icon(
                                isActive ? item.activeIcon : item.icon,
                                color: isActive ? AppColors.primaryBlue : Colors.grey.withValues(alpha: 0.8),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        // Label
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                            color: isActive ? AppColors.primaryBlue : Colors.grey,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
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
}
