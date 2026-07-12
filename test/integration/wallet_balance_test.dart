import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mutex/mutex.dart';

import 'package:roadrobos/core/repositories/wallet_repository.dart';

// ── Mock classes ─────────────────────────────────────────────────────────────
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {
  final FutureOr<dynamic> Function() handler;

  MockPostgrestFilterBuilder(this.handler);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(dynamic value) onValue, {
    Function? onError,
  }) {
    final completer = Completer<R>();

    Future.sync(() => handler()).then((result) {
      Future.sync(() => onValue(result)).then(
        (val) => completer.complete(val),
        onError: (e, st) => completer.completeError(e, st),
      );
    }, onError: (e, st) {
      if (onError != null) {
        Future.sync(() => onError(e, st)).then(
          (val) => completer.complete(val as R),
          onError: (err, stack) => completer.completeError(err, stack),
        );
      } else {
        completer.completeError(e, st);
      }
    });

    return completer.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSupabaseClient mockSupabase;
  late WalletRepository walletRepository;
  late double mockBalance;
  late Mutex mockDbMutex;
  late Map<String, dynamic> lastRpcParams;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    walletRepository = WalletRepository(supabaseClient: mockSupabase);
    mockBalance = 100.0; // Starting balance for tests
    mockDbMutex = Mutex();
    lastRpcParams = {};
  });

  group('Wallet Balance & Debit/Credit Tests', () {
    test('credit correctly increments balance', () async {
      // 1. Mock the update_wallet_balance RPC call to return a mock builder executing credit logic
      final mockRpcFilterBuilder = MockPostgrestFilterBuilder(() {
        final amount = lastRpcParams['amount'] as double;
        final type = lastRpcParams['transaction_type'] as String;

        expect(type, equals('credit'));
        mockBalance += amount;
        return null;
      });

      when(() => mockSupabase.rpc(
            'update_wallet_balance',
            params: any(named: 'params'),
          )).thenAnswer((invocation) {
        lastRpcParams = invocation.namedArguments[const Symbol('params')]
            as Map<String, dynamic>;
        return mockRpcFilterBuilder;
      });

      // 2. Execute credit
      await walletRepository.topUpWallet('user_123', 50.0, 'pay_tx_123');

      // 3. Verify balance
      expect(mockBalance, equals(150.0));
    });

    test(
        'debiting more than balance throws InsufficientBalanceException and balance remains unchanged',
        () async {
      // 1. Mock the update_wallet_balance RPC call to return a mock builder executing debit logic
      final mockRpcFilterBuilder = MockPostgrestFilterBuilder(() {
        final amount = lastRpcParams['amount'] as double;
        final type = lastRpcParams['transaction_type'] as String;

        expect(type, equals('debit'));
        if (mockBalance - amount < 0) {
          throw const PostgrestException(
            message: 'new balance would be negative',
            code: 'P0001',
          );
        }
        mockBalance -= amount;
        return null;
      });

      when(() => mockSupabase.rpc(
            'update_wallet_balance',
            params: any(named: 'params'),
          )).thenAnswer((invocation) {
        lastRpcParams = invocation.namedArguments[const Symbol('params')]
            as Map<String, dynamic>;
        return mockRpcFilterBuilder;
      });

      // 2. Debit more than 100.0 (e.g. 120.0) - Await the asynchronous expectation
      await expectLater(
        walletRepository.payFromWallet('user_123', 120.0, 'Payment over limit'),
        throwsA(isA<InsufficientBalanceException>()),
      );

      // 3. Verify balance remains at 100.0
      expect(mockBalance, equals(100.0));
    });

    test(
        'concurrent debit race condition - only one succeeds if total exceeds balance',
        () async {
      // 1. Mock the update_wallet_balance RPC with lock emulation and lag
      final mockRpcFilterBuilder = MockPostgrestFilterBuilder(() async {
        final amount = lastRpcParams['amount'] as double;
        final type = lastRpcParams['transaction_type'] as String;

        expect(type, equals('debit'));

        // Emulate pessimistic database locking via Mutex protection
        return await mockDbMutex.protect(() async {
          // Introduce database/network lag to force overlap of requests
          await Future.delayed(const Duration(milliseconds: 20));

          if (mockBalance - amount < 0) {
            throw const PostgrestException(
              message: 'new balance would be negative',
              code: 'P0001',
            );
          }
          mockBalance -= amount;
          return null;
        });
      });

      when(() => mockSupabase.rpc(
            'update_wallet_balance',
            params: any(named: 'params'),
          )).thenAnswer((invocation) {
        lastRpcParams = invocation.namedArguments[const Symbol('params')]
            as Map<String, dynamic>;
        return mockRpcFilterBuilder;
      });

      // 2. Dispatch two concurrent debits: 60.0 and 50.0 (Total: 110.0, Balance: 100.0)
      final results = <dynamic>[];

      await Future.wait([
        walletRepository.payFromWallet('user_123', 60.0, 'Debit A').then(
              (success) => results.add(success),
              onError: (e) => results.add(e),
            ),
        walletRepository.payFromWallet('user_123', 50.0, 'Debit B').then(
              (success) => results.add(success),
              onError: (e) => results.add(e),
            ),
      ]);

      // 3. Verify that one succeeded (returned true) and the other failed (threw InsufficientBalanceException)
      final successCount = results.where((r) => r == true).length;
      final failureCount =
          results.whereType<InsufficientBalanceException>().length;

      expect(successCount, equals(1),
          reason: 'Exactly one concurrent debit must succeed');
      expect(failureCount, equals(1),
          reason: 'Exactly one concurrent debit must fail');

      // 4. Assert that the balance never fell below zero (it should be either 40.0 or 50.0)
      expect(mockBalance, isNot(isNegative));
      expect(mockBalance, anyOf(equals(40.0), equals(50.0)));
    });
  });
}
