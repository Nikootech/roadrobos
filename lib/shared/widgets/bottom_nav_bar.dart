import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Data model for a bottom navigation item.
class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// Unified Bottom Navigation Bar — React / Tier-1 Modern Animated Design
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? const Color(0xFF006241);
    final effectiveInactiveColor = inactiveColor ?? const Color(0xFF94A3B8);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: 8,
        bottom: bottomPadding > 0 ? bottomPadding : 10,
        left: 12,
        right: 12,
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isActive = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (!isActive) {
                  HapticFeedback.selectionClick();
                  onTap(index);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFF006241).withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AnimatedScale(
                      scale: isActive ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        color: isActive
                            ? effectiveActiveColor
                            : effectiveInactiveColor,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                      color: isActive
                          ? effectiveActiveColor
                          : effectiveInactiveColor,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isActive ? 4 : 0,
                    height: isActive ? 4 : 0,
                    decoration: BoxDecoration(
                      color: effectiveActiveColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
