import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../../core/config/app_config.dart';
import '../security/jailbreak_guard.dart';
import '../../navigation/app_router.dart';

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

final razorpayProvider = Provider<Razorpay>((ref) {
  return Razorpay();
});

@riverpod
class PaymentService extends _$PaymentService {
  late Razorpay _razorpay;
  PaymentDetails? _currentPayment;
  Completer<void>? _paymentCompleter;

  SupabaseClient? _mockSupabase;
  Razorpay? _mockRazorpay;

  @visibleForTesting
  set mockSupabaseClient(SupabaseClient client) => _mockSupabase = client;

  @visibleForTesting
  set mockRazorpayInstance(Razorpay razorpay) {
    _mockRazorpay = razorpay;
    _razorpay = razorpay;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  SupabaseClient get _supabase => _mockSupabase ?? Supabase.instance.client;

  @override
  FutureOr<void> build() {
    _razorpay = _mockRazorpay ?? ref.watch(razorpayProvider);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Validate Razorpay config early — throws in production if key is missing.
    _validateProductionConfig();

    ref.onDispose(() {
      // Clear event listeners on dispose to prevent memory leaks
      _razorpay.clear();
    });
  }

  /// Validates that the Razorpay API key is properly configured.
  ///
  /// In release builds: throws [FlutterError] immediately if key is empty
  /// or still holds the placeholder value — preventing silent fake payments.
  ///
  /// In debug builds: only logs a warning so that developers using test
  /// keys can still exercise the payment UI without a real Razorpay account.
  void _validateProductionConfig() {
    const apiKey = AppConfig.razorpayKey;
    final isPlaceholder = apiKey.isEmpty || apiKey == 'rzp_test_placeholderKey';

    if (isPlaceholder) {
      if (!kDebugMode) {
        // Release / profile builds: hard-fail immediately.
        throw FlutterError(
          'Razorpay production key is not configured. '
          'Build with --dart-define=RAZORPAY_KEY_ID=rzp_live_... '
          'or include it in dart_defines/prod.json.',
        );
      } else {
        // Debug builds: warn but allow test keys.
        debugPrint(
          'WARNING: PaymentService — Razorpay key is empty or a placeholder. '
          'Payments will fail unless a valid rzp_test_... key is provided.',
        );
      }
    }
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
        final rpcName = AppConfig.isDev ? 'verify_payment_dev' : 'verify_payment';
        final isValid = await _supabase.rpc(rpcName, params: {
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
    if (ref.read(jailbreakProvider)) {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        JailbreakGuard.showDisallowedDialog(context);
      }
      throw const SecurityException('Operation blocked: device integrity compromised.');
    }

    _currentPayment = details;
    _paymentCompleter = Completer<void>();

    unawaited(Sentry.addBreadcrumb(
      Breadcrumb(
        message: 'Payment attempted',
        category: 'payment',
        data: {
          'booking_id': details.bookingId,
          'booking_type': details.bookingType.name,
          'total_cost': details.totalCost,
        },
      ),
    ));

    final amountInPaise = (details.totalCost * 100).toInt();
    const apiKey = AppConfig.razorpayKey;

    // Silent simulation removed. If key is invalid in a non-mock context,
    // _validateProductionConfig() (called in build()) has already thrown.
    // In debug with no key, we fall through to the Supabase order creation
    // which will fail with a clear error message.

    // Call Supabase Edge Function to create Razorpay Order
    String? orderId;
    try {
      final response = await _supabase.functions.invoke(
        'create_razorpay_order',
        body: {
          'amount': amountInPaise,
          'currency': 'INR',
        },
      );
      
      if (response.status != 200) {
        throw Exception('Failed to create order on server: ${response.data}');
      }
      
      orderId = response.data['order_id'] as String?;
      if (orderId == null || orderId.isEmpty) {
        throw Exception('Order ID returned from server was null or empty');
      }
    } catch (e) {
      debugPrint('Error generating Razorpay Order ID: $e');
      if (!_paymentCompleter!.isCompleted) {
        _paymentCompleter!.completeError('Order generation failed: $e');
      }
      return _paymentCompleter!.future;
    }

    final options = {
      'key': apiKey,
      'amount': amountInPaise,
      'order_id': orderId,
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
