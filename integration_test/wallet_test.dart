/// Wallet integration tests.
///
/// Tests wallet balance rendering and top-up flow using mocked
/// wallet providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:roadrobos/core/services/auth_service.dart';
import 'package:roadrobos/core/repositories/wallet_repository.dart';
import 'package:roadrobos/core/models/wallet_model.dart';
import 'package:roadrobos/features/wallet/wallet_screen.dart';
import 'package:roadrobos/features/wallet/wallet_providers.dart';
import 'package:roadrobos/features/wallet/wallet_topup_screen.dart';
import 'package:roadrobos/features/profile/user_provider.dart';

import 'test_helpers.dart';

void main() {
  late MockAuthService mockAuth;
  late MockWalletRepository mockWalletRepo;

  setUpAll(() {
    registerTestFallbackValues();
  });

  setUp(() {
    mockAuth = MockAuthService();
    mockWalletRepo = MockWalletRepository();

    when(() => mockAuth.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => mockAuth.restoredUser).thenReturn(null);
    when(() => mockAuth.currentUser).thenReturn(null);
  });

  group('Wallet Tests', () {
    testWidgets('wallet screen renders with balance',
        (WidgetTester tester) async {
      // Override walletProvider to return our test wallet
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            walletProvider.overrideWith((ref) => Stream.value(testWallet)),
            walletTransactionsProvider.overrideWith(
              (ref) => Future.value(testTransactions),
            ),
          ],
          child: const MaterialApp(
            home: WalletScreen(),
          ),
        ),
      );

      await tester.pump();

      // Assert: Wallet screen renders
      expect(find.byType(WalletScreen), findsOneWidget);
      // Assert: Balance label is present
      expect(find.text('Available Balance'), findsOneWidget);
    });

    testWidgets('wallet action tiles render correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            walletProvider.overrideWith((ref) => Stream.value(testWallet)),
            walletTransactionsProvider.overrideWith(
              (ref) => Future.value(testTransactions),
            ),
          ],
          child: const MaterialApp(
            home: WalletScreen(),
          ),
        ),
      );

      await tester.pump();

      // Assert: Action tiles are displayed
      expect(find.text('Top Up'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Withdraw'), findsOneWidget);
    });

    testWidgets('wallet transactions section renders',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            walletProvider.overrideWith((ref) => Stream.value(testWallet)),
            walletTransactionsProvider.overrideWith(
              (ref) => Future.value(testTransactions),
            ),
          ],
          child: const MaterialApp(
            home: WalletScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert: Recent Transactions header is present
      expect(find.text('Recent Transactions'), findsOneWidget);
    });

    testWidgets('top-up screen renders correctly',
        (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const WalletTopupScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );

      await tester.pump();

      // Assert: Top-up screen renders
      expect(find.byType(WalletTopupScreen), findsOneWidget);
    });
  });
}
