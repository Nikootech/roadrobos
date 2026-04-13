class ServiceBooking {
  final String id;
  final String customerId;
  final String? techId;
  final String vehicleName;
  final String vehiclePlate;
  final String packageName;
  final String date;
  final String time;
  final String status;
  final double totalCost;
  final String details;
  final DateTime createdAt;

  ServiceBooking({
    required this.id,
    required this.customerId,
    this.techId,
    required this.vehicleName,
    required this.vehiclePlate,
    required this.packageName,
    required this.date,
    required this.time,
    this.status = 'pending',
    required this.totalCost,
    required this.details,
    required this.createdAt,
  });

  factory ServiceBooking.fromMap(Map<String, dynamic> map, String documentId) {
    return ServiceBooking(
      id: documentId,
      customerId: map['customer_id'] ?? '',
      techId: map['tech_id'],
      vehicleName: map['vehicle_name'] ?? '',
      vehiclePlate: map['vehicle_plate'] ?? '',
      packageName: map['package_name'] ?? '',
      date: map['booking_date'] ?? '',
      time: map['booking_time'] ?? '',
      status: map['status'] ?? 'pending',
      totalCost: (map['total_cost'] ?? 0.0).toDouble(),
      details: map['details'].toString(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'tech_id': techId,
      'vehicle_name': vehicleName,
      'vehicle_plate': vehiclePlate,
      'package_name': packageName,
      'booking_date': date,
      'booking_time': time,
      'status': status,
      'total_cost': totalCost,
      'details': details,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
