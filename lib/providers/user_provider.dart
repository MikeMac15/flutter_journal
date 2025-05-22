import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final _auth = AuthService();
  User? _user = FirebaseAuth.instance.currentUser;

  // NEW: header image URL
  String? _headerImageUrl;
  String? get headerImageUrl => _headerImageUrl;

  UnmodifiableMapView<String, dynamic>? get userInfo =>
      _user != null ? UnmodifiableMapView({"user": _user}) : null;

  bool get isLoggedIn => _user != null;
  String? get userId => _user?.uid;
  String? get userEmail => _user?.email;
  String? get userDisplayName => _user?.displayName;
  String? get userPhotoURL => _user?.photoURL;

  UserProvider() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    if (!isLoggedIn) {
      final u = await _auth.signInWithGoogle(interactive: false);
      if (u != null) _user = u;
    }
    // load header image if we have a user
    if (_user != null) await loadHeaderImage();
    notifyListeners();
  }

  Future<void> signIn() async {
    _user = await _auth.signInWithGoogle();
    if (_user != null) {
      await _upsertUser(_user!);
      await loadHeaderImage();
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _headerImageUrl = null;
    notifyListeners();
  }

  Future<void> _upsertUser(User user) async {
    final uid = user.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
          'name': user.displayName,
          'email': user.email,
          'createdAt': user.metadata.creationTime,
          'lastLogin': user.metadata.lastSignInTime,
        }, SetOptions(merge: true));
  }

  /// Loads the headerImageUrl from Firestore into local state
  Future<void> loadHeaderImage() async {
    final uid = _user?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data()!.containsKey('headerImageUrl')) {
      _headerImageUrl = doc.get('headerImageUrl') as String?;
      notifyListeners();
    }
  }

  /// Prompts user to pick an image, uploads it, saves URL in Firestore & state.
  Future<void> pickAndUploadHeaderImage() async {
    final uid = _user?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;

    // upload to storage
    final storageRef = FirebaseStorage.instance.ref().child('users/$uid/headerPic/header.jpg');
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      await storageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      await storageRef.putFile(File(file.path), SettableMetadata(contentType: 'image/jpeg'));
    }

    final url = await storageRef.getDownloadURL();

    // write into Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid)
      .set({'headerImageUrl': url}, SetOptions(merge: true));

    // update local state
    _headerImageUrl = url;
    notifyListeners();
  }
}
