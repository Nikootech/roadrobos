import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../core/services/payment_service.dart';
import '../profile/user_provider.dart';

class WalletTopupScreen extends ConsumerStatefulWidget {
  final double? initialAmount;
  const WalletTopupScreen({super.key, this.initialAmount});

  @override
  ConsumerState<WalletTopupScreen> createState() => _WalletTopupScreenState();
}

class _WalletTopupScreenState extends ConsumerState<WalletTopupScreen> {
  late final TextEditingController _amountController;
  String _selectedMethod = 'UPI';
  final List<int> _quickAmounts = [100, 250, 500, 1000, 2000];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null ? widget.initialAmount!.toStringAsFixed(0) : '100',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

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
        title: const Text(
          'Top Up Wallet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Amount Denomination', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: _quickAmounts.map((amt) {
                        final isSelected = _amountController.text == amt.toString();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _amountController.text = amt.toString()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.bgLightGrey,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? AppColors.primaryBlue : Colors.transparent),
                              ),
                              child: Text(
                                '₹$amt',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Or Enter Custom Amount', style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() {}),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentMethodTile('UPI (PhonePe, GPay)', Iconsax.mobile, 'UPI'),
            _buildPaymentMethodTile('Credit / Debit Card', Iconsax.card, 'CARD'),
            _buildPaymentMethodTile('Net Banking', Iconsax.bank, 'NET_BANKING'),
            const SizedBox(height: 80),
            CustomButton(
              label: 'Proceed to Pay ₹${_amountController.text}',
              onPressed: () async {
                final amount = double.tryParse(_amountController.text) ?? 0.0;
                if (amount <= 0) return;

                final userData = ref.read(userProvider).user;
                final userId = userData?.id ?? 'demo';

                try {
                  await ref.read(paymentServiceProvider.notifier).startPayment(
                    PaymentDetails(
                      bookingId: '00000000-0000-0000-0000-000000000000',
                      bookingType: BookingType.wallet,
                      totalCost: amount,
                      userId: userId,
                      contact: userData?.phone ?? '9876543210',
                      email: userData?.email ?? 'customer@example.com',
                      description: 'Wallet Top-up',
                    )
                  );
                  
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Wallet Top-up Successful!'),
                    backgroundColor: Colors.green,
                  ));
                  context.pop();
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: AppColors.errorRed,
                  ));
                }
              },
              backgroundColor: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(String title, IconData icon, String methodId) {
    final isSelected = _selectedMethod == methodId;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = methodId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primaryBlue : AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            if (isSelected) 
              BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }
}


