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

class PricingService {
  static const double gstRate = 0.18;
  static const double platformFee = 20.0;
  static const double handlingCharges = 10.0;

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
