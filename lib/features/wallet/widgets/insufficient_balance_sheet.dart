import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';

class InsufficientBalanceSheet extends StatelessWidget {
  final double currentBalance;
  final double requiredAmount;

  const InsufficientBalanceSheet({
    super.key,
    required this.currentBalance,
    required this.requiredAmount,
  });

  static void show(BuildContext context, {required double currentBalance, required double requiredAmount}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => InsufficientBalanceSheet(
        currentBalance: currentBalance,
        requiredAmount: requiredAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shortfall = requiredAmount - currentBalance;
    final currencyFormatter = NumberFormat.simpleCurrency(name: 'INR', decimalDigits: 0);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Warning Icon
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.dangerRed.withValues(alpha: 0.1),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.dangerRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              'Insufficient Wallet Balance',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You do not have enough funds in your wallet to complete this transaction.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            
            // Balance Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgLightGrey,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Required Amount', currencyFormatter.format(requiredAmount), isBold: true),
                  const Divider(height: 20),
                  _buildDetailRow('Current Balance', currencyFormatter.format(currentBalance)),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Shortfall Amount', 
                    currencyFormatter.format(shortfall), 
                    valueColor: AppColors.dangerRed,
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // CTA Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/wallet/topup?amount=${shortfall.ceil()}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                'Top Up ${currencyFormatter.format(shortfall.ceil())}',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
