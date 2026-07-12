import '../extensions/datetime_extensions.dart';

class RideBooking {
  final String id;
  final String customerId;
  final String? driverId;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLat;
  final double pickupLng;
  final double destLat;
  final double destLng;
  final String status;
  final double fare;
  final String? vehicleType;
  final String? otp;
  final DateTime createdAt;
  final DateTime? scheduledFor;

  RideBooking({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.destLat,
    required this.destLng,
    this.status = 'searching',
    required this.fare,
    this.vehicleType,
    this.otp,
    required this.createdAt,
    this.scheduledFor,
  });

  factory RideBooking.fromMap(Map<String, dynamic> map, String documentId) {
    return RideBooking(
      id: documentId,
      customerId: map['customer_id'] ?? '',
      driverId: map['driver_id'],
      pickupAddress: map['pickup_address'] ?? '',
      destinationAddress: map['destination_address'] ?? '',
      pickupLat: (map['pickup_lat'] ?? 0.0).toDouble(),
      pickupLng: (map['pickup_lng'] ?? 0.0).toDouble(),
      destLat: (map['dest_lat'] ?? 0.0).toDouble(),
      destLng: (map['dest_lng'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'searching',
      fare: (map['fare'] ?? 0.0).toDouble(),
      vehicleType: map['vehicle_type'],
      otp: map['otp']?.toString(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      scheduledFor: map['scheduled_for'] != null ? DateTime.parse(map['scheduled_for']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'driver_id': driverId,
      'pickup_address': pickupAddress,
      'destination_address': destinationAddress,
      'pickup_lat': pickupLat,
      'pickup_lng': pickupLng,
      'dest_lat': destLat,
      'dest_lng': destLng,
      'status': status,
      'fare': fare,
      'vehicle_type': vehicleType,
      'otp': otp,
      'created_at': createdAt.utcIso,
      if (scheduledFor != null) 'scheduled_for': scheduledFor!.utcIso,
    };
  }
}
