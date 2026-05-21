import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roadrobos/core/repositories/technician_job_repository.dart';
import '../../core/models/technician_job_model.dart';
import '../profile/user_provider.dart';

// ─── Legacy UI-compatible wrappers ───
// These thin wrappers allow existing screens to work unchanged while
// the data now flows from Firestore underneath.

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

  /// Convert from Firestore model to UI model
  factory TechnicianJob.fromFirestore(TechnicianJobModel model) {
    return TechnicianJob(
      id: model.id,
      estimatedCompletion: model.estimatedCompletion,
      vehicleModel: model.vehicleModel,
      vehiclePlate: model.vehiclePlate,
      serviceType: model.serviceType,
      packageName: model.packageName,
      date: model.date,
      time: model.time,
      progress: model.progress,
      checklist: model.checklist.map((c) => ChecklistItem(
        task: c.task,
        category: c.category,
        isDone: c.isDone,
      )).toList(),
      parts: model.parts.map((p) => SparePart(
        name: p.name,
        qty: p.qty,
        isFound: p.isFound,
      )).toList(),
      status: model.status,
      price: model.price,
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

// ─── Booking State (unchanged, used by customer flow) ───

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

final selectedJobIdProvider = StateProvider<String?>((ref) => null);

final selectedJobProvider = Provider<TechnicianJob?>((ref) {
  final jobs = ref.watch(technicianProvider);
  final selectedId = ref.watch(selectedJobIdProvider);
  if (selectedId == null && jobs.isNotEmpty) return jobs.first;
  if (selectedId == null) return null;
  return jobs.cast<TechnicianJob?>().firstWhere((j) => j?.id == selectedId, orElse: () => jobs.isNotEmpty ? jobs.first : null);
});

// ─── Firestore-Backed Technician Notifier ───

class TechnicianNotifier extends StateNotifier<List<TechnicianJob>> {
  final Ref ref;
  final String? userId;
  StreamSubscription? _subscription;

  TechnicianNotifier(this.ref, this.userId) : super([]) {
    _listenToFirestore();
  }

  void _listenToFirestore() {
    final repo = ref.read(technicianJobRepositoryProvider);
    final stream = userId != null
        ? repo.watchJobsForTech(userId!)
        : repo.watchAllJobs();

    _subscription?.cancel();
    _subscription = stream.listen((firestoreJobs) {
      state = firestoreJobs.map((m) => TechnicianJob.fromFirestore(m)).toList();
      
      // Auto-select first job if none selected
      if (state.isNotEmpty && ref.read(selectedJobIdProvider) == null) {
        ref.read(selectedJobIdProvider.notifier).state = state.first.id;
      }
    });
  }

  void toggleChecklistItem(String jobId, int index) {
    final repo = ref.read(technicianJobRepositoryProvider);
    repo.toggleChecklistItem(jobId, index);
    // State will auto-update via the Firestore stream listener
  }

  void startMockProgress(String jobId) {
    // In production, progress comes from checklist completion via Firestore
    // This is kept for UI compatibility but now uses repository
    final repo = ref.read(technicianJobRepositoryProvider);
    repo.updateJobStatus(jobId, 'IN PROGRESS');
  }

  void resetProgress(String jobId) {
    // No-op in production; Firestore is the source of truth
  }

  void createJobFromBooking(BookingState booking) {
    final repo = ref.read(technicianJobRepositoryProvider);
    
    final checklist = booking.packageItems.isNotEmpty 
      ? booking.packageItems.map((item) => FirestoreChecklistItem(task: item, category: 'Service Item')).toList()
      : [
          FirestoreChecklistItem(task: 'General Inspection', category: 'Initial'),
          FirestoreChecklistItem(task: 'Service Execution', category: 'Main'),
          FirestoreChecklistItem(task: 'Final Quality Check', category: 'Quality'),
        ];

    final newJob = TechnicianJobModel(
      id: '', // Will be assigned by Firestore
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
      assignedTechId: userId,
    );
    
    repo.createJob(newJob);
    // State will auto-update via the Firestore stream listener
  }

  void createJob(TechnicianJob job) {
    final repo = ref.read(technicianJobRepositoryProvider);
    repo.createJob(TechnicianJobModel(
      id: '',
      estimatedCompletion: job.estimatedCompletion,
      vehicleModel: job.vehicleModel,
      vehiclePlate: job.vehiclePlate,
      serviceType: job.serviceType,
      packageName: job.packageName,
      date: job.date,
      time: job.time,
      progress: job.progress,
      checklist: job.checklist.map((c) => FirestoreChecklistItem(task: c.task, category: c.category, isDone: c.isDone)).toList(),
      parts: job.parts.map((p) => FirestoreSparePart(name: p.name, qty: p.qty, isFound: p.isFound)).toList(),
      status: job.status,
      price: job.price,
      assignedTechId: userId,
    ));
  }

  void updateJob(TechnicianJob job) {
    // Delegate checklist/status changes individually to repository
    final repo = ref.read(technicianJobRepositoryProvider);
    repo.updateJobStatus(job.id, job.status);
    repo.updateJobProgress(job.id, job.progress);
  }

  Future<void> updateVehicleDetails(String jobId, String model, String plate) async {
    final repo = ref.read(technicianJobRepositoryProvider);
    await repo.updateVehicleDetails(jobId, model, plate);
  }

  void acceptJob(String jobId) {
    ref.read(technicianJobRepositoryProvider).updateJobStatus(jobId, 'ACCEPTED');
  }

  void startJob(String jobId) {
    ref.read(technicianJobRepositoryProvider).updateJobStatus(jobId, 'IN PROGRESS');
  }

  void finishJob(String jobId) {
    ref.read(technicianJobRepositoryProvider).completeJob(jobId);
  }

  void addSparePart(String jobId, SparePart part) {
    ref.read(technicianJobRepositoryProvider).addSparePart(
      jobId,
      FirestoreSparePart(name: part.name, qty: part.qty, isFound: part.isFound),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final technicianProvider = StateNotifierProvider<TechnicianNotifier, List<TechnicianJob>>((ref) {
  final userState = ref.watch(userProvider);
  final userId = userState.user?.id;
  return TechnicianNotifier(ref, userId);
});
