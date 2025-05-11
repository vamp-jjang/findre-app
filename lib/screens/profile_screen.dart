import 'package:flutter/material.dart';
import 'account_settings_screen.dart';
import 'find_agent_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Profile header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Avatar circle with initials
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2F3542),
                        ),
                        child: const Center(
                          child: Text(
                            'JV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // User name
                      const Text(
                        'Jayhann Villarin',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  // Settings icon
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccountSettingsScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Menu items
            // Find a local Agent (with red background)
            Container(
              color: Colors.red[50],
              child: ListTile(
                leading: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.red,
                ),
                title: const Text(
                  'Find a local Agent',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindAgentScreen(),
                ),
              ),
              ),
            ),
            const Divider(height: 1),
            // Notifications
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindAgentScreen(),
                ),
              ),
            ),
            const Divider(height: 1),
            // Share the App
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share the App'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindAgentScreen(),
                ),
              ),
            ),
            const Divider(height: 1),
            // Legal
            ListTile(
              leading: const Icon(Icons.gavel_outlined),
              title: const Text('Legal'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindAgentScreen(),
                ),
              ),
            ),
            const Divider(height: 1),
            // Language
            ListTile(
              leading: const Icon(Icons.language_outlined),
              title: const Text('Language'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FindAgentScreen(),
                ),
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}