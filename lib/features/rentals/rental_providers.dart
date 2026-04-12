import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../core/repositories/rental_booking_repository.dart';
import '../../core/models/rental_booking.dart';
import '../profile/user_provider.dart';

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
  final Ref ref;
  ActiveRentalNotifier(this.ref) : super(null);
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

  Future<void> completePayment({
    required double totalCost,
    String? paymentId,
  }) async {
    if (state != null) {
      final custId = ref.read(userProvider).user?.id ?? 'demo';
      
      await ref.read(rentalBookingRepositoryProvider).createRentalBooking(RentalBooking(
        id: '',
        customerId: custId,
        vehicleName: state!.vehicle['name'] ?? 'Unknown',
        rentalType: 'hourly',
        startTime: state!.startTime,
        duration: state!.duration.inHours,
        totalCost: totalCost,
        details: paymentId != null ? 'Razorpay ID: $paymentId' : '',
        status: 'paid'
      ));
      
      _timer?.cancel();
      _timer = null;
      
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

final activeRentalProvider = StateNotifierProvider<ActiveRentalNotifier, ActiveRental?>((ref) => ActiveRentalNotifier(ref));


class RecentlyViewedNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  RecentlyViewedNotifier() : super([]);

  void addView(Map<String, dynamic> vehicle) {
    final existingIndex = state.indexWhere((v) => v['name'] == vehicle['name']);
    
    List<Map<String, dynamic>> newState = List.from(state);
    if (existingIndex != -1) {
      newState.removeAt(existingIndex);
    }
    
    newState.insert(0, vehicle);
    
    // Cap at 10 items
    if (newState.length > 10) {
      newState = newState.sublist(0, 10);
    }
    
    state = newState;
  }

  void clearHistory() => state = [];
}

final recentlyViewedProvider = StateNotifierProvider<RecentlyViewedNotifier, List<Map<String, dynamic>>>((ref) {
  return RecentlyViewedNotifier();
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
