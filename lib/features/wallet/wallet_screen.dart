import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../navigation/nav_helpers.dart';
import '../../shared/widgets/glass_card.dart';

/// Wallet & Transactions Screen matching Figma Screen [7]
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightGrey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Center(
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          ),
        ),
        title: Text(
          'Wallet',
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.clock, color: AppColors.textPrimary),
            onPressed: () => NavHelpers.showComingSoon(context, 'Transaction filters'),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card (358x220 from Figma)
            GlassCard(
              padding: const EdgeInsets.all(24),
              borderRadius: 32,
              opacity: 0.1,
              blur: 20,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Available Balance', style: GoogleFonts.inter(fontSize: 14, color: Colors.white70)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                          child: const Text('RoAdRoBos Pay', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('₹4,500.00', style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => context.push('/wallet/topup'),
                          child: _buildWalletAction(Iconsax.add, 'Top Up', AppColors.primaryBlue),
                        ),
                      ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildWalletAction(Iconsax.send_2, 'Transfer', AppColors.successGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Cashback Banner (358x104)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warningAmber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warningAmber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Iconsax.ticket_discount, color: AppColors.warningAmber),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Get 5% Cashback!', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('Top up ₹2,000 or more to avail', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  )
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 24),
            Text('Recent Transactions', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),

            // Transaction History
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildTransactionItem('General Service - Hyundai Creta', 'Today, 10:45 AM', '-₹2,419', true),
                  const Divider(height: 1, indent: 70, endIndent: 20, color: AppColors.borderLight),
                  _buildTransactionItem('Wallet Top up (HDFC Bank)', 'Yesterday, 02:30 PM', '+₹5,000', false),
                  const Divider(height: 1, indent: 70, endIndent: 20, color: AppColors.borderLight),
                  _buildTransactionItem('Ride Fare - Bandra to Andheri', '24 Oct, 09:15 AM', '-₹350', true),
                  const Divider(height: 1, indent: 70, endIndent: 20, color: AppColors.borderLight),
                  _buildTransactionItem('Cashback Received', '24 Oct, 09:15 AM', '+₹17', false),
                ],
              ),
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.1, end: 0)
          ],
        ),
      ),
    );
  }

  Widget _buildWalletAction(IconData icon, String label, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: bgColor),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String subtitle, String amount, bool isDebit) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDebit ? AppColors.dangerRed.withValues(alpha: 0.1) : AppColors.successGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDebit ? Iconsax.arrow_down : Iconsax.arrow_up_3,
              color: isDebit ? AppColors.dangerRed : AppColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDebit ? AppColors.textPrimary : AppColors.successGreen),
          ),
        ],
      ),
    );
  }
}

