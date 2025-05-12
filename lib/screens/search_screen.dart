import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_directions_api/google_directions_api.dart' as directions_api;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_webservice/places.dart' as P; // Remove this line
import 'package:http/http.dart' as http; // Add http package
import 'dart:convert'; // Add dart:convert for jsonDecode
import './place_search_screen.dart'; // Import the new screen
// For decoding polyline


const String GOOGLE_MAPS_API_KEY = "AIzaSyDZuK3iJMP6qCiPf-MzsGVK7e5XEDPWW58";

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  GoogleMapController? _mapController;
  // P.GoogleMapsPlaces? _placesApi; // Remove this line
  bool _isListView = false;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  final _markerId = const MarkerId('current_location');
  final _polylineId = const PolylineId('route');
  directions_api.DirectionsService? _directionsService;
  PolylinePoints _polylinePoints = PolylinePoints();

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    if (GOOGLE_MAPS_API_KEY == "YOUR_GOOGLE_MAPS_API_KEY") {
      // Show a dialog or toast to remind the user to add their API key
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) { // Check if the widget is still in the tree
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('API Key Required'),
              content: const Text('Please replace "YOUR_GOOGLE_MAPS_API_KEY" in search_screen.dart with your actual Google Maps API key to enable route and place search functionality.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      });
    } else {
      directions_api.DirectionsService.init(GOOGLE_MAPS_API_KEY);
      _directionsService = directions_api.DirectionsService();
      // _placesApi = P.GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY); // Remove this line
    }
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
        // Preserve existing property markers
        _markers = _markers.where((m) => m.markerId != _markerId).toSet();
        _markers.add(marker);
      });
    }
  }

  Future<void> _drawPolyline(LatLng destination) async {
    if (_currentPosition == null || _directionsService == null) {
      print('Current position or directions service not available.');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not draw route. Ensure location is enabled and API key is set.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final request = directions_api.DirectionsRequest(
      origin: '${_currentPosition!.latitude},${_currentPosition!.longitude}',
      destination: '${destination.latitude},${destination.longitude}',
      travelMode: directions_api.TravelMode.driving,
    );

    try {
      await _directionsService!.route(request, (result, status) {
        if (!mounted) return; 
        if (status == directions_api.DirectionsStatus.ok && result.routes != null && result.routes!.isNotEmpty) {
          final route = result.routes!.first;
          if (route.overviewPolyline != null && route.overviewPolyline!.points != null) {
            List<PointLatLng> decodedPoints = _polylinePoints.decodePolyline(route.overviewPolyline!.points!);
            List<LatLng> polylineCoordinates = decodedPoints.map((point) => LatLng(point.latitude, point.longitude)).toList();

            if (polylineCoordinates.isNotEmpty) {
              final polyline = Polyline(
                polylineId: _polylineId,
                color: const Color.fromARGB(255, 236, 8, 8),
                width: 5,
                points: polylineCoordinates,
              );
              if (!mounted) return;
              setState(() {
                _polylines = {polyline};
              });
            } else {
              print('No coordinates found for polyline');
               if (!mounted) return;
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not decode route points.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }
          } else {
            print('Overview polyline or points are null');
             if (!mounted) return;
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not retrieve route details.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else {
          print('Directions request failed with status: $status');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error fetching directions: ${status.toString().split(".").last}'),
              duration: Duration(seconds: 3),
            ),
          );
          setState(() {
            _polylines.clear(); // Clear previous polylines on error
          });
        }
      });
    } catch (e) {
      print('Error calling directions API: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while fetching directions.'),
          duration: Duration(seconds: 3),
        ),
      );
       if (!mounted) return;
       setState(() {
        _polylines.clear(); // Clear previous polylines on error
      });
    }
  }

  Future<void> _navigateToPlaceSearch() async {
    // if (_placesApi == null) { // Remove this check
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Places API not initialized. Check API Key.')),
    //   );
    //   return;
    // }
    if (GOOGLE_MAPS_API_KEY == "YOUR_GOOGLE_MAPS_API_KEY" || GOOGLE_MAPS_API_KEY.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key not configured. Cannot search for places.')),
      );
      return;
    }
    // Navigate to the PlaceSearchScreen and wait for a result.
    final placeId = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => PlaceSearchScreen(apiKey: GOOGLE_MAPS_API_KEY), // Pass the API key
      ),
    );

    if (placeId != null && placeId.isNotEmpty) {
      _goToPlace(placeId);
    }
  }

  Future<void> _goToPlace(String placeId) async {
    // if (_placesApi == null) return; // Remove this check
    if (GOOGLE_MAPS_API_KEY == "YOUR_GOOGLE_MAPS_API_KEY" || GOOGLE_MAPS_API_KEY.isEmpty) {
      print("API Key is not set for fetching place details.");
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('API Key not configured. Cannot fetch place details.')),
        );
      }
      return;
    }

    final String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$GOOGLE_MAPS_API_KEY';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];
          final location = result['geometry']['location'];
          final LatLng newLatLng = LatLng(location['lat'], location['lng']);

          _mapController?.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: newLatLng, zoom: 15.0),
          ));

          final selectedPlaceMarker = Marker(
            markerId: MarkerId('selected_place_$placeId'),
            position: newLatLng,
            infoWindow: InfoWindow(title: result['name'], snippet: result['formatted_address']),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          );

          if (!mounted) return;
          setState(() {
            // Clear previous property markers but keep current location marker
            _markers = _markers.where((m) => m.markerId == _markerId).toSet();
            _markers.add(selectedPlaceMarker);
            _polylines.clear(); // Clear any existing polylines like routes
          });

        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching place details: ${data['error_message'] ?? data['status']}')),
          );
        }
      } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching place details: ${response.reasonPhrase}')),
          );
      }
    } catch (e) {
      print('Error getting place details: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while fetching place details.')),
      );
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
              _mapController = controller; // Assign the controller
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
                onTap: () => _drawPolyline(position), // Call _drawPolyline here as well if needed when tapping existing marker
              );
              setState(() {
                // Add new property marker, keep existing current location marker
                Set<Marker> newMarkers = _markers.where((m) => m.markerId == _markerId).toSet();
                newMarkers.add(propertyMarker);
                _markers = newMarkers;
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
                            readOnly: true, // Make TextField read-only
                            onTap: _navigateToPlaceSearch, // Navigate on tap
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