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
      customerId: map['customerId'] ?? '',
      techId: map['techId'],
      vehicleName: map['vehicleName'] ?? '',
      vehiclePlate: map['vehiclePlate'] ?? '',
      packageName: map['packageName'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? 'pending',
      totalCost: (map['totalCost'] ?? 0.0).toDouble(),
      details: map['details'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'techId': techId,
      'vehicleName': vehicleName,
      'vehiclePlate': vehiclePlate,
      'packageName': packageName,
      'date': date,
      'time': time,
      'status': status,
      'totalCost': totalCost,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
