import '../extensions/datetime_extensions.dart';

class FirestoreChecklistItem {
  final String task;
  final String category;
  final bool isDone;

  FirestoreChecklistItem({
    required this.task,
    required this.category,
    this.isDone = false,
  });

  Map<String, dynamic> toMap() => {
        'task': task,
        'category': category,
        'isDone': isDone,
      };

  factory FirestoreChecklistItem.fromMap(Map<String, dynamic> map) {
    return FirestoreChecklistItem(
      task: map['task'] ?? '',
      category: map['category'] ?? '',
      isDone: map['isDone'] ?? false,
    );
  }
}

class FirestoreSparePart {
  final String name;
  final String qty;
  final bool isFound;

  FirestoreSparePart({
    required this.name,
    required this.qty,
    this.isFound = true,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'qty': qty,
        'isFound': isFound,
      };

  factory FirestoreSparePart.fromMap(Map<String, dynamic> map) {
    return FirestoreSparePart(
      name: map['name'] ?? '',
      qty: map['qty'] ?? '',
      isFound: map['isFound'] ?? true,
    );
  }
}

class TechnicianJobModel {
  final String id;
  final String estimatedCompletion;
  final String vehicleModel;
  final String vehiclePlate;
  final String serviceType;
  final String packageName;
  final String date;
  final String time;
  final double progress;
  final List<FirestoreChecklistItem> checklist;
  final List<FirestoreSparePart> parts;
  final String
      status; // SCHEDULED, ACCEPTED, IN PROGRESS, QUALITY CHECK, COMPLETED
  final String price;
  final String? assignedTechId;
  final String? customerId;
  final String? serviceBookingId;
  final DateTime createdAt;

  TechnicianJobModel({
    required this.id,
    required this.estimatedCompletion,
    required this.vehicleModel,
    required this.vehiclePlate,
    this.serviceType = 'General Service',
    this.packageName = 'Basic',
    this.date = 'Today',
    this.time = 'Now',
    required this.progress,
    this.checklist = const [],
    this.parts = const [],
    this.status = 'SCHEDULED',
    this.price = '₹0',
    this.assignedTechId,
    this.customerId,
    this.serviceBookingId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'estimated_completion': estimatedCompletion,
        'vehicle_model': vehicleModel,
        'vehicle_plate': vehiclePlate,
        'service_type': serviceType,
        'package_name': packageName,
        'date': date,
        'time': time,
        'progress': progress,
        'checklist': checklist.map((c) => c.toMap()).toList(),
        'parts': parts.map((p) => p.toMap()).toList(),
        'status': status,
        'price': price,
        'assigned_tech_id': assignedTechId,
        'customer_id': customerId,
        'service_booking_id': serviceBookingId,
        'created_at': createdAt.utcIso,
      };

  factory TechnicianJobModel.fromMap(Map<String, dynamic> map, String docId) {
    return TechnicianJobModel(
      id: docId,
      estimatedCompletion: map['estimated_completion'] ?? '',
      vehicleModel: map['vehicle_model'] ?? '',
      vehiclePlate: map['vehicle_plate'] ?? '',
      serviceType: map['service_type'] ?? 'General Service',
      packageName: map['package_name'] ?? 'Basic',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      progress: (map['progress'] ?? 0.0).toDouble(),
      checklist: (map['checklist'] as List<dynamic>?)
              ?.map((c) =>
                  FirestoreChecklistItem.fromMap(Map<String, dynamic>.from(c)))
              .toList() ??
          [],
      parts: (map['parts'] as List<dynamic>?)
              ?.map((p) =>
                  FirestoreSparePart.fromMap(Map<String, dynamic>.from(p)))
              .toList() ??
          [],
      status: map['status'] ?? 'SCHEDULED',
      price: map['price'] ?? '₹0',
      assignedTechId: map['assigned_tech_id'],
      customerId: map['customer_id'],
      serviceBookingId: map['service_booking_id'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  TechnicianJobModel copyWith({
    String? id,
    String? estimatedCompletion,
    String? vehicleModel,
    String? vehiclePlate,
    String? serviceType,
    String? packageName,
    String? date,
    String? time,
    double? progress,
    List<FirestoreChecklistItem>? checklist,
    List<FirestoreSparePart>? parts,
    String? status,
    String? price,
    String? assignedTechId,
    String? customerId,
    String? serviceBookingId,
  }) {
    return TechnicianJobModel(
      id: id ?? this.id,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      serviceType: serviceType ?? this.serviceType,
      packageName: packageName ?? this.packageName,
      date: date ?? this.date,
      time: time ?? this.time,
      progress: progress ?? this.progress,
      checklist: checklist ?? this.checklist,
      parts: parts ?? this.parts,
      status: status ?? this.status,
      price: price ?? this.price,
      assignedTechId: assignedTechId ?? this.assignedTechId,
      customerId: customerId ?? this.customerId,
      serviceBookingId: serviceBookingId ?? this.serviceBookingId,
      createdAt: createdAt,
    );
  }
}
