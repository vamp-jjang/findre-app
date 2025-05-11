import 'package:flutter/material.dart';

class FindAgentScreen extends StatelessWidget {
  const FindAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find a local KW® agent',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Find a local KW® agent by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          // Agent list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                // Agent Card 1
                Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Luxury badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: const Text(
                                'LUXURY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        // Agent info
                        Row(
                          children: [
                            // Profile picture
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: const AssetImage(
                                'assets/icons/avatar.jpg') // Placeholder image                    
                            ),
                            const SizedBox(width: 16.0),
                            // Agent details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Jayhann Villarin',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4.0),
                                  const Text('Bohol, Philippines'),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 16.0),
                                      const SizedBox(width: 4.0),
                                      const Text('Carmen'),
                                      const SizedBox(width: 16.0),
                                      const Icon(Icons.language, size: 16.0),
                                      const SizedBox(width: 4.0),
                                      const Text('English'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        // Connect button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text('Connect with Me',
                            style: TextStyle(color: const Color.fromARGB(255, 252, 252, 252)),
                                
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // License info
                        Center(
                          child: Text(
                            'License #: 370131',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 106, 105, 105),
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // Additional agent cards can be added here
              ],
            ),
          ),
        ],
      ),
    );
  }
}