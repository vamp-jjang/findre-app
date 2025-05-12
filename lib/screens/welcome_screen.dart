import 'package:flutter/material.dart';
import 'package:real_estate/screens/home_screen.dart';
import 'package:real_estate/screens/signup_screen.dart';
import 'login_screen.dart';
import '../auth_services.dart';

class WelcomeScreen extends StatelessWidget {
          WelcomeScreen({super.key});
final AuthService firebaseAuth = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Logo
              Image.asset(
                'assets/icons/findre_tm.png',
                height: 48,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                'Find your',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                'real estate',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F4254),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Log In Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF3F4254)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF3F4254),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Skip for now or anon signin
              TextButton(
                onPressed: () async {
                  try {
                    dynamic result = await firebaseAuth.signInAnon();
                    if (result == null) {
                      print('error signing in');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error signing in. Please check your connection.'),
                          ),
                        );
                      }
                    } else {
                      print('signed in');
                      print(result.uid);
                      if (context.mounted) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    print('Error during sign in: $e');
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to sign in: ${e.toString()} Please check your internet connection.'),
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  'Skip for now',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height:
             16),
            ],
          ),
        ),
      ),
    );
  }
}