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
      customerId: map['customerId'] ?? '',
      driverId: map['driverId'],
      pickupLocation: map['pickupLocation'] ?? '',
      pickupAddress: map['pickupAddress'] ?? '',
      dropLocation: map['dropLocation'] ?? '',
      dropAddress: map['dropAddress'] ?? '',
      status: map['status'] ?? 'pending',
      fare: (map['fare'] ?? 0.0).toDouble(),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'pickupAddress': pickupAddress,
      'dropLocation': dropLocation,
      'dropAddress': dropAddress,
      'status': status,
      'fare': fare,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
