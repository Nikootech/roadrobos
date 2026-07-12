import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadrobos/core/services/auth_service.dart';
import 'package:roadrobos/core/security/auth_rate_limiter.dart';

// ── Mock Classes ─────────────────────────────────────────────────────────────
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final FutureOr<List<Map<String, dynamic>>> Function() handler;

  MockPostgrestFilterBuilder(this.handler);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {
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

class MockPostgrestFilterBuilderRpc extends Mock
    implements PostgrestFilterBuilder<dynamic> {
  final FutureOr<dynamic> Function() handler;

  MockPostgrestFilterBuilderRpc(this.handler);

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
  SharedPreferences.setMockInitialValues({});

  late MockSupabaseClient mockSupabase;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockGoTrueClient mockAuth;
  late AuthService authService;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockAuth = MockGoTrueClient();
    authService = AuthService();

    // Inject mock Supabase client
    authService.mockSupabaseClient = mockSupabase;

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockSupabase.from(any())).thenAnswer((_) => mockQueryBuilder);
  });

  group('AuthService Unit Tests & Rate Limiting', () {
    const email = 'user@example.com';
    const password = 'password123';

    setUp(() {
      // Clear rate limiter history before each test
      AuthRateLimiter.reset(email);
    });

    test('signInWithEmail logs in successfully and resets rate limits',
        () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user_123');

      final mockResponse = AuthResponse(
        user: mockUser,
      );

      // Mock signInWithPassword to return success
      when(() => mockAuth.signInWithPassword(
            email: email,
            password: password,
          )).thenAnswer((_) async => mockResponse);

      // Mock user_roles select to return empty list
      final mockSelectBuilder = MockPostgrestFilterBuilder(() => []);
      when(() => mockQueryBuilder.select(any()))
          .thenAnswer((_) => mockSelectBuilder);
      when(() => mockSelectBuilder.eq(any(), any()))
          .thenAnswer((_) => mockSelectBuilder);

      // Mock get_user_permissions RPC called inside RbacService after sign in
      final mockRpcBuilder = MockPostgrestFilterBuilderRpc(() => []);
      when(() => mockSupabase.rpc<dynamic>('get_user_permissions',
          params: any(named: 'params'))).thenAnswer((_) => mockRpcBuilder);

      final response = await authService.signInWithEmail(email, password);

      expect(response.user?.id, equals('user_123'));
      verify(() =>
              mockAuth.signInWithPassword(email: email, password: password))
          .called(1);
    });

    test(
        'signInWithEmail triggers AuthRateLimiter blocking after too many attempts',
        () async {
      when(() => mockAuth.signInWithPassword(
            email: email,
            password: password,
          )).thenThrow(const AuthException('Invalid login credentials'));

      // Make 5 sequential login calls (this hits the rate limit threshold)
      for (int i = 0; i < AuthRateLimiter.maxAttempts; i++) {
        try {
          await authService.signInWithEmail(email, password);
        } catch (e) {
          expect(e.toString(), contains('Invalid login credentials'));
        }
      }

      // The 6th login attempt should fail immediately due to client-side rate limiting
      await expectLater(
        authService.signInWithEmail(email, password),
        throwsA(predicate((e) =>
            e is Exception &&
            e.toString().contains('Too many login attempts'))),
      );
    });
  });
}
