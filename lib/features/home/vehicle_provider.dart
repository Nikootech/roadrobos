import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/mock_data.dart';

class Vehicle {
  final String name;
  final String plate;
  final String fuel;
  final String year;
  final String type;

  Vehicle({required this.name, required this.plate, required this.fuel, required this.year, required this.type});
}

class VehicleNotifier extends StateNotifier<Vehicle> {
  VehicleNotifier() : super(Vehicle(
    name: MockData.vehicles[0]['name']!,
    plate: MockData.vehicles[0]['plate']!,
    fuel: MockData.vehicles[0]['fuel']!,
    year: MockData.vehicles[0]['year']!,
    type: MockData.vehicles[0]['type']!,
  ));

  void setVehicle(Vehicle vehicle) => state = vehicle;
}

final vehicleProvider = StateNotifierProvider<VehicleNotifier, Vehicle>((ref) => VehicleNotifier());

class AllVehiclesNotifier extends StateNotifier<List<Vehicle>> {
  AllVehiclesNotifier() : super(MockData.vehicles.map((v) => Vehicle(
    name: v['name']!,
    plate: v['plate']!,
    fuel: v['fuel']!,
    year: v['year']!,
    type: v['type']!,
  )).toList());

  void addVehicle(Vehicle vehicle) => state = [...state, vehicle];
}

final allVehiclesProvider = StateNotifierProvider<AllVehiclesNotifier, List<Vehicle>>((ref) => AllVehiclesNotifier());
