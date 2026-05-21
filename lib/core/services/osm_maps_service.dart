import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

/// Service for OpenStreetMap integration using Nominatim and OSRM
class OSMMapsService {
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';
  static const String _osrmUrl = 'https://router.project-osrm.org';

  /// Search for addresses using Nominatim
  Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    if (query.length < 3) return [];

    try {
      final response = await http.get(
        Uri.parse('$_nominatimUrl/search?q=$query&format=json&addressdetails=1&limit=5'),
        headers: {'User-Agent': 'RoadRobos_App_v1.0'},
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) {
          return {
            'name': item['display_name'].toString().split(',')[0],
            'address': item['display_name'],
            'lat': double.parse(item['lat']),
            'lng': double.parse(item['lon']),
            'type': 'result',
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Nominatim Search Error: $e');
    }
    return [];
  }

  /// Get routing polyline between two points using OSRM
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final response = await http.get(
        Uri.parse('$_osrmUrl/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List coordinates = data['routes'][0]['geometry']['coordinates'];
          return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
        }
      }
    } catch (e) {
      debugPrint('OSRM Routing Error: $e');
    }
    // Fallback to straight line if routing fails
    return [start, end];
  }

  /// Reverse geocoding: Get address from coordinates
  Future<String?> getAddressFromCoords(LatLng point) async {
    try {
      final response = await http.get(
        Uri.parse('$_nominatimUrl/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json'),
        headers: {'User-Agent': 'RoadRobos_App_v1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'];
      }
    } catch (e) {
      debugPrint('Nominatim Reverse Geocode Error: $e');
    }
    return null;
  }
}
