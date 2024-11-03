import 'dart:async';
import 'package:flutter/material.dart';
import 'package:green_vision/screens/signin_screen.dart'; // Ensure this is the correct import

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the SignInScreen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // You can add your logo here
            Image.asset(
              'assets/images/logo.png', // Change to your logo's path
              height: 150,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Optional loading indicator
            const SizedBox(height: 20),
            const Text(
              'Welcome to Green Vision',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
