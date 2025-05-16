import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/property.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';
  static List<Property> _favorites = [];

  // Load favorites from SharedPreferences
  static Future<List<Property>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];
      
      _favorites = favoritesJson
          .map((json) => _propertyFromJson(jsonDecode(json)))
          .toList();
      
      return _favorites;
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  // Save favorites to SharedPreferences
  static Future<bool> saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites
          .map((property) => jsonEncode(_propertyToJson(property)))
          .toList();
      
      return await prefs.setStringList(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
      return false;
    }
  }

  // Add a property to favorites
  static Future<bool> addFavorite(Property property) async {
    // Check if property already exists in favorites
    if (!_favorites.any((p) => p.id == property.id)) {
      _favorites.add(property.copyWith(isFavorite: true));
      return await saveFavorites();
    }
    return true;
  }

  // Remove a property from favorites
  static Future<bool> removeFavorite(String propertyId) async {
    _favorites.removeWhere((p) => p.id == propertyId);
    return await saveFavorites();
  }

  // Toggle favorite status
  static Future<bool> toggleFavorite(Property property) async {
    // Update in local storage
    bool localResult;
    if (property.isFavorite) {
      localResult = await addFavorite(property);
    } else {
      localResult = await removeFavorite(property.id);
    }
    
    // Also update in Firestore if local update was successful
    if (localResult) {
      try {
        // Update in Firestore
        await FirebaseFirestore.instance
            .collection('properties')
            .doc(property.id)
            .update({'isFavorite': property.isFavorite});
      } catch (e) {
        print('Error updating favorite status in Firestore: $e');
        // Continue even if Firestore update fails
        // Local changes are still saved
      }
    }
    
    return localResult;
  }

  // Check if a property is in favorites
  static bool isFavorite(String propertyId) {
    return _favorites.any((p) => p.id == propertyId);
  }

  // Get all favorites
  static List<Property> getFavorites() {
    return List.from(_favorites);
  }

  // Helper method to convert Property to Map
  static Map<String, dynamic> _propertyToJson(Property property) {
    return {
      'id': property.id,
      'address': property.address,
      'city': property.city,
      'state': property.state,
      'zipCode': property.zipCode,
      'price': property.price,
      'squareFeet': property.squareFeet,
      'acres': property.acres,
      'imageUrl': property.imageUrl,
      'isFavorite': true,
      'listingCourtesy': property.listingCourtesy,
    };
  }

  // Helper method to convert Map to Property
  static Property _propertyFromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zipCode'],
      price: json['price'],
      squareFeet: json['squareFeet'],
      acres: json['acres'],
      imageUrl: json['imageUrl'],
      isFavorite: json['isFavorite'] ?? true,
      listingCourtesy: json['listingCourtesy'],
    );
  }
}