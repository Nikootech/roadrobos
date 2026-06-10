import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:roadrobos/core/repositories/wallet_repository.dart';

// ── Mock Classes ─────────────────────────────────────────────────────────────
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<dynamic> {
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

class MockPostgrestFilterBuilderList extends Mock implements PostgrestFilterBuilder<List<dynamic>> {
  final FutureOr<List<dynamic>> Function() handler;

  MockPostgrestFilterBuilderList(this.handler);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<dynamic> value) onValue, {
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

  setUp(() {
    mockSupabase = MockSupabaseClient();
    walletRepository = WalletRepository(supabaseClient: mockSupabase);
  });

  group('WalletRepository.transferFunds Unit Tests', () {
    test('transferFunds succeeds with valid parameters', () async {
      // 1. Mock lookupUserByPhone (first query: lookup_user_by_phone)
      final mockLookupBuilder = MockPostgrestFilterBuilderList(() {
        return [
          {
            'id': 'recipient_123',
            'full_name': 'Jane Doe',
          }
        ];
      });

      when(() => mockSupabase.rpc<List<dynamic>>(
            'lookup_user_by_phone',
            params: any(named: 'params'),
          )).thenAnswer((_) => mockLookupBuilder);

      // 2. Mock transfer_funds RPC (second query: transfer_funds)
      final mockTransferBuilder = MockPostgrestFilterBuilder(() {
        return {
          'success': true,
          'transaction_id': 'tx_123',
        };
      });

      when(() => mockSupabase.rpc<dynamic>(
            'transfer_funds',
            params: any(named: 'params'),
          )).thenAnswer((_) => mockTransferBuilder);

      // 3. Run and expect success
      final success = await walletRepository.transferFunds(
        'sender_123',
        '9876543210',
        50.0,
      );

      expect(success, isTrue);

      verify(() => mockSupabase.rpc<List<dynamic>>(
            'lookup_user_by_phone',
            params: {'phone_param': '9876543210'},
          )).called(1);

      verify(() => mockSupabase.rpc<dynamic>(
            'transfer_funds',
            params: {
              'sender_id': 'sender_123',
              'receiver_id': 'recipient_123',
              'amount': 50.0,
              'description': 'Transfer to Jane Doe',
            },
          )).called(1);
    });

    test('transferFunds throws exception when recipient phone lookup returns null', () async {
      // 1. Mock lookupUserByPhone to return empty list
      final mockLookupBuilder = MockPostgrestFilterBuilderList(() => []);

      when(() => mockSupabase.rpc<List<dynamic>>(
            'lookup_user_by_phone',
            params: any(named: 'params'),
          )).thenAnswer((_) => mockLookupBuilder);

      // 2. Run and expect standard exception
      await expectLater(
        walletRepository.transferFunds('sender_123', '9876543210', 50.0),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('User with this phone number not found.'))),
      );
    });

    test('transferFunds maps database exceptions to user friendly messages', () async {
      // 1. Mock lookupUserByPhone
      final mockLookupBuilder = MockPostgrestFilterBuilderList(() {
        return [
          {
            'id': 'recipient_123',
            'full_name': 'Jane Doe',
          }
        ];
      });

      when(() => mockSupabase.rpc<List<dynamic>>(
            'lookup_user_by_phone',
            params: any(named: 'params'),
          )).thenAnswer((_) => mockLookupBuilder);

      // 2. Mock transfer_funds to throw insufficient_funds database exception
      final mockTransferBuilder = MockPostgrestFilterBuilder(() {
        throw const PostgrestException(
          message: 'insufficient_funds',
          code: 'P0001',
        );
      });

      when(() => mockSupabase.rpc<dynamic>(
            'transfer_funds',
            params: any(named: 'params'),
          )).thenAnswer((_) => mockTransferBuilder);

      // 3. Expect user-friendly Exception
      await expectLater(
        walletRepository.transferFunds('sender_123', '9876543210', 50.0),
        throwsA(predicate((e) =>
            e is Exception && e.toString().contains('Insufficient wallet balance.'))),
      );
    });
  });
}
