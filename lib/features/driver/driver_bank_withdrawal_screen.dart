import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

/// Driver Bank Withdrawal Screen — Premium Overhaul
class DriverBankWithdrawalScreen extends StatefulWidget {
  const DriverBankWithdrawalScreen({super.key});

  @override
  State<DriverBankWithdrawalScreen> createState() => _DriverBankWithdrawalScreenState();
}

class _DriverBankWithdrawalScreenState extends State<DriverBankWithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController(text: '5000');
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () {
            HapticFeedback.lightImpact();
            context.pop();
          },
        ),
        title: const Text(
          'Withdraw Funds',
          style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance Card (Premium Navy Gradient)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.deepNavy, Color(0xFF1E293B)],
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: AppColors.deepNavy.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('AVAILABLE BALANCE', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                      Icon(Iconsax.wallet_1, color: Colors.white.withValues(alpha: 0.3), size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('₹12,450.00', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 40),
            const SizedBox(height: 40),
            const Text('Enter amount to withdraw', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: AppColors.bgLightGrey.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('₹', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.deepNavy)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.deepNavy, letterSpacing: -1),
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true, hintText: '0.00'),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            const Text('Payout method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Iconsax.bank, color: AppColors.primaryBlue, size: 26),
                  ),
                  const SizedBox(width: 20),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HDFC Bank', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: AppColors.textPrimary)),
                        SizedBox(height: 4),
                        Text('Account No: **** 1234', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
            else
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  label: 'CONFIRM WITHDRAWAL',
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    setState(() => _isProcessing = true);
                    await Future.delayed(const Duration(seconds: 2));
                    if (!context.mounted) return;
                    setState(() => _isProcessing = false);
                    HapticFeedback.heavyImpact();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Withdrawal request submitted!'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.deepNavy,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    context.pop();
                  },
                  backgroundColor: AppColors.deepNavy,
                ).animate().scale(delay: 200.ms),
              ),
            
            const SizedBox(height: 24),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Funds will be credited to your bank within 2-4 hours',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
