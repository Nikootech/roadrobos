import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TechnicianJob {
  final String id;
  final String estimatedCompletion;
  final String vehicleModel;
  final String vehiclePlate;
  final String serviceType;
  final String packageName;
  final String date;
  final String time;
  final double progress;
  final List<ChecklistItem> checklist;
  final List<SparePart> parts;
  final String status;
  final String price;

  TechnicianJob({
    required this.id,
    required this.estimatedCompletion,
    required this.vehicleModel,
    required this.vehiclePlate,
    this.serviceType = 'General Service',
    this.packageName = 'Basic',
    this.date = 'Today',
    this.time = 'Now',
    required this.progress,
    required this.checklist,
    required this.parts,
    this.status = 'IN PROGRESS',
    this.price = '₹0',
  });

  TechnicianJob copyWith({
    String? id,
    String? estimatedCompletion,
    String? vehicleModel,
    String? vehiclePlate,
    String? serviceType,
    String? packageName,
    String? date,
    String? time,
    double? progress,
    List<ChecklistItem>? checklist,
    List<SparePart>? parts,
    String? status,
    String? price,
  }) {
    return TechnicianJob(
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
    );
  }
}

class ChecklistItem {
  final String task;
  final String category;
  final bool isDone;

  ChecklistItem({
    required this.task,
    required this.category,
    this.isDone = false,
  });

  ChecklistItem copyWith({bool? isDone}) {
    return ChecklistItem(
      task: task,
      category: category,
      isDone: isDone ?? this.isDone,
    );
  }
}

class SparePart {
  final String name;
  final String qty;
  final bool isFound;

  SparePart({
    required this.name,
    required this.qty,
    this.isFound = true,
  });
}

class BookingState {
  final String serviceType;
  final String vehicleModel;
  final String vehiclePlate;
  final String packageName;
  final String date;
  final String time;
  final String price;
  final List<String> packageItems;

  BookingState({
    this.serviceType = '',
    this.vehicleModel = 'Hyundai Creta',
    this.vehiclePlate = 'MH 02 AB 1234',
    this.packageName = '',
    this.date = '',
    this.time = '',
    this.price = '₹0',
    this.packageItems = const [],
  });

  BookingState copyWith({
    String? serviceType,
    String? vehicleModel,
    String? vehiclePlate,
    String? packageName,
    String? date,
    String? time,
    String? price,
    List<String>? packageItems,
  }) {
    return BookingState(
      serviceType: serviceType ?? this.serviceType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      packageName: packageName ?? this.packageName,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      packageItems: packageItems ?? this.packageItems,
    );
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(BookingState());

  void setServiceType(String type) => state = state.copyWith(serviceType: type);
  void setVehicle(String model, String plate) => state = state.copyWith(vehicleModel: model, vehiclePlate: plate);
  void setPackage(String name, String price, List<String> items) => state = state.copyWith(packageName: name, price: price, packageItems: items);
  void setSchedule(String date, String time) => state = state.copyWith(date: date, time: time);
  
  void reset() => state = BookingState();
}

final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) => BookingNotifier());

class TechnicianNotifier extends StateNotifier<TechnicianJob?> {
  Timer? _simulationTimer;

  TechnicianNotifier() : super(_mockJob);

  static final _mockJob = TechnicianJob(
    id: 'JOB-008',
    estimatedCompletion: '4:30 PM',
    vehicleModel: '2021 Hyundai Creta SX',
    vehiclePlate: 'MH 12 AB 1234',
    serviceType: 'General Service',
    packageName: 'Premium detailing',
    date: '23 March 2026',
    time: '02:00 PM',
    progress: 0.1,
    checklist: [
      ChecklistItem(task: 'Vehicle Inspection & Job Card', category: 'Core Service', isDone: true),
      ChecklistItem(task: 'Surface Cleaning (High Pressure)', category: 'Core Service', isDone: false),
      ChecklistItem(task: 'Interior Detailing & Polish', category: 'Finishing', isDone: false),
      ChecklistItem(task: 'Foam Cleaning & Rims Polish', category: 'Finishing', isDone: false),
      ChecklistItem(task: 'Engine Degreasing & Dressing', category: 'Finishing', isDone: false),
      ChecklistItem(task: 'Final Inspection & Ready', category: 'Finishing', isDone: false),
    ],
    parts: [
      SparePart(name: 'Ceramic Coating Wax', qty: '1 Box'),
      SparePart(name: 'Premium Glass Cleaner', qty: '1 Bottle'),
    ],
    status: 'ACCEPTED',
  );

  void toggleChecklistItem(int index) {
    if (state == null) return;
    
    final newList = List<ChecklistItem>.from(state!.checklist);
    newList[index] = newList[index].copyWith(isDone: !newList[index].isDone);
    
    // Recalculate progress
    final doneCount = newList.where((item) => item.isDone).length;
    final progress = doneCount / newList.length;
    
    state = state!.copyWith(checklist: newList, progress: progress);
  }

  void startMockProgress() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (state == null || state!.progress >= 1.0) {
        timer.cancel();
        return;
      }

      final currentIndex = (state!.progress * state!.checklist.length).floor();
      if (currentIndex < state!.checklist.length) {
        toggleChecklistItem(currentIndex);
        
        // Update status based on progress
        String newStatus = 'IN PROGRESS';
        if (state!.progress > 0.8) {
          newStatus = 'QUALITY CHECK';
        } else if (state!.progress == 1.0) {
          newStatus = 'COMPLETED';
        }
        
        state = state?.copyWith(status: newStatus);
      }
    });
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
  }

  void resetProgress() {
    _simulationTimer?.cancel();
    state = _mockJob;
  }

  void createJobFromBooking(BookingState booking) {
    _simulationTimer?.cancel();
    
    final checklist = booking.packageItems.isNotEmpty 
      ? booking.packageItems.map((item) => ChecklistItem(task: item, category: 'Service Item')).toList()
      : [
          ChecklistItem(task: 'General Inspection', category: 'Initial'),
          ChecklistItem(task: 'Service Execution', category: 'Main'),
          ChecklistItem(task: 'Final Quality Check', category: 'Quality'),
        ];

    state = TechnicianJob(
      id: 'JOB-${(100 + (DateTime.now().millisecondsSinceEpoch % 900))}',
      estimatedCompletion: booking.time, 
      vehicleModel: booking.vehicleModel,
      vehiclePlate: booking.vehiclePlate,
      serviceType: booking.serviceType,
      packageName: booking.packageName,
      date: booking.date,
      time: booking.time,
      price: booking.price,
      progress: 0.0,
      checklist: checklist,
      parts: [],
      status: 'SCHEDULED',
    );
  }

  void createJob(TechnicianJob job) {
    state = job;
  }

  void acceptJob() {
    state = state?.copyWith(status: 'ACCEPTED');
  }

  void startJob() {
    state = state?.copyWith(status: 'IN PROGRESS');
  }

  void finishJob() {
    state = state?.copyWith(status: 'COMPLETED', progress: 1.0);
  }

  void addSparePart(SparePart part) {
    if (state == null) return;
    state = state!.copyWith(parts: [...state!.parts, part]);
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

final technicianProvider = StateNotifierProvider<TechnicianNotifier, TechnicianJob?>((ref) {
  return TechnicianNotifier();
});
