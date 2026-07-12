import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:roadrobos/core/repositories/wallet_repository.dart';

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
  test('diagnose payFromWallet exception', () async {
    final mockSupabase = MockSupabaseClient();
    final repo = WalletRepository(supabaseClient: mockSupabase);

    final mockBuilder = MockPostgrestFilterBuilder(() {
      debugPrint('Mock throwing PostgrestException...');
      throw const PostgrestException(
        message: 'new balance would be negative',
        code: 'P0001',
      );
    });

    when(() => mockSupabase.rpc(any(), params: any(named: 'params')))
        .thenAnswer((_) => mockBuilder);

    try {
      debugPrint('Calling payFromWallet...');
      await repo.payFromWallet('user_123', 150.0, 'debit');
      debugPrint('Success!');
      fail('Should have thrown');
    } catch (e) {
      debugPrint('payFromWallet threw exception: $e (${e.runtimeType})');
      expect(e, isA<InsufficientBalanceException>());
    }
  });
}
