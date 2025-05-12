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
              // Next button
              ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
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
                    onPressed: () async{
                      // TODO: Implement Google sign in
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
    if (!mounted) return;
    try {
      final user = await _auth.createAccount(
        email: _email.text,
        password: _password.text,
      );
      if (user != null) {
        print('User created');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      if (e.code == 'network-request-failed') {
        message = 'No internet connection. Please check your network and try again.';
      } else {
        message = e.message ?? 'An unexpected error occurred.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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