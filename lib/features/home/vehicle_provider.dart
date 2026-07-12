import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/user_vehicle_repository.dart';
import '../profile/user_provider.dart';

// Alias for backward compatibility across the app
typedef Vehicle = UserVehicle;

// Single selected vehicle state (for active UI interactions)
class SelectedVehicleNotifier extends StateNotifier<Vehicle> {
  SelectedVehicleNotifier()
      : super(Vehicle(
          id: 'placeholder',
          userId: 'placeholder',
          name: 'Loading...',
          plate: '... ...',
          fuel: '-',
          year: '-',
          type: 'Car',
        ));

  void setVehicle(Vehicle vehicle) => state = vehicle;
}

final vehicleProvider = StateNotifierProvider<SelectedVehicleNotifier, Vehicle>(
    (ref) => SelectedVehicleNotifier());

class AllVehiclesNotifier extends StateNotifier<List<Vehicle>> {
  final Ref ref;
  StreamSubscription<List<Vehicle>>? _subscription;

  AllVehiclesNotifier(this.ref) : super([]) {
    _init();
  }

  void _init() {
    ref.listen<UserState>(userProvider, (previous, next) {
      if (next.user?.id != previous?.user?.id) {
        _subscribeToVehicles(next.user?.id);
      }
    }, fireImmediately: true);
  }

  void _subscribeToVehicles(String? userId) {
    _subscription?.cancel();
    if (userId == null || userId.isEmpty || userId.startsWith('demo_')) {
      // Fallback dummy for unauthenticated demo state
      state = [
        Vehicle(
            id: 'v1',
            userId: 'demo',
            name: 'Honda City',
            plate: 'MH 04 XY 4321',
            fuel: 'Petrol',
            year: 2022,
            type: 'Car')
      ];
      // Auto-select the demo vehicle
      ref.read(vehicleProvider.notifier).setVehicle(state.first);
      return;
    }

      try {
      final repo = ref.read(userVehicleRepositoryProvider);
      _subscription = repo.getUserVehiclesStream(userId).listen(
        (vehicles) {
          state = vehicles;
          // Auto-select first vehicle if none selected yet
          final currentId = ref.read(vehicleProvider).id;
          if (vehicles.isNotEmpty && (currentId == 'placeholder' || currentId.isEmpty)) {
            ref.read(vehicleProvider.notifier).setVehicle(vehicles.first);
          }
        },
        onError: (e) {
          state = [];
        },
      );
    } catch (e) {
      state = [];
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void addVehicle(Vehicle vehicle) {
    state = [...state, vehicle];
    final userState = ref.read(userProvider);
    if (userState.user != null) {
      ref.read(userVehicleRepositoryProvider).addVehicle(vehicle);
    }
    // If this is the first vehicle ever added, auto-select it
    final currentId = ref.read(vehicleProvider).id;
    if (currentId == 'placeholder' || state.length == 1) {
      ref.read(vehicleProvider.notifier).setVehicle(vehicle);
    }
  }
}

final allVehiclesProvider =
    StateNotifierProvider<AllVehiclesNotifier, List<Vehicle>>((ref) {
  return AllVehiclesNotifier(ref);
});
