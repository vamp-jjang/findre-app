import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = AuthService();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _passwordVisible = false;
final formKey = GlobalKey<FormState>();
String errorMessage = '';

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  void register() async{
    try{
      await authService.value.createAccount(
      email: _email.text,
      password: _password.text,
    );
      popPage();
    } on FirebaseAuthException catch(e){
      setState(() {
        errorMessage = e.message ?? 'There is an error';
      });
    }
  }
      void popPage(){
      Navigator.pop(context);
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
                  Image.asset(
                    'assets/icons/findre_tm.png',
                    height: 48,
                    fit: BoxFit.contain,
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
                controller: _username,
                decoration: InputDecoration(
                  labelText: 'USERNAME',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  labelText: 'EMAIL',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _password,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Display error message if any
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Next button
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 246, 78, 78),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 16,color: Colors.white),
                  
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
                    onPressed: () async {
                      await _auth.loginWithGoogle();
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
    void _signup() async{
      setState(() {
        errorMessage = ''; // Clear previous error messages
      });
      try {
         final user = await _auth.createAccount(
          email: _email.text,
          password: _password.text,
        );
        if(user != null){
          print('User created');
          // Navigate to LoginScreen after successful signup
          // It's generally better to navigate to a screen that confirms account creation
          // or directly to the home screen if auto-login is implemented.
          // For now, as per existing logic, navigating to LoginScreen.
          if (mounted) { // Check if the widget is still in the tree
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String displayMessage;
        switch (e.code) {
          case 'invalid-email':
            displayMessage = 'Invalid email address. Please enter a valid email.';
            break;
          case 'email-already-in-use':
            displayMessage = 'This email address is already in use by another account.';
            break;
          case 'weak-password':
            displayMessage = 'The password provided is too weak.';
            break;
          case 'network-request-failed':
            displayMessage = 'No internet connection. Please check your network and try again.';
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No internet connection. Please check your network and try again.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            // We still set errorMessage for consistency, though SnackBar is shown
            // Or choose to only show SnackBar and not update errorMessage for network issues
            break;
          default:
            displayMessage = e.message ?? 'An unexpected error occurred. Please try again.';
        }
        if (mounted) {
          setState(() {
            errorMessage = displayMessage;
          });
        }
      } catch (e) {
        // Catch any other non-FirebaseAuth exceptions
        if (mounted) {
          setState(() {
            errorMessage = 'An unexpected error occurred. Please try again.';
          });
        }
        print('Signup error: $e'); // Log for debugging
      }
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
      child: icon == 'Google'
          ? Image.asset(
              'assets/icons/google.png',
              height: 24,
              width: 24,
            )
          : icon == 'Apple'
              ? Image.asset(
                  'assets/icons/apple.png',
                  height: 24,
                  width: 24,
                )
          : icon == 'Facebook'
              ? Image.asset(
                  'assets/icons/facebook.png',
                  height: 24,
                  width: 24,
                )
              : Text(
                  icon,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
    );
  }
}