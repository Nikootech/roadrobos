import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/providers/paginated_notifier.dart';
import '../../core/models/rental_vehicle.dart';

/// Cursor-based paginated list of available rental vehicles.
/// Replaces the old unbounded .select() query.
final rentalVehicleListProvider = AutoDisposeAsyncNotifierProvider<
    RentalVehicleListNotifier, PaginatedState<RentalVehicle>>(
  () => RentalVehicleListNotifier(),
);

class RentalVehicleListNotifier extends PaginatedNotifier<RentalVehicle> {
  @override
  Future<List<RentalVehicle>> fetchPage(int offset, int limit) async {
    final rows = await Supabase.instance.client
        .from('rental_vehicles')
        .select()
        .eq('availability_status', 'available')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows
        .map((row) => RentalVehicle.fromMap(row, row['id'].toString()))
        .toList();
  }
}
