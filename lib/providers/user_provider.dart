import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:journal/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final _auth = AuthService();
  late User? _user = FirebaseAuth.instance.currentUser;
  UnmodifiableMapView<String, dynamic>? get userInfo => _user != null ? UnmodifiableMapView({"user":_user}) : null;

  bool get isLoggedIn => _user != null;

  String? get userId => _user?.uid;

  String? get userEmail => _user?.email;

  String? get userDisplayName => _user?.displayName;

  String? get userPhotoURL => _user?.photoURL;

  UserProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    print("isLoggedIn: $isLoggedIn");
    // On web, try silent sign in first; on mobile this just skips to null
    if(!isLoggedIn){
    final u = await _auth.signInWithGoogle(interactive: false);
    if (u != null) {
      _user = u;
    }
    }
      notifyListeners();
  }

  Future<void> signIn() async {
    _user = await _auth.signInWithGoogle();
    print('//////////////////////////////////');
    print(_user);
    print('//////////////////////////////////');
    if (_user != null) {
      await _upsertUser(_user!);
    }
    notifyListeners();
  }

  Future<void> _upsertUser(User user) async {
    try{

    await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .set({
        'name'      : user.displayName,
        'email'     : user.email,
        'createdAt' : user.metadata.creationTime,
        'lastLogin' : user.metadata.lastSignInTime,
      }, SetOptions(merge: true));
    } catch (e) {
      print('upsertUser');
      print(e);
    }
  }


  Future<void> signOut() async {
    print("SignOut!!!!!!!!!!!!!!!!!!!!!!!!!");
    await _auth.signOut();
    _user = null;
    notifyListeners();
  }

}