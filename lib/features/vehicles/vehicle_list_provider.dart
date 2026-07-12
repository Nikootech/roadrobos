import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/repositories/user_vehicle_repository.dart';
import '../profile/user_provider.dart';
import '../../core/utils/async_error_handler.dart';

class VehicleListNotifier extends AsyncNotifier<List<UserVehicle>> {
  @override
  Future<List<UserVehicle>> build() async {
    final userState = ref.watch(userProvider);
    final userId = userState.user?.id;
    if (userId == null || userId.isEmpty) {
      return [];
    }
    final repository = ref.watch(userVehicleRepositoryProvider);
    return repository.getUserVehicles(userId);
  }

  Future<void> addVehicle(UserVehicle vehicle) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(userVehicleRepositoryProvider);
      await repository.addVehicle(vehicle);
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      final userFriendlyMsg = AsyncErrorHandler.handleError(e, st);
      state = AsyncValue.error(userFriendlyMsg, st);
      rethrow;
    }
  }

  Future<void> setPrimary(String vehicleId) async {
    state = const AsyncValue.loading();
    try {
      final userState = ref.read(userProvider);
      final userId = userState.user?.id;
      if (userId == null || userId.isEmpty) return;

      final repository = ref.read(userVehicleRepositoryProvider);
      await repository.setPrimaryVehicle(userId, vehicleId);
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      final userFriendlyMsg = AsyncErrorHandler.handleError(e, st);
      state = AsyncValue.error(userFriendlyMsg, st);
      rethrow;
    }
  }

  Future<void> deleteVehicle(String vehicleId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(userVehicleRepositoryProvider);
      await repository.deleteVehicle(vehicleId);
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      final userFriendlyMsg = AsyncErrorHandler.handleError(e, st);
      state = AsyncValue.error(userFriendlyMsg, st);
      rethrow;
    }
  }

  Future<void> updateVehicle(UserVehicle vehicle) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(userVehicleRepositoryProvider);
      await repository.updateVehicle(vehicle);
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      final userFriendlyMsg = AsyncErrorHandler.handleError(e, st);
      state = AsyncValue.error(userFriendlyMsg, st);
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final vehicleListProvider =
    AsyncNotifierProvider<VehicleListNotifier, List<UserVehicle>>(() {
  return VehicleListNotifier();
});
