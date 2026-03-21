import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:roadrobos/features/taxi/taxi_ride_screen.dart';
import 'package:roadrobos/providers/taxi_provider.dart';

void main() {
  testWidgets('TaxiRideScreen completes full booking flow', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TaxiRideScreen(),
        ),
      ),
    );

    // 1. Check Initial State
    expect(find.text('Plan Your Ride'), findsOneWidget);
    expect(find.text('CONFIRM LOCATIONS'), findsOneWidget);

    // 2. Simulate Location Selection
    final container = ProviderScope.containerOf(tester.element(find.byType(TaxiRideScreen)));
    container.read(taxiProvider.notifier).setPickup(const LatLng(12.9716, 77.5946), 'HSR Layout');
    container.read(taxiProvider.notifier).setDropoff(const LatLng(12.9176, 77.6234), 'Silk Board');
    
    await tester.pumpAndSettle();

    // 3. Verify Fare Estimate Shown
    expect(find.text('Estimated Fare'), findsOneWidget);
    expect(find.text('BOOK NOW'), findsOneWidget);

    // 4. Click Book
    await tester.tap(find.text('BOOK NOW'));
    await tester.pump(); // Start booking status

    // 5. Verify Booking Overlay
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 6. Wait for Driver Assignment (Simulated delay)
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 7. Verify Tracking State
    expect(find.text('Captain Arriving'), findsOneWidget);
    expect(find.text('OTP: 4582'), findsOneWidget);
    expect(find.text('Sohan Kumar'), findsOneWidget);

    // 8. End Trip
    await tester.tap(find.text('ARRIVED? END TRIP'));
    await tester.pumpAndSettle();

    // 9. Verify Completion Dialog/State
    expect(find.text('Rental Time Completed!'), findsOneWidget);
  });
}
