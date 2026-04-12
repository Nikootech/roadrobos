class RentalBooking {
  final String id;
  final String customerId;
  final String vehicleName;
  final String rentalType; // 'hourly' or 'daily'
  final DateTime startTime;
  final int duration; // in hours or days
  final String status; // active, completed, paid
  final double totalCost;
  final String details;

  RentalBooking({
    required this.id,
    required this.customerId,
    required this.vehicleName,
    required this.rentalType,
    required this.startTime,
    required this.duration,
    this.status = 'active',
    required this.totalCost,
    required this.details,
  });

  factory RentalBooking.fromMap(Map<String, dynamic> map, String documentId) {
    return RentalBooking(
      id: documentId,
      customerId: map['customerId'] ?? '',
      vehicleName: map['vehicleName'] ?? '',
      rentalType: map['rentalType'] ?? '',
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : DateTime.now(),
      duration: map['duration'] ?? 1,
      status: map['status'] ?? 'active',
      totalCost: (map['totalCost'] ?? 0.0).toDouble(),
      details: map['details'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'vehicleName': vehicleName,
      'rentalType': rentalType,
      'startTime': startTime.toIso8601String(),
      'duration': duration,
      'status': status,
      'totalCost': totalCost,
      'details': details,
    };
  }
}
