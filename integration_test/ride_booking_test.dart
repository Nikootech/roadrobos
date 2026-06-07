/// Ride booking integration tests.
///
/// Tests pickup/destination selection and ride options flow
/// using mocked Supabase responses.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:roadrobos/core/services/auth_service.dart';
import 'package:roadrobos/features/rides/book_ride_screen.dart';
import 'package:roadrobos/features/rides/ride_options_screen.dart';

import 'test_helpers.dart';

void main() {
  late MockAuthService mockAuth;

  setUpAll(() {
    registerTestFallbackValues();
  });

  setUp(() {
    mockAuth = MockAuthService();
    when(() => mockAuth.authStateChanges).thenAnswer((_) => const Stream.empty());
    when(() => mockAuth.restoredUser).thenReturn(null);
    when(() => mockAuth.currentUser).thenReturn(null);
  });

  group('Ride Booking Tests', () {
    testWidgets('book ride screen renders with map and search trigger',
        (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const BookRideScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );

      await tester.pump();

      // Assert: The ride booking screen should render
      expect(find.byType(BookRideScreen), findsOneWidget);
      // Assert: 'Where do you want to go?' search trigger is present
      expect(find.text('Where do you want to go?'), findsOneWidget);
    });

    testWidgets('book ride screen shows recent locations',
        (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const BookRideScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );

      await tester.pump();

      // Assert: Recent Locations header is displayed
      expect(find.text('Recent Locations'), findsOneWidget);
    });

    testWidgets('ride options screen renders with vehicle choices',
        (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const RideOptionsScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );

      await tester.pump();

      // Assert: Ride options screen renders
      expect(find.byType(RideOptionsScreen), findsOneWidget);
      // Assert: Book button is present
      expect(find.text('Book Ride Direct'), findsOneWidget);
    });

    testWidgets('ride options screen shows payment options',
        (WidgetTester tester) async {
      await pumpTestWidget(
        tester,
        child: const RideOptionsScreen(),
        overrides: [
          authServiceProvider.overrideWithValue(mockAuth),
        ],
      );

      await tester.pump();

      // Assert: Cash and Offers footer options are displayed
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Offers'), findsOneWidget);
    });
  });
}
