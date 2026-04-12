import 'package:cloud_firestore/cloud_firestore.dart';

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
      'userId': userId,
      'razoprayPaymentId': razoprayPaymentId,
      'razorpayOrderId': razorpayOrderId,
      'razorpaySignature': razorpaySignature,
      'baseAmount': baseAmount,
      'gstAmount': gstAmount,
      'platformFee': platformFee,
      'handlingCharges': handlingCharges,
      'totalAmount': totalAmount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map, String docId) {
    return AppTransaction(
      id: docId,
      userId: map['userId'] ?? '',
      razoprayPaymentId: map['razoprayPaymentId'] ?? '',
      razorpayOrderId: map['razorpayOrderId'],
      razorpaySignature: map['razorpaySignature'],
      baseAmount: (map['baseAmount'] ?? 0.0).toDouble(),
      gstAmount: (map['gstAmount'] ?? 0.0).toDouble(),
      platformFee: (map['platformFee'] ?? 0.0).toDouble(),
      handlingCharges: (map['handlingCharges'] ?? 0.0).toDouble(),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      status: map['status'] ?? 'SUCCESS',
    );
  }
}
