import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/property.dart';

class FirestoreService {
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection reference
  CollectionReference get _propertiesCollection => _firestore.collection('properties');
  
  // Get all properties
  Future<List<Property>> getProperties() async {
    try {
      final QuerySnapshot snapshot = await _propertiesCollection.get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // If the document doesn't have an id field, use the document ID
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return Property.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error getting properties: $e');
      return [];
    }
  }
  
  // Get a single property by ID
  Future<Property?> getProperty(String id) async {
    try {
      final DocumentSnapshot doc = await _propertiesCollection.doc(id).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // If the document doesn't have an id field, use the document ID
        if (!data.containsKey('id')) {
          data['id'] = doc.id;
        }
        return Property.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error getting property: $e');
      return null;
    }
  }
  
  // Add a new property
  Future<String?> addProperty(Property property) async {
    try {
      // Create a new document with auto-generated ID
      final docRef = await _propertiesCollection.add(property.toMap());
      return docRef.id;
    } catch (e) {
      print('Error adding property: $e');
      return null;
    }
  }
  
  // Update an existing property
  Future<bool> updateProperty(Property property) async {
    try {
      await _propertiesCollection.doc(property.id).update(property.toMap());
      return true;
    } catch (e) {
      print('Error updating property: $e');
      return false;
    }
  }
  
  // Delete a property
  Future<bool> deleteProperty(String id) async {
    try {
      await _propertiesCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting property: $e');
      return false;
    }
  }
  
  // Update favorite status
  Future<bool> updateFavoriteStatus(String id, bool isFavorite) async {
    try {
      await _propertiesCollection.doc(id).update({'isFavorite': isFavorite});
      return true;
    } catch (e) {
      print('Error updating favorite status: $e');
      return false;
    }
  }
  
  // Update property coordinates
  Future<bool> updatePropertyCoordinates(String id, double latitude, double longitude) async {
    try {
      await _propertiesCollection.doc(id).update({
        'latitude': latitude,
        'longitude': longitude,
      });
      return true;
    } catch (e) {
      print('Error updating property coordinates: $e');
      return false;
    }
  }
  
  // Add mock properties to Firestore (for initial setup)
  Future<void> addMockPropertiesToFirestore(List<Property> properties) async {
    try {
      // Check if collection is empty first
      final QuerySnapshot snapshot = await _propertiesCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        // Collection is empty, add mock data
        for (var property in properties) {
          await _propertiesCollection.doc(property.id).set(property.toMap());
        }
        print('Mock properties added to Firestore');
      } else {
        print('Properties collection already has data, skipping mock data import');
      }
    } catch (e) {
      print('Error adding mock properties to Firestore: $e');
    }
  }
}