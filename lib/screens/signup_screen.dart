import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'password_setup_screen.dart';
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

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
          'Sign Up',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Text(
                'findRE',
                style: TextStyle(
                  color: Colors.red[400],
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Already have an account text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );                      // TODO: Navigate to login screen
                    },
                    child: const Text('Log In'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Form fields
              TextField(
                decoration: InputDecoration(
                  labelText: 'FIRST NAME',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'LAST NAME',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              // Next button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordSetupScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 24),
              // Or continue with text
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('or continue with'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              // Social login buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SocialButton(
                    onPressed: () {
                      // TODO: Implement Google sign in
                    },
                    icon: 'Google',
                  ),
                  _SocialButton(
                    onPressed: () {
                      // TODO: Implement Apple sign in
                    },
                    icon: 'Apple',
                  ),
                  _SocialButton(
                    onPressed: () {
                      // TODO: Implement Facebook sign in
                    },
                    icon: 'Facebook',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        side: const BorderSide(color: Colors.grey),
        minimumSize: const Size(90, 45),
      ),
      child: Text(
        icon,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
        ),
      ),
    );
  }
}