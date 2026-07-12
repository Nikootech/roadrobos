// lib/core/models/delivery_order.dart
// Data model for a delivery order.

enum DeliveryStatus {
  pending,
  accepted,
  pickedUp,
  inTransit,
  delivered,
  cancelled;

  static DeliveryStatus fromString(String s) {
    switch (s) {
      case 'accepted':
        return DeliveryStatus.accepted;
      case 'picked_up':
        return DeliveryStatus.pickedUp;
      case 'in_transit':
        return DeliveryStatus.inTransit;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'cancelled':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.pending;
    }
  }

  String toDbString() {
    switch (this) {
      case DeliveryStatus.pending:
        return 'pending';
      case DeliveryStatus.accepted:
        return 'accepted';
      case DeliveryStatus.pickedUp:
        return 'picked_up';
      case DeliveryStatus.inTransit:
        return 'in_transit';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.cancelled:
        return 'cancelled';
    }
  }

  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'Pending';
      case DeliveryStatus.accepted:
        return 'Accepted';
      case DeliveryStatus.pickedUp:
        return 'Picked Up';
      case DeliveryStatus.inTransit:
        return 'In Transit';
      case DeliveryStatus.delivered:
        return 'Delivered';
      case DeliveryStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class DeliveryOrder {
  final String id;
  final String customerId;
  final String? driverId;
  final String pickupAddress;
  final String dropoffAddress;
  final String packageDescription;
  final double weightKg;
  final DeliveryStatus status;
  final double estimatedPrice;
  final double? finalPrice;
  final String? proofImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryOrder({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.packageDescription,
    required this.weightKg,
    required this.status,
    required this.estimatedPrice,
    this.finalPrice,
    this.proofImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryOrder.fromMap(Map<String, dynamic> map) {
    return DeliveryOrder(
      id: map['id'] as String,
      customerId: map['customer_id'] as String,
      driverId: map['driver_id'] as String?,
      pickupAddress: map['pickup_address'] as String,
      dropoffAddress: map['dropoff_address'] as String,
      packageDescription: map['package_description'] as String? ?? '',
      weightKg: (map['weight_kg'] as num?)?.toDouble() ?? 1.0,
      status: DeliveryStatus.fromString(map['status'] as String? ?? 'pending'),
      estimatedPrice: (map['estimated_price'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (map['final_price'] as num?)?.toDouble(),
      proofImageUrl: map['proof_image_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'customer_id': customerId,
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'package_description': packageDescription,
      'weight_kg': weightKg,
      'status': status.toDbString(),
      'estimated_price': estimatedPrice,
    };
  }

  DeliveryOrder copyWith({
    String? driverId,
    DeliveryStatus? status,
    double? finalPrice,
    String? proofImageUrl,
  }) {
    return DeliveryOrder(
      id: id,
      customerId: customerId,
      driverId: driverId ?? this.driverId,
      pickupAddress: pickupAddress,
      dropoffAddress: dropoffAddress,
      packageDescription: packageDescription,
      weightKg: weightKg,
      status: status ?? this.status,
      estimatedPrice: estimatedPrice,
      finalPrice: finalPrice ?? this.finalPrice,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
