import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

/// Service for OpenStreetMap integration using Nominatim and OSRM
class OSMMapsService {
  static const String _nominatimUrl = 'https://nominatim.openstreetmap.org';
  static const String _osrmUrl = 'https://router.project-osrm.org';

  static final List<Map<String, dynamic>> _bengaluruLocations = [
    {
      'name': 'Babusapalya',
      'address': 'Babusapalya, Horamavu, Bengaluru, Karnataka, 560043',
      'lat': 13.0235,
      'lng': 77.6582,
      'type': 'result',
    },
    {
      'name': 'Horamavu',
      'address': 'Horamavu, Bengaluru, Karnataka, 560043',
      'lat': 13.0273,
      'lng': 77.6602,
      'type': 'result',
    },
    {
      'name': 'Kalyan Nagar',
      'address': 'Kalyan Nagar, Bengaluru, Karnataka, 560043',
      'lat': 13.0221,
      'lng': 77.6403,
      'type': 'result',
    },
    {
      'name': 'Hebbal',
      'address': 'Hebbal, Bengaluru, Karnataka, 560024',
      'lat': 13.0354,
      'lng': 77.5988,
      'type': 'result',
    },
    {
      'name': 'HSR Layout',
      'address': 'HSR Layout, Bengaluru, Karnataka, 560102',
      'lat': 12.9128,
      'lng': 77.6388,
      'type': 'result',
    },
    {
      'name': 'Indiranagar',
      'address': 'Indiranagar, Bengaluru, Karnataka, 560038',
      'lat': 12.9719,
      'lng': 77.6412,
      'type': 'result',
    },
    {
      'name': 'Koramangala',
      'address': 'Koramangala, Bengaluru, Karnataka, 560095',
      'lat': 12.9352,
      'lng': 77.6245,
      'type': 'result',
    },
    {
      'name': 'MG Road Metro Station',
      'address': 'Mahatma Gandhi Road, Bengaluru, Karnataka, 560001',
      'lat': 12.9756,
      'lng': 77.6068,
      'type': 'result',
    },
    {
      'name': 'Whitefield',
      'address': 'Whitefield, Bengaluru, Karnataka, 560066',
      'lat': 12.9698,
      'lng': 77.7499,
      'type': 'result',
    },
  ];

  /// Search for addresses using Nominatim
  Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    if (query.length < 3) return [];

    final localResults = _bengaluruLocations.where((loc) {
      final q = query.toLowerCase();
      final name = loc['name'].toString().toLowerCase();
      final address = loc['address'].toString().toLowerCase();
      return name.contains(q) || address.contains(q);
    }).toList();

    try {
      final headers = kIsWeb
          ? null
          : <String, String>{
              'User-Agent': 'RoadRobosMobileApp/1.0.0 (contact@roadrobos.com)'
            };
      final response = await http.get(
        Uri.parse(
            '$_nominatimUrl/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5&countrycodes=in'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final apiResults = data.map((item) {
          return {
            'name': item['display_name'].toString().split(',')[0],
            'address': item['display_name'],
            'lat': double.parse(item['lat']),
            'lng': double.parse(item['lon']),
            'type': 'result',
          };
        }).toList();

        // Combine, removing duplicates by name
        final combined = [...localResults];
        for (var apiLoc in apiResults) {
          if (!combined.any((l) =>
              l['name'].toString().toLowerCase() ==
              apiLoc['name'].toString().toLowerCase())) {
            combined.add(apiLoc);
          }
        }
        return combined;
      }
    } catch (e) {
      debugPrint('Nominatim Search Error: $e');
    }
    return localResults;
  }

  /// Get routing polyline between two points using OSRM
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    try {
      final response = await http.get(
        Uri.parse(
            '$_osrmUrl/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final List coordinates = data['routes'][0]['geometry']['coordinates'];
          return coordinates
              .map((coord) => LatLng(coord[1], coord[0]))
              .toList();
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
      final headers = kIsWeb
          ? null
          : <String, String>{
              'User-Agent': 'RoadRobosApp/1.0 (contact@roadrobos.com)'
            };
      final response = await http.get(
        Uri.parse(
            '$_nominatimUrl/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json&zoom=18&addressdetails=1'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['display_name'] != null) {
          final address = data['display_name'].toString();
          final parts = address.split(', ');
          if (parts.length > 3) {
            return '${parts[0]}, ${parts[1]}, ${parts[2]}';
          }
          return address;
        }
      }
    } catch (e) {
      debugPrint('Nominatim Reverse Geocode Error: $e');
    }
    return null;
  }

  /// Calculate total distance of a route polyline in kilometers
  double calculateDistanceInKm(List<LatLng> points) {
    if (points.isEmpty || points.length == 1) return 0.0;

    double totalDistance = 0.0;
    const distance = Distance();

    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += distance.as(LengthUnit.Meter, points[i], points[i + 1]);
    }

    return totalDistance / 1000.0;
  }
}
