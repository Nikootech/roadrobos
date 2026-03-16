import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';

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
          onPressed: () => context.pop(),
        ),
        title: const Text('Withdraw Funds', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available for Withdrawal', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  SizedBox(height: 8),
                  Text('₹12,450.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 32),
            const Text('Withdrawal Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                filled: true,
                fillColor: AppColors.bgLightGrey,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Bank Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.credit_card_rounded, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HDFC Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('**** **** 1234', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const Text('Change', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            if (_isProcessing)
              const Center(child: CircularProgressIndicator())
            else
              CustomButton(
                label: 'Confirm Withdrawal',
                onPressed: () async {
                  setState(() => _isProcessing = true);
                  await Future.delayed(const Duration(seconds: 2));
                  if (!context.mounted) return;
                  setState(() => _isProcessing = false);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal request submitted successfully!')));
                  context.pop();
                },
                backgroundColor: AppColors.primaryBlue,
              ),
            
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Funds will be credited to your bank within 2-4 hours',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

