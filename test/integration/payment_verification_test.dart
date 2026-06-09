import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:roadrobos/core/config/app_config.dart';
import 'package:roadrobos/core/services/payment_service.dart';
import 'package:roadrobos/core/security/jailbreak_guard.dart';

// ── Mock classes ─────────────────────────────────────────────────────────────
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<dynamic> {
  final dynamic futureValue;
  final bool shouldThrow;
  final Object? exceptionToThrow;

  MockPostgrestFilterBuilder({
    this.futureValue,
    this.shouldThrow = false,
    this.exceptionToThrow,
  });

  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic value) onValue, {
    Function? onError,
  }) async {
    if (shouldThrow) {
      if (exceptionToThrow != null) {
        throw exceptionToThrow!;
      }
      throw Exception('Mock database error');
    }
    final result = await onValue(futureValue);
    return result;
  }
}

class MockRazorpay extends Mock implements Razorpay {}
class MockPaymentSuccessResponse extends Mock implements PaymentSuccessResponse {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabase;
  late MockRazorpay mockRazorpay;
  late ProviderContainer container;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockRazorpay = MockRazorpay();

    // Register fallbacks
    registerFallbackValue(Uri());
    registerFallbackValue(HttpMethod.post);

    final mockFunctions = MockFunctionsClient();
    when(() => mockSupabase.functions).thenReturn(mockFunctions);
    when(() => mockFunctions.invoke(
          any(),
          body: any(named: 'body'),
        )).thenAnswer((_) async => FunctionResponse(
          status: 200,
          data: {'order_id': 'order_mock_123'},
        ));

    // Stub the mockRazorpay methods BEFORE building the PaymentService provider
    when(() => mockRazorpay.on(any(), any())).thenAnswer((_) {});
    when(() => mockRazorpay.open(any())).thenAnswer((_) {});
  });

  void initContainer() {
    container = ProviderContainer(
      overrides: [
        jailbreakProvider.overrideWithValue(false),
        razorpayProvider.overrideWithValue(mockRazorpay),
      ],
    );
  }

  tearDown(() {
    container.dispose();
  });

  group('PaymentService Verification Tests', () {
    test('verify_payment RPC rejects simulated_signature in production config', () async {
      // 1. Force Production Config
      AppConfig.environment = Environment.prod;

      // 2. Capture Razorpay handlers when build is called
      final eventHandlers = <String, Function>{};
      when(() => mockRazorpay.on(any(), any())).thenAnswer((invocation) {
        final event = invocation.positionalArguments[0] as String;
        final handler = invocation.positionalArguments[1] as Function;
        eventHandlers[event] = handler;
      });

      // 3. Initialize container and read service
      initContainer();
      final paymentService = container.read(paymentServiceProvider.notifier);
      paymentService.mockSupabaseClient = mockSupabase;
      paymentService.mockRazorpayInstance = mockRazorpay; // Bypasses simulation check

      // 4. Mock the Supabase RPC call structure to return false for simulated signature
      final mockRpcFilterBuilder = MockPostgrestFilterBuilder(futureValue: false);
      when(() => mockSupabase.rpc(
            'verify_payment',
            params: any(named: 'params'),
          )).thenAnswer((_) => mockRpcFilterBuilder);

      // 5. Start payment
      final details = PaymentDetails(
        bookingId: '00000000-0000-0000-0000-000000000000',
        bookingType: BookingType.wallet,
        totalCost: 100.0,
        userId: '00000000-0000-0000-0000-000000000001',
        contact: '9876543210',
        email: 'test@roadrobos.com',
        description: 'Test Wallet Topup',
      );

      final paymentFuture = paymentService.startPayment(details);

      // 6. Capture the success callback
      final successHandler = eventHandlers[Razorpay.EVENT_PAYMENT_SUCCESS];
      expect(successHandler, isNotNull, reason: 'Razorpay success handler must be registered');

      final mockResponse = MockPaymentSuccessResponse();
      when(() => mockResponse.paymentId).thenReturn('sim_pay_123');
      when(() => mockResponse.orderId).thenReturn('sim_order_123');
      when(() => mockResponse.signature).thenReturn('simulated_signature');

      // 7. Register expectation BEFORE triggering the async callback to avoid uncaught exceptions
      final expectFuture = expectLater(
        paymentFuture,
        throwsA(contains('Payment validation failed on server')),
      );

      await successHandler!(mockResponse);

      // 8. Wait for validation result
      await expectFuture;

      // Verify Supabase RPC was called with correct parameters
      verify(() => mockSupabase.rpc(
            'verify_payment',
            params: {
              'p_order_id': 'sim_order_123',
              'p_payment_id': 'sim_pay_123',
              'p_signature': 'simulated_signature',
              'p_booking_id': details.bookingId,
              'p_booking_type': details.bookingType.name,
              'p_amount': details.totalCost,
              'p_user_id': details.userId,
            },
          )).called(1);
    });

    test('verify_payment RPC passes with a valid HMAC signature', () async {
      // 1. Force Production Config
      AppConfig.environment = Environment.prod;

      // 2. Set up event capturing
      final eventHandlers = <String, Function>{};
      when(() => mockRazorpay.on(any(), any())).thenAnswer((invocation) {
        final event = invocation.positionalArguments[0] as String;
        final handler = invocation.positionalArguments[1] as Function;
        eventHandlers[event] = handler;
      });

      // 3. Initialize container and read service
      initContainer();
      final paymentService = container.read(paymentServiceProvider.notifier);
      paymentService.mockSupabaseClient = mockSupabase;
      paymentService.mockRazorpayInstance = mockRazorpay; // Bypasses simulation check

      // 4. Calculate valid HMAC signature matching server side
      const rzpSecret = 'rzp_test_placeholderSecret';
      const orderId = 'order_valid_999';
      const paymentId = 'pay_valid_999';
      const payload = '$orderId|$paymentId';

      final key = utf8.encode(rzpSecret);
      final bytes = utf8.encode(payload);
      final hmac = Hmac(sha256, key);
      final validSignature = hmac.convert(bytes).toString();

      // 5. Mock the Supabase RPC call structure to return true for valid signature
      final mockRpcFilterBuilder = MockPostgrestFilterBuilder(futureValue: true);
      when(() => mockSupabase.rpc(
            'verify_payment',
            params: any(named: 'params'),
          )).thenAnswer((_) => mockRpcFilterBuilder);

      // 6. Start payment
      final details = PaymentDetails(
        bookingId: '00000000-0000-0000-0000-000000000000',
        bookingType: BookingType.wallet,
        totalCost: 150.0,
        userId: '00000000-0000-0000-0000-000000000001',
        contact: '9876543210',
        email: 'test@roadrobos.com',
        description: 'Valid Topup',
      );

      final paymentFuture = paymentService.startPayment(details);

      // 7. Trigger success callback with valid signature
      final successHandler = eventHandlers[Razorpay.EVENT_PAYMENT_SUCCESS];
      final mockResponse = MockPaymentSuccessResponse();
      when(() => mockResponse.paymentId).thenReturn(paymentId);
      when(() => mockResponse.orderId).thenReturn(orderId);
      when(() => mockResponse.signature).thenReturn(validSignature);

      // 8. Register expectation before triggering callback
      final expectFuture = expectLater(paymentFuture, completes);

      await successHandler!(mockResponse);

      // 9. Wait for validation result
      await expectFuture;

      // Verify Supabase RPC call parameters
      verify(() => mockSupabase.rpc(
            'verify_payment',
            params: {
              'p_order_id': orderId,
              'p_payment_id': paymentId,
              'p_signature': validSignature,
              'p_booking_id': details.bookingId,
              'p_booking_type': details.bookingType.name,
              'p_amount': details.totalCost,
              'p_user_id': details.userId,
            },
          )).called(1);
    });
  });
}
