import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../admin_providers.dart';

/// Interactive Geographic Zone Selector for Ops Head, City Managers, and Area Managers.
class ZoneFilterDropdown extends ConsumerWidget {
  const ZoneFilterDropdown({super.key});

  static const List<String> availableZones = [
    'All Zones',
    'Mumbai - South (Colaba/Fort)',
    'Mumbai - West (Bandra/Andheri)',
    'Delhi - NCR Central',
    'Bangalore - Indiranagar/Koramangala',
    'Hyderabad - Hitec City',
    'Pune - Hinjewadi',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedZone = ref.watch(selectedZoneProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        onSelected: (zone) {
          HapticFeedback.selectionClick();
          ref.read(selectedZoneProvider.notifier).state = zone;
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        offset: const Offset(0, 44),
        itemBuilder: (context) => availableZones.map((zone) {
          final isSelected = zone == selectedZone;
          return PopupMenuItem<String>(
            value: zone,
            child: Row(
              children: [
                Icon(
                  zone == 'All Zones' ? Iconsax.global : Iconsax.location,
                  size: 16,
                  color: isSelected ? AppColors.brandGreen : AppColors.textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    zone,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.brandGreen : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_rounded, color: AppColors.brandGreen, size: 16),
              ],
            ),
          );
        }).toList(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.brandGreenBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.location,
                  size: 14,
                  color: AppColors.brandGreen,
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Text(
                  selectedZone,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down_rounded,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
