import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late GoogleMapController _mapController;
  bool _isListView = false;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(10.3157, 123.8854), // Default to Carmen, Cebu coordinates
    zoom: 12,
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