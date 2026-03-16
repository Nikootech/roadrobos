import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RentalType { hourly, daily }

final selectedRentalTypeProvider = StateProvider<RentalType>((ref) => RentalType.hourly);

final selectedVehicleProvider = StateProvider<Map<String, dynamic>?>((ref) => null);

final rentalPriceProvider = Provider<String>((ref) {
  final vehicle = ref.watch(selectedVehicleProvider);
  final type = ref.watch(selectedRentalTypeProvider);
  
  if (vehicle == null) return '₹0';
  
  if (type == RentalType.hourly) {
    return vehicle['price'] ?? '₹150';
  } else {
    // Basic logic for daily price (e.g., 6x hourly)
    final hourly = int.tryParse((vehicle['price'] as String).replaceAll(RegExp(r'[^0-9]'), '')) ?? 150;
    return '₹${hourly * 6}';
  }
});
