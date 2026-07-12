/// Admin KYC integration tests.
///
/// Tests admin viewing pending KYC list and approve action
/// using mocked approval repository.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:roadrobos/core/services/auth_service.dart';
import 'package:roadrobos/core/repositories/approval_repository.dart';
import 'package:roadrobos/core/models/approval.dart';
import 'package:roadrobos/features/admin/approval_center_screen.dart';
import 'package:roadrobos/features/admin/kyc_approval_screen.dart';

import 'test_helpers.dart';

void main() {
  late MockAuthService mockAuth;
  late MockApprovalRepository mockApprovalRepo;

  setUpAll(() {
    registerTestFallbackValues();
  });

  setUp(() {
    mockAuth = MockAuthService();
    mockApprovalRepo = MockApprovalRepository();

    when(() => mockAuth.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAuth.restoredUser).thenReturn(null);
    when(() => mockAuth.currentUser).thenReturn(null);
  });

  group('Admin KYC Tests', () {
    testWidgets('approval center shows pending KYC list',
        (WidgetTester tester) async {
      // Arrange: Mock watchPendingApprovals to return test data
      when(() => mockApprovalRepo.watchPendingApprovals())
          .thenAnswer((_) => Stream.value(testPendingApprovals));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            approvalRepositoryProvider.overrideWithValue(mockApprovalRepo),
          ],
          child: const MaterialApp(
            home: ApprovalCenterScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert: Approval Center screen renders
      expect(find.byType(ApprovalCenterScreen), findsOneWidget);
      expect(find.text('Approval Center'), findsOneWidget);
    });

    testWidgets('approval center shows empty state when no approvals',
        (WidgetTester tester) async {
      when(() => mockApprovalRepo.watchPendingApprovals())
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            approvalRepositoryProvider.overrideWithValue(mockApprovalRepo),
          ],
          child: const MaterialApp(
            home: ApprovalCenterScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert: Empty state is shown
      expect(find.text('All caught up!'), findsOneWidget);
      expect(find.text('No pending approval requests.'), findsOneWidget);
    });

    testWidgets('KYC approval screen shows applicant info and action buttons',
        (WidgetTester tester) async {
      final testRequest = testPendingApprovals.first;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            approvalRepositoryProvider.overrideWithValue(mockApprovalRepo),
          ],
          child: MaterialApp(
            home: KycApprovalScreen(request: testRequest),
          ),
        ),
      );

      await tester.pump();

      // Assert: KYC screen renders with applicant info
      expect(find.byType(KycApprovalScreen), findsOneWidget);
      expect(find.text('KYC Approval'), findsOneWidget);
      expect(find.text('Rajesh Kumar'), findsOneWidget);
      // Assert: Action buttons are present
      expect(find.text('APPROVE'), findsOneWidget);
      expect(find.text('REJECT'), findsOneWidget);
    });

    testWidgets('approve action calls updateApprovalStatus',
        (WidgetTester tester) async {
      final testRequest = testPendingApprovals.first;

      when(() => mockApprovalRepo.updateApprovalStatus(
            id: any(named: 'id'),
            status: any(named: 'status'),
            reason: any(named: 'reason'),
          )).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authServiceProvider.overrideWithValue(mockAuth),
            approvalRepositoryProvider.overrideWithValue(mockApprovalRepo),
          ],
          child: MaterialApp(
            home: KycApprovalScreen(request: testRequest),
          ),
        ),
      );

      await tester.pump();

      // Act: Tap the APPROVE button
      await tester.tap(find.text('APPROVE'));
      await tester.pump();

      // Assert: The updateApprovalStatus was called with correct params
      verify(() => mockApprovalRepo.updateApprovalStatus(
            id: testRequest.id,
            status: ApprovalStatus.approved,
          )).called(1);
    });
  });
}
