import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';

/// 4-Eyes Dual Approval Verification Dialog for High-Value Financial & RBAC Transactions.
class DualApprovalDialog extends StatelessWidget {
  final String actionTitle;
  final String amountText;
  final String makerName;
  final String reason;
  final VoidCallback onAuthorized;

  const DualApprovalDialog({
    super.key,
    required this.actionTitle,
    required this.amountText,
    required this.makerName,
    required this.reason,
    required this.onAuthorized,
  });

  static void show(
    BuildContext context, {
    required String actionTitle,
    required String amountText,
    required String makerName,
    required String reason,
    required VoidCallback onAuthorized,
  }) {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => DualApprovalDialog(
        actionTitle: actionTitle,
        amountText: amountText,
        makerName: makerName,
        reason: reason,
        onAuthorized: onAuthorized,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.shield_security, color: Color(0xFF4F46E5), size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            '4-Eyes Dual Authorization',
            style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, size: 16, color: Color(0xFFB45309)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'High-Value Transaction Governance (>₹5,000 threshold). Requires SuperAdmin co-signature.',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildDetail('Action', actionTitle),
          _buildDetail('Transaction Value', amountText, isHighlight: true),
          _buildDetail('Maker Initiator', makerName),
          _buildDetail('Justification', reason),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 6),
          const Text(
            'By co-signing, you confirm this transaction complies with audit standards.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Reject / Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.pop(context);
            onAuthorized();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Transaction co-signed and authorized successfully!'),
                backgroundColor: AppColors.brandGreen,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Co-Sign & Authorize', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDetail(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 14 : 12,
              fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
              color: isHighlight ? const Color(0xFF059669) : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
