import 'package:flutter/material.dart';
import 'package:real_estate/auth_services.dart';
import 'welcome_screen.dart';
import 'update_name_screen.dart';


class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _auth = AuthService();
  String _userName = 'User';
  String _userEmail = '';
  
  @override
  void initState() {
    super.initState();
    // Initialize with current name and email if available
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      setState(() {
        if (currentUser.displayName != null) {
          _userName = currentUser.displayName!;
        }
        
        // Get email if available, otherwise leave empty
        if (currentUser.email != null && !currentUser.isAnonymous) {
          _userEmail = currentUser.email!;
        }
      });
    }
  }
  
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
          'Account Settings',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: ListView(
        children: [
          // Personal Info Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'PERSONAL INFO',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ListTile(
            title: const Text('Name'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpdateNameScreen()),
              );
              
              if (result != null && result is String) {
                setState(() {
                  _userName = result;
                });
              }
            },
          ),
          ListTile(
            title: const Text('Email'),
            trailing: Text(
              _userEmail,
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          // Security Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'SECURITY',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ListTile(
            title: const Text('Password'),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: () {},
          ),

          // Account Section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'ACCOUNT',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ListTile(
            title: const Text('Log Out'),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: () async{
              await _auth.signOut();
                            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                (route) => false,
              ); 
            },
          ),
          ListTile(
            title: Text(
              'Delete Account',
              style: TextStyle(color: Colors.red[400]),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}