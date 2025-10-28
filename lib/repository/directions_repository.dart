import 'package:bulletin_board/provider/map/directions_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../config/logger.dart';

class DirectionsRepository {
  final Dio _dio;
  final String apiKey;

  DirectionsRepository({required Dio dio, required this.apiKey}) : _dio = dio;

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final url =
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjI4MmRiMmIzOTExYTQyMzI4OGRiNzM4YzBlYTU5MTk5IiwiaCI6Im11cm11cjY0In0=&start=${origin.longitude},${origin.latitude}&end=${destination.longitude},${destination.latitude}';
    
    final response = await _dio.get(
      url,
      options: Options(
        headers: {'Authorization': apiKey},
      ),
    );

      if (kDebugMode) {
        logger.w('ORS response: ${response.data}');
      }

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['features'] != null &&
          (response.data['features'] as List).isNotEmpty) {
        final feature = (response.data['features'] as List).first as Map<String, dynamic>;

        final geometry = feature['geometry'] as Map<String, dynamic>?;
        final coords = geometry != null ? geometry['coordinates'] as List<dynamic>? : null;

        final List<PointLatLng> polylinePoints = [];
        LatLngBounds bounds;

        if (coords != null && coords.isNotEmpty) {
          double minLat = (coords[0][1] as num).toDouble();
          double maxLat = minLat;
          double minLng = (coords[0][0] as num).toDouble();
          double maxLng = minLng;

          for (final c in coords) {
            final double lon = (c[0] as num).toDouble();
            final double lat = (c[1] as num).toDouble();

            if (lat < minLat) minLat = lat;
            if (lat > maxLat) maxLat = lat;
            if (lon < minLng) minLng = lon;
            if (lon > maxLng) maxLng = lon;

            polylinePoints.add(PointLatLng(lat, lon));
          }

          bounds = LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          );
        } else {
          bounds = LatLngBounds(southwest: origin, northeast: destination);
        }

        String distanceText = '';
        String durationText = '';
        final properties = feature['properties'] as Map<String, dynamic>?;
        if (properties != null && properties['summary'] != null) {
          final summary = properties['summary'] as Map<String, dynamic>;
          final distanceMeters = summary['distance'] as num?;
          final durationSeconds = summary['duration'] as num?;
          if (distanceMeters != null) {
            final km = (distanceMeters / 1000);
            distanceText = '${km.toStringAsFixed(km >= 1 ? 2 : 3)} km';
          }
          if (durationSeconds != null) {
            final min = (durationSeconds / 60);
            durationText = '${min.toStringAsFixed(0)} min';
          }
        }
        return Directions(
          bounds: bounds,
          polylinePoints: polylinePoints,
          totalDistance: distanceText,
          totalDuration: durationText,
        );
      }

      return null;
    }
  }
