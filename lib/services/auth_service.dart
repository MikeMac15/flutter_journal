import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn  _googleSignIn  = GoogleSignIn();

  Future<User?> signInWithGoogle({bool interactive = true}) async {
    GoogleSignInAccount? googleUser;

    if (kIsWeb && !interactive) {
      // Try to restore a previous web session without UI
      googleUser = await _googleSignIn.signInSilently();
    }
    googleUser ??= await _googleSignIn.signIn();
    if (googleUser == null) {
      // User still didn’t sign in (they cancelled)
      return null;
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken:     googleAuth.idToken,
    );

    final userCred = await _firebaseAuth.signInWithCredential(credential);
    return userCred.user;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
