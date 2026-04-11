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

final selectedJobIdProvider = StateProvider<String?>((ref) => 'JOB-008');

final selectedJobProvider = Provider<TechnicianJob?>((ref) {
  final jobs = ref.watch(technicianProvider);
  final selectedId = ref.watch(selectedJobIdProvider);
  if (selectedId == null) return null;
  return jobs.firstWhere((j) => j.id == selectedId, orElse: () => jobs.first);
});

class TechnicianNotifier extends StateNotifier<List<TechnicianJob>> {
  Timer? _simulationTimer;

  TechnicianNotifier() : super(_mockJobs);

  static final _mockJobs = [
    TechnicianJob(
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
    ),
    TechnicianJob(
      id: 'JOB-009',
      estimatedCompletion: '01:30 PM',
      vehicleModel: 'Maruti Swift Dzire',
      vehiclePlate: 'KA 05 MJ 8899',
      serviceType: 'Brake Service',
      progress: 0.0,
      checklist: [
        ChecklistItem(task: 'Brake Pad Replacement', category: 'Core Service'),
        ChecklistItem(task: 'Check Rotors', category: 'Inspection'),
      ],
      parts: [],
      status: 'SCHEDULED',
    ),
    TechnicianJob(
      id: 'JOB-010',
      estimatedCompletion: '03:00 PM',
      vehicleModel: 'Honda City ZX',
      vehiclePlate: 'DL 09 CA 5566',
      serviceType: 'AC Service',
      progress: 1.0,
      checklist: [
        ChecklistItem(task: 'AC Compressor Service', category: 'Core Service', isDone: true),
        ChecklistItem(task: 'Clean Filters', category: 'Core Service', isDone: true),
      ],
      parts: [],
      status: 'COMPLETED',
    ),
  ];

  void toggleChecklistItem(String jobId, int index) {
    state = [
      for (final job in state)
        if (job.id == jobId)
          _updateJobChecklist(job, index)
        else
          job,
    ];
  }

  TechnicianJob _updateJobChecklist(TechnicianJob job, int index) {
    final newList = List<ChecklistItem>.from(job.checklist);
    newList[index] = newList[index].copyWith(isDone: !newList[index].isDone);
    
    final doneCount = newList.where((item) => item.isDone).length;
    final progress = doneCount / newList.length;
    
    return job.copyWith(checklist: newList, progress: progress);
  }

  void startMockProgress(String jobId) {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final jobIndex = state.indexWhere((j) => j.id == jobId);
      if (jobIndex == -1 || state[jobIndex].progress >= 1.0) {
        timer.cancel();
        return;
      }

      final job = state[jobIndex];
      final currentIndex = (job.progress * job.checklist.length).floor();
      if (currentIndex < job.checklist.length) {
        toggleChecklistItem(jobId, currentIndex);
        
        final updatedJob = state.firstWhere((j) => j.id == jobId);
        String newStatus = 'IN PROGRESS';
        if (updatedJob.progress > 0.8) {
          newStatus = 'QUALITY CHECK';
        } else if (updatedJob.progress == 1.0) {
          newStatus = 'COMPLETED';
        }
        
        _updateJobStatus(jobId, newStatus);
      }
    });
  }

  void _updateJobStatus(String jobId, String status) {
    state = [
      for (final job in state)
        if (job.id == jobId) job.copyWith(status: status) else job,
    ];
  }

  void resetProgress(String jobId) {
    _simulationTimer?.cancel();
    // This simple mock reset doesn't restore original mock state for specific job
  }

  void createJobFromBooking(BookingState booking) {
    final checklist = booking.packageItems.isNotEmpty 
      ? booking.packageItems.map((item) => ChecklistItem(task: item, category: 'Service Item')).toList()
      : [
          ChecklistItem(task: 'General Inspection', category: 'Initial'),
          ChecklistItem(task: 'Service Execution', category: 'Main'),
          ChecklistItem(task: 'Final Quality Check', category: 'Quality'),
        ];

    final newJob = TechnicianJob(
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
    
    state = [...state, newJob];
  }

  void createJob(TechnicianJob job) {
    state = [...state, job];
  }

  void updateJob(TechnicianJob job) {
    state = [
      for (final j in state)
        if (j.id == job.id) job else j,
    ];
  }

  void acceptJob(String jobId) {
    _updateJobStatus(jobId, 'ACCEPTED');
  }

  void startJob(String jobId) {
    _updateJobStatus(jobId, 'IN PROGRESS');
  }

  void finishJob(String jobId) {
    state = [
      for (final job in state)
        if (job.id == jobId) job.copyWith(status: 'COMPLETED', progress: 1.0) else job,
    ];
  }

  void addSparePart(String jobId, SparePart part) {
    state = [
      for (final job in state)
        if (job.id == jobId) job.copyWith(parts: [...job.parts, part]) else job,
    ];
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}

final technicianProvider = StateNotifierProvider<TechnicianNotifier, List<TechnicianJob>>((ref) {
  return TechnicianNotifier();
});
