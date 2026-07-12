import 'package:flutter_test/flutter_test.dart';
import 'package:roadrobos/core/services/pricing_service.dart';

void main() {
  group('PricingService Unit Tests', () {
    setUp(() {
      // Reset to default constants before each test
      PricingService.gstRate = 0.18;
      PricingService.platformFee = 20.0;
      PricingService.handlingCharges = 10.0;
    });

    test('calculateBill calculates breakdown correctly with default parameters',
        () {
      const baseAmount = 100.0;
      final breakdown = PricingService.calculateBill(baseAmount);

      // Taxable total = 100.0 + 20.0 (platform fee) + 10.0 (handling fee) = 130.0
      // GST = 130.0 * 0.18 = 23.4
      // Total payable = 130.0 + 23.4 = 153.4

      expect(breakdown.baseAmount, equals(100.0));
      expect(breakdown.platformFee, equals(20.0));
      expect(breakdown.handlingCharges, equals(10.0));
      expect(breakdown.gstAmount, equals(23.4));
      expect(breakdown.totalPayable, equals(153.4));
    });

    test('calculateBill responds dynamically when constants are updated', () {
      // Update variables dynamically (DB config simulation)
      PricingService.gstRate = 0.05; // 5% GST
      PricingService.platformFee = 10.0;
      PricingService.handlingCharges = 5.0;

      const baseAmount = 100.0;
      final breakdown = PricingService.calculateBill(baseAmount);

      // Taxable total = 100.0 + 10.0 + 5.0 = 115.0
      // GST = 115.0 * 0.05 = 5.75
      // Total payable = 115.0 + 5.75 = 120.75

      expect(breakdown.baseAmount, equals(100.0));
      expect(breakdown.platformFee, equals(10.0));
      expect(breakdown.handlingCharges, equals(5.0));
      expect(breakdown.gstAmount, equals(5.75));
      expect(breakdown.totalPayable, equals(120.75));
    });

    test('BillBreakdown maps correctly to map format', () {
      final breakdown = BillBreakdown(
        baseAmount: 100.0,
        gstAmount: 18.0,
        platformFee: 20.0,
        handlingCharges: 10.0,
        totalPayable: 148.0,
      );

      final map = breakdown.toMap();

      expect(map['baseAmount'], equals(100.0));
      expect(map['gstAmount'], equals(18.0));
      expect(map['platformFee'], equals(20.0));
      expect(map['handlingCharges'], equals(10.0));
      expect(map['totalPayable'], equals(148.0));
    });
  });
}
