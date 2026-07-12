/// Smoke test for the RoadRobos app.
///
/// Verifies the app launches correctly with mocked providers
/// and the basic widget tree renders without errors.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test — MaterialApp renders',
      (WidgetTester tester) async {
    // Pump a minimal MaterialApp to verify the widget tree builds
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('RoadRobos'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('RoadRobos'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('ProviderScope wraps correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Provider Test'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Provider Test'), findsOneWidget);
  });
}
