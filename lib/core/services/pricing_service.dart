import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BillBreakdown {
  final double baseAmount;
  final double gstAmount;
  final double platformFee;
  final double handlingCharges;
  final double totalPayable;

  BillBreakdown({
    required this.baseAmount,
    required this.gstAmount,
    required this.platformFee,
    required this.handlingCharges,
    required this.totalPayable,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseAmount': baseAmount,
      'gstAmount': gstAmount,
      'platformFee': platformFee,
      'handlingCharges': handlingCharges,
      'totalPayable': totalPayable,
    };
  }
}

/// Dynamic, database-driven Pricing Service.
/// Fetches active pricing rates from the `pricing_config` table (see migration
/// 040_pricing_config_table.sql) via [pricingConfigProvider].
///
/// If the network or DB fetch fails, falls back to default static constants.
class PricingService {
  static double gstRate = 0.18;
  static double platformFee = 20.0;
  static double handlingCharges = 10.0;

  static BillBreakdown calculateBill(double baseAmount) {
    // Basic fees before tax
    final taxableTotal = baseAmount + platformFee + handlingCharges;

    // GST on the taxable total (Fare + Fees)
    final gstAmount = taxableTotal * gstRate;

    // Final payable amount
    final totalPayable = taxableTotal + gstAmount;

    return BillBreakdown(
      baseAmount: baseAmount,
      gstAmount: gstAmount,
      platformFee: platformFee,
      handlingCharges: handlingCharges,
      totalPayable: totalPayable,
    );
  }
}

/// Riverpod provider to fetch and cache remote pricing configuration.
///
/// Must be read or watched at app startup (e.g. in [main.dart] or home screens)
/// to ensure local rates sync with remote configuration.
final pricingConfigProvider = FutureProvider<void>((ref) async {
  try {
    final client = Supabase.instance.client;
    final response = await client.rpc('get_active_pricing_config', params: {
      'p_service_type': 'all',
    }) as List<dynamic>;

    for (final row in response) {
      final key = row['key'] as String?;
      final val = double.tryParse(row['value'].toString());
      if (key != null && val != null) {
        switch (key) {
          case 'gst_rate':
            PricingService.gstRate = val;
            break;
          case 'platform_fee':
            PricingService.platformFee = val;
            break;
          case 'handling_charges':
            PricingService.handlingCharges = val;
            break;
        }
      }
    }
    if (kDebugMode) {
      debugPrint(
          'PricingService: Config updated. GST: ${PricingService.gstRate}, Platform: ${PricingService.platformFee}, Handling: ${PricingService.handlingCharges}');
    }
  } catch (e) {
    // Falls back silently to default values
    if (kDebugMode) {
      debugPrint(
          'PricingService: Failed to fetch remote config, using defaults. Error: $e');
    }
  }
});
