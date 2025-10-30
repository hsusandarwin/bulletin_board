// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:bulletin_board/config/logger.dart';
import 'package:bulletin_board/provider/map/directions_model.dart';
import 'package:bulletin_board/repository/directions_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bulletin_board/data/entities/user/user.dart';

class MapScreenPage extends StatefulWidget {
  final List<User> selectedUsers;

  const MapScreenPage({super.key, required this.selectedUsers});

  @override
  State<MapScreenPage> createState() => _MapScreenPageState();
}

class _MapScreenPageState extends State<MapScreenPage> {
  LatLng _currentPosition = const LatLng(0, 0);
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  final Map<String, Directions> _userDirections = {};
  bool _showAllUsers = true;
  bool _showRoute = true;

  Timer? _directionsTimer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadUserMarkers();
  }

  @override
  void dispose() {
    _directionsTimer?.cancel();
    super.dispose();
  }

  void showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: Text('Show Route'),
                value: _showRoute,
                onChanged: (value) {
                  setState(() {
                    _showRoute = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              CheckboxListTile(
                title: Text('Show Users'),
                value: _showAllUsers,
                onChanged: (value) {
                  setState(() {
                    _showAllUsers = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        logger.e('Location services are disabled.');
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          logger.e('User denied permissions to access the device\'s location.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        logger.e(
          'Location permissions are permanently denied. Please enable them in app settings.',
        );
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = LatLng(position.latitude, position.longitude);
      logger.f('_currentPosition --> $_currentPosition');

      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPosition,
          infoWindow: const InfoWindow(title: 'You are here'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );

      if (_mapController != null) {
        _mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition));
        // _loadUserMarkers();
        // _directionLoad();
      }

      if (mounted) setState(() {});

      if (widget.selectedUsers.isNotEmpty) {
        for (var user in widget.selectedUsers) {
          final loc = user.address?.location;
          if (loc != null && loc.contains(',')) {
            final parts = loc.split(',');
            final lat = double.tryParse(parts[0].trim());
            final lng = double.tryParse(parts[1].trim());
            if (lat != null && lng != null) {
              await _fetchDirectionsToUser(user, LatLng(lat, lng));
            }
          }
        }
      }
    } catch (e) {
      logger.e('Error getting location: $e');
    }
  }

  Future<void> _fetchDirectionsToUser(User user, LatLng destination) async {
    // final String configString = await rootBundle.loadString(
    //   'api_keys.dev.json',
    // );
    // final Map<String, dynamic> config = json.decode(configString);
    // final orsKey = config['OPEN_ROUTE_API_KEY'];
    final apiKey = String.fromEnvironment('OPEN_ROUTE_API_KEY');
    final repo = DirectionsRepository(dio: Dio(), apiKey: apiKey);
    final directions = await repo.getDirections(
      origin: _currentPosition,
      destination: destination,
    );

    if (directions != null && mounted) {
      setState(() {
        _userDirections[user.email] = directions;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(directions.bounds, 50),
      );
    }
  }

  // void _directionLoad() {
  //   if (widget.selectedUsers.isEmpty) return;

  //   _directionsTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
  //     for (var user in widget.selectedUsers) {
  //       final loc = user.address?.location;
  //       if (loc != null && loc.contains(',')) {
  //         final parts = loc.split(',');
  //         final lat = double.tryParse(parts[0].trim());
  //         final lng = double.tryParse(parts[1].trim());
  //         if (lat != null && lng != null) {
  //           await _fetchDirectionsToUser(user, LatLng(lat, lng));
  //         }
  //       }
  //     }
  //   });
  // }

  void _loadUserMarkers() {
    for (var user in widget.selectedUsers) {
      final loc = user.address?.location;
      if (loc != null && loc.contains(',')) {
        final parts = loc.split(',');
        final lat = double.tryParse(parts[0].trim());
        final lng = double.tryParse(parts[1].trim());
        if (lat != null && lng != null) {
          setState(() {
            _markers = {
              ..._markers,
              Marker(
                markerId: MarkerId(user.email),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: user.name,
                  snippet: user.address?.name ?? '',
                ),
              ),
            };
          });
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Selected Users on Map',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showFilterDialog(context),
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 13,
        ),
        onMapCreated: (controller) => _mapController = controller,
        myLocationEnabled: true,
        markers: _showAllUsers ? _markers : {},
        polylines: _showRoute ? _userDirections.entries.map((entry) {
          return Polyline(
            polylineId: PolylineId(entry.key),
            color:
                Colors.primaries[_userDirections.keys.toList().indexOf(
                      entry.key,
                    ) %
                    Colors.primaries.length],
            width: 5,
            points: entry.value.polylinePoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList(),
          );
        }).toSet() : {},
      ),
    );
  }
}
