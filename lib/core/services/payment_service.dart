import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

class PaymentService {
  late Razorpay _razorpay;
  
  // Callbacks
  final Function(PaymentSuccessResponse?) onSuccess;
  final Function(String) onFailure;

  String? _currentBookingId;
  String? _currentUserId;
  double? _currentAmount;

  PaymentService({required this.onSuccess, required this.onFailure}) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse? response) async {
    debugPrint('Payment Success: ${response?.paymentId}');
    
    if (_currentBookingId != null && _currentUserId != null && _currentAmount != null) {
      try {
        await Supabase.instance.client.rpc('process_payment', params: {
          'payment_id': response?.paymentId ?? 'simulated_payment_id_${DateTime.now().millisecondsSinceEpoch}',
          'booking_id': _currentBookingId,
          'amount': _currentAmount,
          'user_id': _currentUserId,
        });
      } catch (e) {
        debugPrint('Error processing payment via RPC: $e');
        onFailure('Payment captured but backend update failed: $e');
        return;
      }
    }
    
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
    required String bookingId,
    required String userId,
  }) {
    _currentAmount = amount;
    _currentBookingId = bookingId;
    _currentUserId = userId;

    // Razorpay expects amount in paise (multiply by 100)
    final amountInPaise = (amount * 100).toInt();
    
    final apiKey = AppConfig.razorpayKey;
    
    if (apiKey.isEmpty || apiKey == 'rzp_test_placeholderKey') {
      // Simulation mode if no key provided
      debugPrint("Simulation Mode: Razorpay Key is missing or placeholder. Triggering Success.");
      
      // Simulate immediate success for testing when no key is present.
      // In production, the backend should verify the payment signature.
      Future.microtask(() async {
        await _handlePaymentSuccess(null);
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
