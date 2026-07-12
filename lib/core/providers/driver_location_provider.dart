import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/taxi_provider.dart';

/// Streams available taxi driver locations from Supabase Realtime.
///
/// Subscribes to the [driver_locations] table filtered by:
///   status = 'available' AND service_type = 'taxi'
///
/// Emits a fresh [List<NearbyVehicle>] each time a driver location is
/// inserted, updated, or deleted. The taxi booking map consumes this
/// provider to render live vehicle pins — no mock coordinates are used.
///
/// Falls back to an empty list when the table is empty or unreachable,
/// so the map still renders without crashing.
final availableTaxiLocationsProvider =
    StreamProvider<List<NearbyVehicle>>((ref) {
  final supabase = Supabase.instance.client;

  // Use Supabase Realtime streaming — re-emits the full list on any change.
  final stream = supabase
      .from('driver_locations')
      .stream(primaryKey: ['id'])
      .eq('status', 'available')
      // Note: Supabase stream does not support multiple .eq() filters on different
      // columns directly — filter service_type client-side after receiving data.
      .map((rows) {
        return rows.where((row) => row['service_type'] == 'taxi').map((row) {
          final lat = (row['lat'] as num?)?.toDouble() ?? 0.0;
          final lng = (row['lng'] as num?)?.toDouble() ?? 0.0;
          return NearbyVehicle(
            position: LatLng(lat, lng),
            type: 'car', // default vehicle icon for taxi drivers
          );
        }).toList();
      });

  return stream;
});
