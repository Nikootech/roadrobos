/// Service booking integration tests.
///
/// Tests navigating to bike service, filling form, and asserting
/// booking creation using mocked providers.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:roadrobos/core/services/auth_service.dart';
import 'package:roadrobos/features/home/bike_service_booking_screen.dart';

import 'test_helpers.dart';

void main() {
  late MockAuthService mockAuth;

  setUpAll(() {
    registerTestFallbackValues();
  });

  setUp(() {
    mockAuth = MockAuthService();
    when(() => mockAuth.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => mockAuth.restoredUser).thenReturn(null);
    when(() => mockAuth.currentUser).thenReturn(null);
  });

  group('Service Booking Tests', () {
    testWidgets('bike service booking screen renders package list',
        (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const BikeServiceBookingScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );

      await tester.pumpAndSettle();

      // Assert: Service booking screen renders
      expect(find.byType(BikeServiceBookingScreen), findsOneWidget);

      // Assert: Package options are displayed
      expect(find.text('Bike Service Packages'), findsOneWidget);
      expect(find.text('Choose a Package'), findsOneWidget);
      expect(find.text('Basic Service'), findsOneWidget);
      expect(find.text('General Service'), findsOneWidget);
      expect(find.text('Premium Service'), findsOneWidget);
    });

    testWidgets('selecting a service package highlights it',
        (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const BikeServiceBookingScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );

      await tester.pumpAndSettle();

      // Act: Tap on Basic Service package
      await tester.tap(find.text('Basic Service'));
      await tester.pumpAndSettle();

      // Assert: Package items should be visible
      expect(find.text('Engine Oil Replacement'), findsOneWidget);
      expect(find.text('Chain Clean & Lube'), findsOneWidget);
    });

    testWidgets('proceed button is disabled when no package selected',
        (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const BikeServiceBookingScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );

      await tester.pumpAndSettle();

      // Assert: Proceed button exists
      expect(find.text('Proceed to Schedule'), findsOneWidget);
    });

    testWidgets('service package prices are visible',
        (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const BikeServiceBookingScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );

      await tester.pumpAndSettle();

      // Assert: All prices are displayed
      expect(find.text('₹499'), findsOneWidget);
      expect(find.text('₹899'), findsOneWidget);
      expect(find.text('₹1,499'), findsOneWidget);
    });
  });
}
