import 'package:flutter_riverpod/flutter_riverpod.dart';

class TechnicianJob {
  final String id;
  final String estimatedCompletion;
  final String vehicleModel;
  final String vehiclePlate;
  final double progress;
  final List<ChecklistItem> checklist;
  final List<SparePart> parts;
  final String status;

  TechnicianJob({
    required this.id,
    required this.estimatedCompletion,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.progress,
    required this.checklist,
    required this.parts,
    this.status = 'IN PROGRESS',
  });

  TechnicianJob copyWith({
    String? id,
    String? estimatedCompletion,
    String? vehicleModel,
    String? vehiclePlate,
    double? progress,
    List<ChecklistItem>? checklist,
    List<SparePart>? parts,
    String? status,
  }) {
    return TechnicianJob(
      id: id ?? this.id,
      estimatedCompletion: estimatedCompletion ?? this.estimatedCompletion,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      progress: progress ?? this.progress,
      checklist: checklist ?? this.checklist,
      parts: parts ?? this.parts,
      status: status ?? this.status,
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

class TechnicianNotifier extends StateNotifier<TechnicianJob?> {
  TechnicianNotifier() : super(_mockJob);

  static final _mockJob = TechnicianJob(
    id: 'JOB-008',
    estimatedCompletion: '4:30 PM',
    vehicleModel: '2021 Hyundai Creta SX',
    vehiclePlate: 'MH 12 AB 1234',
    progress: 0.35,
    checklist: [
      ChecklistItem(task: 'Engine Oil & Filter Change', category: 'Core Service', isDone: true),
      ChecklistItem(task: 'Brake Pad Inspection', category: 'Safety Check', isDone: true),
      ChecklistItem(task: 'Tyre Pressure & Rotation', category: 'Safety Check', isDone: false),
      ChecklistItem(task: 'Coolant Level Top-up', category: 'Core Service', isDone: false),
      ChecklistItem(task: 'Battery Health Report', category: 'Electrical', isDone: false),
      ChecklistItem(task: 'Body Washing & Polishing', category: 'Finishing', isDone: false),
    ],
    parts: [
      SparePart(name: 'Synthetic Engine Oil', qty: '4.5L'),
      SparePart(name: 'Oil Filter (OEM)', qty: '1 Unit'),
      SparePart(name: 'Wiper Fluid', qty: '1 Bottle', isFound: false),
    ],
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

  void addSparePart(SparePart part) {
    if (state == null) return;
    final newParts = List<SparePart>.from(state!.parts)..add(part);
    state = state!.copyWith(parts: newParts);
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
}

final technicianProvider = StateNotifierProvider<TechnicianNotifier, TechnicianJob?>((ref) {
  return TechnicianNotifier();
});
