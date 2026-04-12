import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  late Razorpay _razorpay;
  
  // Callbacks
  final Function(PaymentSuccessResponse?) onSuccess;
  final Function(String) onFailure;

  PaymentService({required this.onSuccess, required this.onFailure}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('Payment Success: ${response.paymentId}');
    onSuccess(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    onFailure(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: \${response.walletName}');
    // Ideally, handling wallets is advanced. We forward it as a success for now if it requires manual intent.
    onFailure('Please use a direct payment method instead of \${response.walletName}');
  }

  void startPayment({
    required double amount, // In INR
    required String contact,
    required String email,
    required String description,
  }) {
    // Razorpay expects amount in paise (multiply by 100)
    final amountInPaise = (amount * 100).toInt();
    
    final apiKey = dotenv.env['RAZORPAY_API_KEY_TEST'] ?? '';
    
    if (apiKey.isEmpty || apiKey == 'rzp_test_placeholderKey') {
      // Simulation mode if no key provided
      debugPrint("Simulation Mode: Razorpay Key is missing or placeholder. Triggering Success.");
      
      // Delay for realistic UI effect
      Future.delayed(const Duration(seconds: 1), () {
        onSuccess(null);
      });
      return;
    }

    var options = {
      'key': apiKey,
      'amount': amountInPaise,
      'name': 'RoadRobos Services',
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      'theme': {
        'color': '#0EA5E9' // AppColors.primaryBlue
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error starting razorpay: $e');
      onFailure(e.toString());
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
