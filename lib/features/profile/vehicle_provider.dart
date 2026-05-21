import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/user_vehicle_repository.dart';
import 'user_provider.dart';

final vehicleProvider = StateNotifierProvider<VehicleNotifier, AsyncValue<List<UserVehicle>>>((ref) {
  final repository = ref.watch(userVehicleRepositoryProvider);
  final user = ref.watch(userProvider);
  return VehicleNotifier(repository, user.user?.id);
});

class VehicleNotifier extends StateNotifier<AsyncValue<List<UserVehicle>>> {
  final UserVehicleRepository _repository;
  final String? _userId;

  VehicleNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    if (_userId == null) {
      state = const AsyncValue.data([]);
      return;
    }
    
    state = const AsyncValue.loading();
    try {
      final vehicles = await _repository.getUserVehicles(_userId);
      state = AsyncValue.data(vehicles);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addVehicle({
    required String name,
    required String plate,
    required String fuel,
    required String year,
    required String type,
  }) async {
    if (_userId == null) return;

    try {
      final newVehicle = UserVehicle(
        id: '', // Supabase will generate this
        userId: _userId,
        name: name,
        plate: plate,
        fuel: fuel,
        year: year,
        type: type,
      );
      
      await _repository.addVehicle(newVehicle);
      await fetchVehicles(); // Refresh list
    } catch (e) {
      // Error handled by UI or state
      rethrow;
    }
  }
}
