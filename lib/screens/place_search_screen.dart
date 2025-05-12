import 'package:flutter/material.dart';
// import 'package:google_maps_webservice/places.dart'; // Remove this line
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class PlaceSearchScreen extends StatefulWidget {
  final String apiKey; // Add apiKey parameter
  const PlaceSearchScreen({super.key, required this.apiKey}); // Update constructor

  @override
  _PlaceSearchScreenState createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // GoogleMapsPlaces? _places; // Remove this line
  List<Map<String, dynamic>> _predictions = []; // Changed to List<Map<String, dynamic>>
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Remove the check for GOOGLE_MAPS_API_KEY_PLACES and directly use widget.apiKey
    if (widget.apiKey == "YOUR_GOOGLE_MAPS_API_KEY" || widget.apiKey.isEmpty) { // Check if the passed API key is a placeholder or empty
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('API Key Required'),
              content: const Text('A valid Google Maps API key is required for place search functionality. Please ensure it is correctly configured in search_screen.dart.'),
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
    } 
    // No need to initialize _places here anymore

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (_searchController.text.isNotEmpty) { // No need to check _places != null
          _fetchSuggestions(_searchController.text);
        } else {
          if (mounted) {
            setState(() {
              _predictions = [];
            });
          }
        }
      });
    });
  }

  Future<void> _fetchSuggestions(String input) async {
    // if (_places == null) return; // Remove this check
    if (widget.apiKey == "YOUR_GOOGLE_MAPS_API_KEY" || widget.apiKey.isEmpty) {
      print("API Key is not set for PlaceSearchScreen");
      return;
    }

    final String url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${widget.apiKey}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && mounted) {
          setState(() {
            _predictions = List<Map<String, dynamic>>.from(data['predictions']);
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error fetching places: ${data['error_message'] ?? data['status']}')),
            );
            setState(() {
              _predictions = [];
            });
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching places: ${response.reasonPhrase}')),
          );
          setState(() {
            _predictions = [];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
        setState(() {
          _predictions = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search for a place...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey[600]),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              if (mounted) {
                setState(() {
                  _predictions = [];
                });
              }
            },
          ),
        ],
      ),
      body: _predictions.isEmpty && _searchController.text.isEmpty
          ? const Center(child: Text('Start typing to search for places'))
          : _predictions.isEmpty && _searchController.text.isNotEmpty
              ? const Center(child: Text('No places found. Try a different search.'))
              : ListView.builder(
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = _predictions[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined),
                      title: Text(prediction['description'] ?? 'Unknown place'),
                      subtitle: Text((prediction['types'] as List<dynamic>?)?.join(', ') ?? ''),
                      onTap: () {
                        // When a place is selected, pop and return its placeId
                        if (prediction['place_id'] != null) {
                          Navigator.pop(context, prediction['place_id'] as String);
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not select this place.')),
                          );
                        }
                      },
                    );
                  },
                ),
    );
  }
}