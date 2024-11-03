import 'package:flutter/material.dart';
import 'package:green_vision/screens/signin_screen.dart';
import 'package:green_vision/screens/signup_screen.dart';
import 'package:green_vision/widgets/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                          text: 'Welcome back!\n',
                          style: TextStyle(
                            fontSize: 45.0,
                            fontWeight: FontWeight.w600,
                          )),
                      TextSpan(
                          text: '\nEnter personal details of your employee account',
                          style: TextStyle(
                            fontSize: 20,
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: WelcomeButton(
                        buttonText: 'Sign In',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInScreen(),
                            ),
                          );
                        },
                        color: Colors.transparent,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 20), // Space between buttons
                    Expanded(
                      child: WelcomeButton(
                        buttonText: 'Sign Up',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        color: Colors.white,
                        textColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40), // Add some bottom padding
        ],
      ),
    );
  }
}

class WelcomeButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  const WelcomeButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3.0), // Further reduced vertical padding
        width: 160, // Fixed width for more compact appearance
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25), // More rounded corners
          border: Border.all(
            color: textColor,
            width: 1.5, // Slightly thicker border
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              color: textColor,
              fontSize: 16, // Slightly smaller font
              fontWeight: FontWeight.w600, // Made text semi-bold
              letterSpacing: 0.5, // Added slight letter spacing
            ),
          ),
        ),
      ),
    );
  }
}
