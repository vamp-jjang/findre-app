import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:real_estate/screens/home_screen.dart';
import 'package:real_estate/screens/welcome_screen.dart';


class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {

        return const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
            strokeWidth: 2,
          ),

        );
            
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          } else if (snapshot.hasData) {
            return HomeScreen();
          } else {
            return WelcomeScreen();
          }
        }
        ),
      );
  }
}