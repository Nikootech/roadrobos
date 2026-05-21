import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import '../../core/services/payment_service.dart';

class SecurePaymentScreen extends StatefulWidget {
  const SecurePaymentScreen({super.key});

  @override
  State<SecurePaymentScreen> createState() => _SecurePaymentScreenState();
}

class _SecurePaymentScreenState extends State<SecurePaymentScreen> {
  bool _isProcessing = false;
  bool _isSuccess = false;

  void _startPayment() {
    setState(() => _isProcessing = true);
    final paymentService = PaymentService(
      onSuccess: (response) {
        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isSuccess = true;
          });
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) context.pop(true);
          });
        }
      },
      onFailure: (error) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment failed: $error')));
        }
      },
    );

    paymentService.startPayment(
      amount: 500, // Example amount
      contact: '9999999999',
      email: 'user@example.com',
      description: 'Secure Payment',
      bookingId: '00000000-0000-0000-0000-000000000000',
      userId: '00000000-0000-0000-0000-000000000000',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !_isProcessing,
        title: const Text('Secure Payment', style: TextStyle(color: AppColors.textPrimary)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isProcessing && !_isSuccess) ...[
                const Icon(Icons.shield_rounded, size: 80, color: AppColors.primaryBlue),
                const SizedBox(height: 24),
                const Text('Safe & Secure', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text(
                  'Your payment is encrypted with industry-standard protocols.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Image.network('https://upload.wikimedia.org/wikipedia/commons/8/89/Razorpay_logo.png', width: 100, height: 40),
                  ],
                ),
                const SizedBox(height: 48),
                CustomButton(
                  label: 'Proceed to Pay',
                  onPressed: _startPayment,
                  backgroundColor: AppColors.deepNavy,
                ),
              ] else if (_isProcessing) ...[
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(strokeWidth: 6, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 32),
                const Text('Processing Payment...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Please do not close the app or press back', style: TextStyle(color: AppColors.textSecondary)),
              ] else ...[
                const Icon(Icons.check_circle_rounded, size: 80, color: AppColors.successGreen)
                  .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                const Text('Payment Successful!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Thank you! Redirecting you back...', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
