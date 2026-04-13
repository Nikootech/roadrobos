class RideBooking {
  final String id;
  final String customerId;
  final String? driverId;
  final String pickupLocation;
  final String pickupAddress;
  final String dropLocation;
  final String dropAddress;
  final String status;
  final double fare;
  final DateTime createdAt;

  RideBooking({
    required this.id,
    required this.customerId,
    this.driverId,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.dropLocation,
    required this.dropAddress,
    this.status = 'pending',
    required this.fare,
    required this.createdAt,
  });

  factory RideBooking.fromMap(Map<String, dynamic> map, String documentId) {
    return RideBooking(
      id: documentId,
      customerId: map['customer_id'] ?? '',
      driverId: map['driver_id'],
      pickupLocation: map['pickup_location'] ?? '',
      pickupAddress: map['pickup_address'] ?? '',
      dropLocation: map['destination_location'] ?? map['dropLocation'] ?? '',
      dropAddress: map['destination_address'] ?? map['dropAddress'] ?? '',
      status: map['status'] ?? 'pending',
      fare: (map['fare'] ?? 0.0).toDouble(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'driver_id': driverId,
      'pickup_location': pickupLocation,
      'pickup_address': pickupAddress,
      'destination_location': dropLocation,
      'destination_address': dropAddress,
      'status': status,
      'fare': fare,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
