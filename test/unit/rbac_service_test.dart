import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roadrobos/core/services/rbac_service.dart';

// ── Mock Classes ─────────────────────────────────────────────────────────────
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

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
  late RbacService rbacService;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    rbacService = RbacService(mockSupabase);

    when(() => mockSupabase.from(any())).thenAnswer((_) => mockQueryBuilder);
  });

  group('RbacService Unit Tests', () {
    test('fetchUserPermissions parses RPC response and caches permissions',
        () async {
      // 1. Mock the get_user_permissions RPC call
      final mockRpcBuilder = MockPostgrestFilterBuilderRpc(() {
        return [
          {
            'permission_name': 'read_chats',
            'resource': 'chats',
            'action': 'read'
          },
          {
            'permission_name': 'write_chats',
            'resource': 'chats',
            'action': 'write'
          },
        ];
      });

      when(() => mockSupabase.rpc<dynamic>(
            'get_user_permissions',
            params: any(named: 'params'),
          )).thenAnswer((_) => mockRpcBuilder);

      // 2. Mock the user_roles select call (shorthand role mappings)
      final mockSelectBuilder = MockPostgrestFilterBuilder(() {
        return [
          {
            'roles': {'name': 'customer'}
          }
        ];
      });

      when(() => mockQueryBuilder.select(any()))
          .thenAnswer((_) => mockSelectBuilder);
      when(() => mockSelectBuilder.eq(any(), any()))
          .thenAnswer((_) => mockSelectBuilder);

      // 3. Fetch permissions
      final perms = await rbacService.fetchUserPermissions('user_123');

      expect(perms, contains('read_chats'));
      expect(perms, contains('write_chats'));
      expect(perms.length, equals(2));

      // 4. Verify in-memory and SharedPreferences cache
      final hasRead = await rbacService.hasPermission('read_chats');
      expect(hasRead, isTrue);

      final cached = await rbacService.getCachedPermissions();
      expect(cached, contains('read_chats'));
    });

    test('fetchUserPermissions injects shorthand role permissions for admin',
        () async {
      // 1. Mock empty RPC response
      final mockRpcBuilder = MockPostgrestFilterBuilderRpc(() => []);

      when(() => mockSupabase.rpc<dynamic>(
            'get_user_permissions',
            params: any(named: 'params'),
          )).thenAnswer((_) => mockRpcBuilder);

      // 2. Mock user_roles select to return 'admin'
      final mockSelectBuilder = MockPostgrestFilterBuilder(() {
        return [
          {
            'roles': {'name': 'admin'}
          }
        ];
      });

      when(() => mockQueryBuilder.select(any()))
          .thenAnswer((_) => mockSelectBuilder);
      when(() => mockSelectBuilder.eq(any(), any()))
          .thenAnswer((_) => mockSelectBuilder);

      // 3. Fetch permissions
      final perms = await rbacService.fetchUserPermissions('user_123');

      // 'admin' role should trigger 'admin_access' shorthand injection
      expect(perms, contains('admin_access'));
    });

    test('clearCache clears SharedPreferences and in-memory cache', () async {
      // Seed initial mock cache in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_permissions', ['admin_access']);

      final preCached = await rbacService.getCachedPermissions();
      expect(preCached, contains('admin_access'));

      // Clear cache
      await rbacService.clearCache();

      final postCached = await rbacService.getCachedPermissions();
      expect(postCached, isEmpty);
    });
  });
}
