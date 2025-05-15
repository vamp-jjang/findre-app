import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_directions_api/google_directions_api.dart' as directions_api;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_webservice/places.dart' as P; // Remove this line
import 'package:http/http.dart' as http; // Add http package
import 'dart:convert'; // Add dart:convert for jsonDecode
import 'dart:async'; // Add for StreamSubscription
import 'dart:ui' as ui; // Add for PictureRecorder and Image
import './place_search_screen.dart'; // Import the new screen
import '../models/property.dart'; // Import the property model
import '../services/favorites_service.dart'; // Import favorites service
import '../services/firestore_service.dart'; // Import Firestore service
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
  
  // List of property locations with their prices
  final List<Map<String, dynamic>> _propertyLocations = [
    {'position': LatLng(9.641313657391187, 123.88062357861067), 'price': 199900},
    {'position': LatLng(9.646976145946546, 123.8694971664606), 'price': 169000},
    {'position': LatLng(9.674034604353054, 123.87699593290279), 'price': 225000},
    {'position': LatLng(9.654966026959377, 123.84926638541329), 'price': 189500},
    {'position': LatLng(9.604226593474564, 123.82824421102796), 'price': 210000},
  ];
  
  // Firestore service instance
  final FirestoreService _firestoreService = FirestoreService();
  
  // Properties list
  List<Property> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _loadProperties();
    // Add custom property markers after a short delay to ensure map is loaded
    Future.delayed(const Duration(milliseconds: 500), () {
      _addCustomPropertyMarkers();
    });
    
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
  
  // Load properties from Firestore
  Future<void> _loadProperties() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get properties from Firestore
      final properties = await _firestoreService.getProperties();
      
      // If no properties in Firestore, add mock data
      if (properties.isEmpty) {
        await _firestoreService.addMockPropertiesToFirestore(getMockProperties());
        // Fetch again after adding mock data
        final updatedProperties = await _firestoreService.getProperties();
        if (!mounted) return;
        setState(() {
          _properties = updatedProperties;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _properties = properties;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading properties: $e');
      // Fallback to mock data if Firestore fails
      if (!mounted) return;
      setState(() {
        _properties = getMockProperties();
        _isLoading = false;
      });
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
      
      // Move camera to current location if map controller is already initialized
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15,
            ),
          ),
        );
      }
      
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

  // Location stream subscription
  StreamSubscription<Position>? _positionStreamSubscription;

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream().listen((Position position) {
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _updateMarker();
      });
    });
  }
  
  @override
  void dispose() {
    // Cancel location updates subscription
    _positionStreamSubscription?.cancel();
    // Dispose map controller
    _mapController?.dispose();
    super.dispose();
  }

  void _updateMarker() {
    if (_currentPosition != null && mounted) {
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
    target: LatLng(9.641313657391187, 123.88062357861067), // Updated to center on first property location
    zoom: 12,
  );
  
  // Method to add custom bubble markers for properties
  void _addCustomPropertyMarkers() {
    for (int i = 0; i < _propertyLocations.length; i++) {
      final location = _propertyLocations[i];
      final price = location['price'];
      final formattedPrice = '₱${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}K';
      
      // Add marker with InfoWindow to display price and onTap callback for drawing polyline
      final marker = Marker(
        markerId: MarkerId('property_$i'),
        position: location['position'],
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(
          title: formattedPrice,
          snippet: 'Property details',
        ),
        onTap: () {
          // Draw polyline from current location to this property
          _drawPolyline(location['position']);
        },
      );
      
      setState(() {
        _markers.add(marker);
      });
    }
  }
  
  // Show all InfoWindows when map is ready
  void _showAllInfoWindows() {
    if (_mapController != null) {
      // Trigger showing all InfoWindows by tapping each marker programmatically
      for (int i = 0; i < _propertyLocations.length; i++) {
        _mapController!.showMarkerInfoWindow(MarkerId('property_$i'));
      }
    }
  }
  
  // Create custom marker bitmap with price bubble
  Future<BitmapDescriptor> _createCustomMarkerBitmap(String price) async {
    // For Windows platform, we'll use a simpler approach with BitmapDescriptor.defaultMarker
    // This ensures compatibility across platforms
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);
  }

  // Property card widget for list view
  Widget _buildPropertyCard(Property property) {
    final formattedPrice = '₱${property.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},")}'; 
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property image with favorite button
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  property.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.error, size: 50)),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: IconButton(
                    icon: Icon(
                      property.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: property.isFavorite ? Colors.red : Colors.black,
                      size: 20,
                    ),
                    onPressed: () async {
                      // Toggle favorite status
                      final updatedProperty = property.copyWith(isFavorite: !property.isFavorite);
                      
                      // Update in Firestore
                      await _firestoreService.updateFavoriteStatus(property.id, updatedProperty.isFavorite);
                      
                      // Also save to local favorites service for offline access
                      await FavoritesService.toggleFavorite(updatedProperty);
                      
                      // Update the UI
                      setState(() {
                        // Find and update the property in the list
                        final index = _properties.indexWhere((p) => p.id == property.id);
                        if (index != -1) {
                          _properties[index] = updatedProperty;
                        }
                      });
                      
                      // Show a snackbar to confirm the action
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            updatedProperty.isFavorite 
                              ? 'Added to favorites' 
                              : 'Removed from favorites',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Image pagination dots
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 0 ? Colors.white : Colors.white.withOpacity(0.5),
                    ),
                  )),
                ),
              ),
            ],
          ),
          // Property details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedPrice,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${property.squareFeet.toStringAsFixed(0)} sq ft',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${property.acres} ac',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${property.address}, ${property.city}, ${property.state} ${property.zipCode}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Listing Courtesy Of: ${property.listingCourtesy}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use properties loaded from Firestore
    
    return Scaffold(
      body: Stack(
        children: [
          // Conditional rendering based on view mode
          _isListView 
          ? SafeArea(
              child: Column(
                children: [
                  // Search bar for list view
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
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
                              readOnly: true,
                              onTap: _navigateToPlaceSearch,
                              decoration: const InputDecoration(
                                hintText: 'City, Neighborhood, Address, School',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                prefixIcon: Icon(Icons.search),
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
                  ),
                  // Results count and sort options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All Results',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        Text(
                          '${_properties.length} Results',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Property listings
                  Expanded(
                    child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80), // Add padding for FAB
                          itemCount: _properties.length,
                          itemBuilder: (context, index) => _buildPropertyCard(_properties[index]),
                        ),
                  ),
                ],
              ),
            )
          : GoogleMap(
              initialCameraPosition: _currentPosition != null
                ? CameraPosition(
                    target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    zoom: 15,
                  )
                : _initialPosition,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller; // Assign the controller
                // Move camera to current location if available after map is created
                if (_currentPosition != null) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        zoom: 15,
                      ),
                    ),
                  );
                }
                
                // Show all property price bubbles after a short delay
                Future.delayed(const Duration(milliseconds: 1000), () {
                  _showAllInfoWindows();
                });
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

          // Search Bar and Filters (only show in map view)
          if (!_isListView)
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
          // List View Toggle Button - Always visible
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