import '../extensions/datetime_extensions.dart';

class RentalBooking {
  final String id;
  final String customerId;
  final String vehicleName;
  final String rentalType; // 'hourly' or 'daily'
  final DateTime startTime;
  final int duration; // in hours or days
  final String status; // active, completed, paid
  final double totalCost;
  final Map<String, dynamic> details;

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
      customerId: map['customer_id'] ?? '',
      vehicleName: map['vehicle_name'] ?? '',
      rentalType: map['rental_type'] ?? '',
      startTime: map['start_time'] != null ? DateTime.parse(map['start_time']) : DateTime.now(),
      duration: map['duration'] ?? 1,
      status: map['status'] ?? 'active',
      totalCost: (map['total_cost'] ?? 0.0).toDouble(),
      details: map['details'] is Map ? Map<String, dynamic>.from(map['details']) : {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'vehicle_name': vehicleName,
      'rental_type': rentalType,
      'start_time': startTime.utcIso,
      'duration': duration,
      'status': status,
      'total_cost': totalCost,
      'details': details,
    };
  }
}
