import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_vision/screens/welcome_screen.dart';
import 'package:green_vision/services/auth.dart';
import 'package:green_vision/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get the current user
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // Sign in with Google
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth = await googleSignInAccount?.authentication;

      if (googleAuth == null) {
        throw Exception('Google authentication failed');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        Map<String, dynamic> userInfoMap = {
          "email": userDetails.email,
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          "id": userDetails.uid,
        };

        await DatabaseMethods().addUser(userDetails.uid, userInfoMap).then((value) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => WelcomeScreen()),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In failed: $e")),
      );
    }
  }

  // Sign in with Apple
  Future<User?> signInWithApple({List<Scope> scopes = const [Scope.fullName, Scope.email]}) async {
    try {
      final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)],
      );

      switch (result.status) {
        case AuthorizationStatus.authorized:
          final appleCredential = result.credential!;
          final oAuthProvider = OAuthProvider('apple.com');
          final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleCredential.identityToken!),
          );

          final UserCredential userCredential = await _auth.signInWithCredential(credential);
          final User? firebaseUser = userCredential.user;

          if (firebaseUser != null && scopes.contains(Scope.fullName)) {
            final fullName = appleCredential.fullName;
            if (fullName != null && fullName.givenName != null && fullName.familyName != null) {
              final displayName = '${fullName.givenName} ${fullName.familyName}';
              await firebaseUser.updateDisplayName(displayName);
            }
          }
          return firebaseUser;

        case AuthorizationStatus.error:
          throw PlatformException(
            code: 'ERROR_AUTHORIZATION_DENIED',
            message: result.error?.toString() ?? 'Unknown error',
          );

        case AuthorizationStatus.cancelled:
          throw PlatformException(
            code: 'ERROR_ABORTED_BY_USER',
            message: 'Sign-in aborted by user',
          );

        default:
          throw UnimplementedError();
      }
    } catch (e) {
      throw PlatformException(
        code: 'ERROR_SIGN_IN_FAILED',
        message: 'Sign-in with Apple failed: $e',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
