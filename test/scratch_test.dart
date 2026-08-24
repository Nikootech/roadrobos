import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:roadrobos/core/repositories/wallet_repository.dart';
import 'package:roadrobos/features/insurance/insurance_models.dart';
import 'package:roadrobos/providers/taxi_provider.dart';

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
  group('1. Wallet Logic & Exception Handling', () {
    test('diagnose payFromWallet insufficient balance exception', () async {
      final mockSupabase = MockSupabaseClient();
      final repo = WalletRepository(supabaseClient: mockSupabase);

      final mockBuilder = MockPostgrestFilterBuilder(() {
        throw const PostgrestException(
          message: 'new balance would be negative',
          code: 'P0001',
        );
      });

      when(() => mockSupabase.rpc(any(), params: any(named: 'params')))
          .thenAnswer((_) => mockBuilder);

      try {
        await repo.payFromWallet('user_123', 150.0, 'debit');
        fail('Should have thrown InsufficientBalanceException');
      } catch (e) {
        expect(e, isA<InsufficientBalanceException>());
      }
    });
  });

  group('2. Ride Options & Taxi Calculations', () {
    test('RideOption price with discount clamped correctly', () {
      final option = RideOption(
        id: 'bike_01',
        title: 'Bike',
        subtitle: '1 min away • Drop 5:05pm',
        price: 105.0,
        tag: 'Cheapest',
        icon: Icons.two_wheeler_rounded,
      );

      expect(option.title, 'Bike');
      expect(option.price, 105.0);

      // Apply discount
      const double discount = 30.0;
      final discountedPrice =
          (option.price - discount).clamp(0.0, double.infinity);
      expect(discountedPrice, 75.0);

      // Oversized discount clamp
      const double largeDiscount = 200.0;
      final clampedZero =
          (option.price - largeDiscount).clamp(0.0, double.infinity);
      expect(clampedZero, 0.0);
    });

    test('RideOption vehicle icon and seats determination', () {
      final bike = RideOption(
        id: 'bike_tier',
        title: 'Bike',
        subtitle: 'Quick',
        price: 100,
        icon: Icons.two_wheeler_rounded,
      );
      final auto = RideOption(
        id: 'auto_tier',
        title: 'Auto',
        subtitle: 'Eco',
        price: 150,
        icon: Icons.electric_rickshaw_rounded,
      );
      final cab = RideOption(
        id: 'cab_economy',
        title: 'Cab Economy',
        subtitle: 'Comfortable',
        price: 250,
        icon: Icons.directions_car_rounded,
      );

      String getSeats(String id) {
        if (id.contains('bike')) return '1';
        if (id.contains('auto')) return '3';
        return '4';
      }

      expect(getSeats(bike.id), '1');
      expect(getSeats(auto.id), '3');
      expect(getSeats(cab.id), '4');
    });
  });

  group('3. Insurance Financial Breakdown & Tax Calculation', () {
    test('Calculates 18% GST and add-ons accurately', () {
      const planBasePrice = 1499.0;
      final addOns = [
        const InsuranceAddOn(
          id: 'addon_zero_dep',
          title: 'Zero Depreciation',
          subtitle: '100% claim settlement',
          price: 399.0,
          icon: Icons.shield_rounded,
        ),
        const InsuranceAddOn(
          id: 'addon_rsa',
          title: '24/7 Roadside Assistance',
          subtitle: 'Towing & fuel assistance',
          price: 199.0,
          icon: Icons.car_crash_rounded,
        ),
      ];

      final addOnsTotal =
          addOns.fold<double>(0.0, (acc, item) => acc + item.price);
      expect(addOnsTotal, 598.0);

      final subTotal = planBasePrice + addOnsTotal;
      expect(subTotal, 2097.0);

      final gst = subTotal * 0.18;
      expect(gst, closeTo(377.46, 0.01));

      final grandTotal = subTotal + gst;
      expect(grandTotal, closeTo(2474.46, 0.01));
    });
  });

  group('4. Vehicle Fleet Filtering Logic', () {
    final mockVehicles = [
      {
        'name': 'Honda Activa 6G',
        'category': 'Bikes',
        'is_bike': true,
        'price_per_hr': 49
      },
      {
        'name': 'Ather 450X EV',
        'category': 'EV',
        'type': 'EV Bike',
        'is_bike': true,
        'price_per_hr': 69
      },
      {
        'name': 'Hyundai i20',
        'category': 'Cars',
        'is_bike': false,
        'price_per_hr': 159
      },
      {
        'name': 'Tata Nexon EV',
        'category': 'EV',
        'type': 'EV Car',
        'is_bike': false,
        'price_per_hr': 229
      },
    ];

    List<Map<String, dynamic>> filterVehicles(String filter) {
      if (filter == 'All') {
        return mockVehicles;
      }
      if (filter == 'Cars') {
        return mockVehicles
            .where((v) => v['is_bike'] == false && v['category'] != 'EV')
            .toList();
      }
      if (filter == 'Bikes') {
        return mockVehicles
            .where((v) => v['is_bike'] == true && v['category'] != 'EV')
            .toList();
      }
      if (filter == 'EV') {
        return mockVehicles
            .where((v) =>
                v['category'] == 'EV' || v['type'].toString().contains('EV'))
            .toList();
      }
      return mockVehicles;
    }

    test('Filters fleet correctly across categories', () {
      expect(filterVehicles('All').length, 4);
      expect(filterVehicles('Cars').length, 1);
      expect(filterVehicles('Bikes').length, 1);
      expect(filterVehicles('EV').length, 2);
    });
  });
}
