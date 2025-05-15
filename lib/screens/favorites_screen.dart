import 'package:flutter/material.dart';
import 'package:real_estate/screens/search_screen.dart';
import '../services/favorites_service.dart';
import '../models/property.dart';
import 'collection_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Property> _favoriteProperties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });
    
    final favorites = await FavoritesService.loadFavorites();
    
    setState(() {
      _favoriteProperties = favorites;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top navigation tabs
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Text(
                      'Saved',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      height: 2,
                      width: 32,
                      color: Colors.black,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Collections',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Saved Search',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Neighborhood',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Your Collections header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Collections',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${_favoriteProperties.isEmpty ? "0" : "1"} Collection',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content based on loading state and favorites
            _isLoading
            ? const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : _favoriteProperties.isEmpty
              ? Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Collections',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Here is where you\'ll see your collections. Start\nby searching properties, then favorite the ones\nyou like.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SearchScreen(),
                            ),
                          ),
                          child: const Text('Search Properties'),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Collection card
                        GestureDetector(
                          onTap: () {
                            // Navigate to collection details screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CollectionDetailsScreen(
                                  title: 'My Favorite Listings',
                                  properties: _favoriteProperties,
                                ),
                              ),
                            ).then((_) => _loadFavorites()); // Refresh favorites when returning
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Collection images
                                SizedBox(
                                  height: 180,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12),
                                            bottomLeft: Radius.circular(12),
                                          ),
                                          child: _favoriteProperties.isNotEmpty
                                              ? Image.network(
                                                  _favoriteProperties[0].imageUrl,
                                                  fit: BoxFit.cover,
                                                  height: double.infinity,
                                                  errorBuilder: (context, error, stackTrace) => Container(
                                                    color: Colors.grey[300],
                                                    child: const Icon(Icons.error),
                                                  ),
                                                )
                                              : Container(color: Colors.grey[300]),
                                        ),
                                      ),
                                      if (_favoriteProperties.length > 1)
                                        Expanded(
                                          flex: 1,
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topRight: Radius.circular(12),
                                              bottomRight: Radius.circular(12),
                                            ),
                                            child: Image.network(
                                              _favoriteProperties[1].imageUrl,
                                              fit: BoxFit.cover,
                                              height: double.infinity,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Collection details
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'My Favorite Listings',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Created by you',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(Icons.home, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${_favoriteProperties.length} homes',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const Spacer(),
                                          Text(
                                            'Updated ${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}