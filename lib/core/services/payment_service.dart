import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/app_config.dart';

part 'payment_service.g.dart';

enum BookingType { rental, service, ride, wallet }

class PaymentDetails {
  final String bookingId;
  final BookingType bookingType;
  final double totalCost;
  final String userId;
  final String contact;
  final String email;
  final String description;

  PaymentDetails({
    required this.bookingId,
    required this.bookingType,
    required this.totalCost,
    required this.userId,
    required this.contact,
    required this.email,
    required this.description,
  });
}

@riverpod
class PaymentService extends _$PaymentService {
  late Razorpay _razorpay;
  PaymentDetails? _currentPayment;
  Completer<void>? _paymentCompleter;

  @override
  FutureOr<void> build() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    ref.onDispose(() {
      _razorpay.clear();
    });
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse? response) async {
    // ✅ PCI-DSS: Never log raw payment IDs. Only log a safe prefix for debugging.
    if (kDebugMode) {
      final safeId = (response?.paymentId ?? 'null').substring(
        0,
        (response?.paymentId?.length ?? 0).clamp(0, 8),
      );
      debugPrint('Razorpay payment event received. ID prefix: $safeId...[REDACTED]');
    }

    if (_currentPayment != null) {
      try {
        final paymentId = response?.paymentId ?? 'sim_pay_${DateTime.now().millisecondsSinceEpoch}';
        final signature = response?.signature ?? 'simulated_signature';
        final orderId = response?.orderId ?? 'sim_order_${DateTime.now().millisecondsSinceEpoch}';

        // All sensitive fields go directly to the server via TLS — not logged
        final isValid = await Supabase.instance.client.rpc('verify_payment', params: {
          'p_order_id': orderId,
          'p_payment_id': paymentId,
          'p_signature': signature,
          'p_booking_id': _currentPayment!.bookingId,
          'p_booking_type': _currentPayment!.bookingType.name,
          'p_amount': _currentPayment!.totalCost,
          'p_user_id': _currentPayment!.userId,
        });

        if (isValid == true) {
          if (kDebugMode) debugPrint('Payment validated successfully by server.');
          if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
            _paymentCompleter!.complete();
          }
        } else {
          if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
            _paymentCompleter!.completeError('Payment validation failed on server');
          }
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Error verifying payment via RPC: $e');
        if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
          _paymentCompleter!.completeError('Failed to verify payment');
        }
      }
    } else {
      if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
        _paymentCompleter!.completeError('Payment details lost during transaction');
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Only log error code — never log message which may contain card details
    if (kDebugMode) debugPrint('Payment Error code: ${response.code}');
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.completeError(response.message ?? 'Payment failed');
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet Selected: ${response.walletName}');
    if (_paymentCompleter != null && !_paymentCompleter!.isCompleted) {
      _paymentCompleter!.completeError('Please use a direct Razorpay method');
    }
  }

  Future<void> startPayment(PaymentDetails details) async {
    _currentPayment = details;
    _paymentCompleter = Completer<void>();

    final amountInPaise = (details.totalCost * 100).toInt();
    const apiKey = AppConfig.razorpayKey;

    if (apiKey.isEmpty || apiKey == 'rzp_test_placeholderKey') {
      debugPrint('Simulation Mode: Triggering immediate payment success.');
      // ignore: unawaited_futures
      Future.microtask(() => _handlePaymentSuccess(null));
      return _paymentCompleter!.future;
    }

    final options = {
      'key': apiKey,
      'amount': amountInPaise,
      'name': 'RoadRobos Services',
      'description': details.description,
      'prefill': {
        'contact': details.contact,
        'email': details.email,
      },
      'theme': {
        'color': '#0EA5E9'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error starting razorpay: $e');
      if (!_paymentCompleter!.isCompleted) {
        _paymentCompleter!.completeError(e.toString());
      }
    }

    return _paymentCompleter!.future;
  }
}
