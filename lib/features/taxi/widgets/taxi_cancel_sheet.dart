import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

/// Bottom sheet for cancelling an active taxi ride with reason selection.
class TaxiCancelSheet extends StatefulWidget {
  final VoidCallback onConfirmCancel;

  const TaxiCancelSheet({super.key, required this.onConfirmCancel});

  @override
  State<TaxiCancelSheet> createState() => _TaxiCancelSheetState();
}

class _TaxiCancelSheetState extends State<TaxiCancelSheet> {
  int? _selectedReason;

  static const _reasons = [
    'Driver is taking too long',
    'Changed my plans',
    'Booked by mistake',
    'Found another option',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1F38),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.cancel_outlined,
                          color: AppColors.dangerRed, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cancel Ride',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white54, size: 18),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                const SizedBox(height: 8),

                // Refund policy note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.successGreen.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.successGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '₹0 cancellation fee if cancelled within 2 minutes of booking.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color:
                                AppColors.successGreen.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
                const SizedBox(height: 16),

                Text(
                  'Reason for cancelling',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white54,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Reasons list
                ..._reasons.asMap().entries.map((entry) {
                  final i = entry.key;
                  final reason = entry.value;
                  final isSelected = _selectedReason == i;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedReason = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.dangerRed.withValues(alpha: 0.1)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.dangerRed.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.07),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.dangerRed
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.dangerRed
                                    : Colors.white30,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 12)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            reason,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: isSelected ? Colors.white : Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                      delay: Duration(milliseconds: 120 + i * 50),
                      duration: 300.ms);
                }),
                const SizedBox(height: 16),

                // Confirm cancel button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _selectedReason == null
                        ? null
                        : () {
                            HapticFeedback.heavyImpact();
                            Navigator.pop(context);
                            widget.onConfirmCancel();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerRed,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.white12,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: Text(
                      _selectedReason == null
                          ? 'Select a reason to continue'
                          : 'Confirm Cancellation',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
