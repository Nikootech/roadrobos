/// Shared test helpers and mock classes for integration tests.
///
/// Uses [mocktail] for mock generation and provides helper utilities
/// that wrap widgets with mocked ProviderScope overrides.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:roadrobos/core/services/auth_service.dart';
import 'package:roadrobos/core/repositories/user_repository.dart';
import 'package:roadrobos/core/repositories/wallet_repository.dart';
import 'package:roadrobos/core/repositories/approval_repository.dart';
import 'package:roadrobos/core/models/user_role.dart';
import 'package:roadrobos/core/models/wallet_model.dart';
import 'package:roadrobos/core/models/approval.dart';
import 'package:roadrobos/features/profile/user_provider.dart';

// ---------------------------------------------------------------------------
// Mock classes
// ---------------------------------------------------------------------------

class MockAuthService extends Mock implements AuthService {}

class MockUserRepository extends Mock implements UserRepository {}

class MockWalletRepository extends Mock implements WalletRepository {}

class MockApprovalRepository extends Mock implements ApprovalRepository {}

// ---------------------------------------------------------------------------
// Fake classes (for registerFallbackValue)
// ---------------------------------------------------------------------------

class FakeAppUser extends Fake implements AppUser {}

// ---------------------------------------------------------------------------
// Test fixtures
// ---------------------------------------------------------------------------

/// A test customer user.
final AppUser testCustomer = AppUser(
  id: 'test-customer-001',
  name: 'Test Customer',
  phone: '9876543210',
  email: 'customer@test.com',
  role: UserRole.customer,
  profilePic: '',
  points: 100,
  totalRides: 5,
);

/// A test admin user.
final AppUser testAdmin = AppUser(
  id: 'test-admin-001',
  name: 'Test Admin',
  phone: '9876543211',
  email: 'admin@test.com',
  role: UserRole.superAdmin,
  profilePic: '',
);

/// A test wallet.
final Wallet testWallet = Wallet(
  userId: 'test-customer-001',
  balance: 1500.0,
  lastUpdated: DateTime.now(),
);

/// Sample transactions for wallet tests.
final List<WalletTransaction> testTransactions = [
  WalletTransaction(
    id: 'txn-001',
    walletId: 'wallet-001',
    amount: 500.0,
    type: TransactionType.credit,
    description: 'Top Up',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  WalletTransaction(
    id: 'txn-002',
    walletId: 'wallet-001',
    amount: 200.0,
    type: TransactionType.debit,
    description: 'Ride Payment',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];

/// Sample pending KYC approval requests.
final List<ApprovalRequest> testPendingApprovals = [
  ApprovalRequest(
    id: 'approval-001',
    type: ApprovalType.partnerKyc,
    entityType: 'driver',
    entityId: 'driver-001',
    makerId: 'driver-001',
    status: ApprovalStatus.pending,
    payload: {
      'applicant_name': 'Rajesh Kumar',
      'applicant_role': 'Driver',
    },
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ApprovalRequest(
    id: 'approval-002',
    type: ApprovalType.partnerKyc,
    entityType: 'technician',
    entityId: 'tech-001',
    makerId: 'tech-001',
    status: ApprovalStatus.pending,
    payload: {
      'applicant_name': 'Priya Sharma',
      'applicant_role': 'Technician',
    },
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    updatedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
];

// ---------------------------------------------------------------------------
// Helper: register fallback values for mocktail
// ---------------------------------------------------------------------------

void registerTestFallbackValues() {
  registerFallbackValue(FakeAppUser());
  registerFallbackValue(ApprovalStatus.pending);
}

// ---------------------------------------------------------------------------
// Helper: pump a widget with mocked providers
// ---------------------------------------------------------------------------

/// Pumps a widget wrapped in ProviderScope with test overrides.
Future<void> pumpTestWidget(
  WidgetTester tester, {
  required Widget child,
  List<Override> overrides = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: child,
      ),
    ),
  );
  await tester.pump();
}
