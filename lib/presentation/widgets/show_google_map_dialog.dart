import 'package:bulletin_board/presentation/widgets/commom_dialog.dart';
import 'package:bulletin_board/provider/user/user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoogleMapPickerDialog extends ConsumerStatefulWidget {
  const GoogleMapPickerDialog({super.key, required this.userNotifier});

  final UserNotifier userNotifier;

  @override
  GoogleMapPickerDialogState createState() => GoogleMapPickerDialogState();
}

class GoogleMapPickerDialogState extends ConsumerState<GoogleMapPickerDialog> {
  late GoogleMapController mapController;
  LatLng _currentPosition = const LatLng(0, 0);
  LatLng _pickedLocation = const LatLng(0, 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool permissionGranted = await _requestLocationPermission();
    if (permissionGranted) {
      try {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _pickedLocation = _currentPosition;
          _isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Could not get current location: $e")),
          );
          Navigator.of(context).pop();
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  void _onMapTapped(LatLng latLng) {
    setState(() {
      _pickedLocation = latLng;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              ) // Loading indicator
            : GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 15,
                ),
                onTap: _onMapTapped,
                markers: {
                  Marker(
                    markerId: const MarkerId('pickedLocation'),
                    position: _pickedLocation,
                    infoWindow: InfoWindow(
                      title: 'Selected Location',
                      snippet:
                          'Lat: ${_pickedLocation.latitude}, Lng: ${_pickedLocation.longitude}',
                    ),
                  ),
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null), // Cancel button
          child: Text(
            "Cancel",
          ),
        ),
        TextButton(
          onPressed: () async {
            if (_pickedLocation == const LatLng(0, 0)) return;
            try {
              final address = await widget.userNotifier.getAddressFromLatLng(
                _pickedLocation,
              );

              if (context.mounted) {
                Navigator.of(context).pop();
                showSnackBar(
                  context,
                  'Address updated successfully!',
                  Colors.green,
                );
              }

              await widget.userNotifier.updateAddress(
                name: address.toString(),
                pickedLocation: _pickedLocation,
              );

            } on Exception catch (e) {
              if (!context.mounted) return;
              showSnackBar(
                context,
                'Error updating address: ${e.toString()}',
                Colors.red,
              );
            }
          },
          // Confirm button
          child: Text(
            "Confirm",
          ),
        ),
      ],
    );
  }
}
