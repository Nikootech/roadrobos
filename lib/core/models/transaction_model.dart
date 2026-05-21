
class AppTransaction {
  final String id;
  final String userId;
  final String razoprayPaymentId;
  final String? razorpayOrderId;
  final String? razorpaySignature;
  final double baseAmount;
  final double gstAmount;
  final double platformFee;
  final double handlingCharges;
  final double totalAmount;
  final String description;
  final DateTime timestamp;
  final String status;

  AppTransaction({
    required this.id,
    required this.userId,
    required this.razoprayPaymentId,
    this.razorpayOrderId,
    this.razorpaySignature,
    required this.baseAmount,
    required this.gstAmount,
    required this.platformFee,
    required this.handlingCharges,
    required this.totalAmount,
    required this.description,
    required this.timestamp,
    this.status = 'SUCCESS',
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'razorpay_payment_id': razoprayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
      'base_amount': baseAmount,
      'gst_amount': gstAmount,
      'platform_fee': platformFee,
      'handling_charges': handlingCharges,
      'total_amount': totalAmount,
      'description': description,
      'created_at': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map, String docId) {
    return AppTransaction(
      id: docId,
      userId: map['user_id'] ?? map['userId'] ?? '',
      razoprayPaymentId: map['razorpay_payment_id'] ?? map['razoprayPaymentId'] ?? '',
      razorpayOrderId: map['razorpay_order_id'] ?? map['razorpayOrderId'],
      razorpaySignature: map['razorpay_signature'] ?? map['razorpaySignature'],
      baseAmount: (map['base_amount'] ?? map['baseAmount'] ?? 0.0).toDouble(),
      gstAmount: (map['gst_amount'] ?? map['gstAmount'] ?? 0.0).toDouble(),
      platformFee: (map['platform_fee'] ?? map['platformFee'] ?? 0.0).toDouble(),
      handlingCharges: (map['handling_charges'] ?? map['handlingCharges'] ?? 0.0).toDouble(),
      totalAmount: (map['total_amount'] ?? map['totalAmount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      timestamp: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : map['timestamp'] != null 
              ? DateTime.parse(map['timestamp']) 
              : DateTime.now(),
      status: map['status'] ?? 'SUCCESS',
    );
  }
}
