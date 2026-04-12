import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/user_vehicle_repository.dart';
import '../profile/user_provider.dart';
import '../../core/data/mock_data.dart';

// Alias for backward compatibility across the app
typedef Vehicle = UserVehicle;

// Single selected vehicle state (for active UI interactions)
class SelectedVehicleNotifier extends StateNotifier<Vehicle> {
  SelectedVehicleNotifier() : super(Vehicle(
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

final vehicleProvider = StateNotifierProvider<SelectedVehicleNotifier, Vehicle>((ref) => SelectedVehicleNotifier());

class AllVehiclesNotifier extends StateNotifier<List<Vehicle>> {
  final Ref ref;
  
  AllVehiclesNotifier(this.ref) : super([]) {
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    final userState = ref.read(userProvider);
    if (userState.user == null) {
      // Fallback dummy for unauthenticated demo state
      state = [
        Vehicle(id: 'v1', userId: 'demo', name: 'Honda City', plate: 'MH 04 XY 4321', fuel: 'Petrol', year: '2022', type: 'Car')
      ];
      return;
    }

    try {
      final repo = ref.read(userVehicleRepositoryProvider);
      final vehicles = await repo.getUserVehicles(userState.user!.id);
      
      if (vehicles.isNotEmpty) {
        state = vehicles;
        if (ref.read(vehicleProvider).id == 'placeholder') {
          ref.read(vehicleProvider.notifier).setVehicle(vehicles.first);
        }
      } else {
        state = [];
      }
    } catch (e) {
      // Keep empty state on error
      state = [];
    }
  }

  void addVehicle(Vehicle vehicle) {
    state = [...state, vehicle];
    final userState = ref.read(userProvider);
    if (userState.user != null) {
      ref.read(userVehicleRepositoryProvider).addVehicle(vehicle);
    }
  }
}

final allVehiclesProvider = StateNotifierProvider<AllVehiclesNotifier, List<Vehicle>>((ref) {
  return AllVehiclesNotifier(ref);
});
