import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late GoogleMapController _mapController;
  bool _isListView = false;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final _markerId = const MarkerId('current_location');
  final _polylineId = const PolylineId('route');

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.status;
    if (status.isGranted) {
      _getCurrentLocation();
    } else if (status.isDenied) {
      // Show explanation dialog before requesting permission
      final shouldRequest = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text(
            'We need your location permission to show nearby properties and provide accurate distance calculations. '
            'This helps you find the perfect property in your desired area.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Deny'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Allow'),
            ),
          ],
        ),
      ) ?? false;

      if (shouldRequest) {
        final permissionStatus = await Permission.location.request();
        if (permissionStatus.isGranted) {
          _getCurrentLocation();
        } else {
          _showPermissionDeniedDialog();
        }
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _updateMarker();
      });
      _startLocationUpdates();
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to get current location. Please check your location settings.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is required to show nearby properties. '
          'Please enable location access in your device settings to use this feature.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = position;
        _updateMarker();
      });
    });
  }

  void _updateMarker() {
    if (_currentPosition != null) {
      final marker = Marker(
        markerId: _markerId,
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
      );
      setState(() {
        _markers = {marker};
      });
    }
  }

  void _drawPolyline(LatLng destination) {
    if (_currentPosition != null) {
      final polyline = Polyline(
        polylineId: _polylineId,
        color: Colors.blue,
        width: 5,
        points: [
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          destination,
        ],
      );
      setState(() {
        _polylines = {polyline};
      });
    }
  }

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(9.814062304659195, 124.1764920905616), // Default to Carmen, Bohol coordinates
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map View
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            mapToolbarEnabled: true,
            zoomControlsEnabled: false,
            markers: _markers,
            polylines: _polylines,
            onTap: (LatLng position) {
              final propertyMarker = Marker(
                markerId: MarkerId('property_${position.latitude}_${position.longitude}'),
                position: position,
                infoWindow: const InfoWindow(title: 'Selected Property'),
                onTap: () => _drawPolyline(position),
              );
              setState(() {
                _markers = {propertyMarker, ..._markers};
                _drawPolyline(position);
              });
            },
          ),

          // Search Bar and Filters
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'City, Neighborhood, Address, School',
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                        ),
                        Container(
                          height: 48,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.tune),
                            onPressed: () {
                              // Show filters dialog
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Save Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          // List View Toggle Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Center(
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isListView = !_isListView;
                  });
                },
                backgroundColor: Colors.white,
                child: Icon(
                  _isListView ? Icons.map : Icons.list,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}