import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

enum RentalType { hourly, daily }
enum RentalStatus { active, completed, paid }

class ActiveRental {
  final Map<String, dynamic> vehicle;
  final DateTime startTime;
  final Duration duration;
  final RentalStatus status;

  ActiveRental({
    required this.vehicle,
    required this.startTime,
    required this.duration,
    this.status = RentalStatus.active,
  });

  ActiveRental copyWith({RentalStatus? status}) {
    return ActiveRental(
      vehicle: vehicle,
      startTime: startTime,
      duration: duration,
      status: status ?? this.status,
    );
  }

  bool get isExpired => DateTime.now().isAfter(startTime.add(duration));
  Duration get remainingTime => startTime.add(duration).difference(DateTime.now());
}

class ActiveRentalNotifier extends StateNotifier<ActiveRental?> {
  ActiveRentalNotifier() : super(null);
  Timer? _timer;

  void startRental(Map<String, dynamic> vehicle, Duration duration) {
    state = ActiveRental(
      vehicle: vehicle,
      startTime: DateTime.now(),
      duration: duration,
    );
    
    // Simulation: Check for expiration every minute
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (state != null && state!.isExpired && state!.status == RentalStatus.active) {
        state = state!.copyWith(status: RentalStatus.completed);
        timer.cancel();
      }
    });
  }

  void completePayment() {
    if (state != null) {
      state = state!.copyWith(status: RentalStatus.paid);
    }
  }

  void clearRental() {
    _timer?.cancel();
    state = null;
  }
}

final selectedRentalTypeProvider = StateProvider<RentalType>((ref) => RentalType.hourly);
final selectedVehicleProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final activeRentalProvider = StateNotifierProvider<ActiveRentalNotifier, ActiveRental?>((ref) {
  return ActiveRentalNotifier();
});

final rentalPriceProvider = Provider<String>((ref) {
  final vehicle = ref.watch(selectedVehicleProvider);
  final type = ref.watch(selectedRentalTypeProvider);
  
  if (vehicle == null) return '₹0';
  
  if (type == RentalType.hourly) {
    return vehicle['price'] ?? '₹150';
  } else {
    final hourly = int.tryParse((vehicle['price'] as String).replaceAll(RegExp(r'[^0-9]'), '')) ?? 150;
    return '₹${hourly * 6}';
  }
});
