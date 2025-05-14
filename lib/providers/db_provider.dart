import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DBProvider extends ChangeNotifier {
  String? _userId;
  // Using a map to store journal entries with their Firebase document ID as the key
  Map<String, Map<String, dynamic>> _journalEntries = {};
  Map<String, Map<String, dynamic>> _chapters = {};

  String? get userId => _userId;
  set userId(String? id) {
    _userId = id;
    notifyListeners();
  }

  UnmodifiableMapView<String, Map<String, dynamic>> get journalEntries =>
      UnmodifiableMapView(_journalEntries);

  UnmodifiableMapView<String, Map<String, dynamic>> get chapters =>
      UnmodifiableMapView(_chapters);
    
// Example for displaying journal entry dates
UnmodifiableListView<Map<String, dynamic>> get journalEntryDates =>
    UnmodifiableListView(
      _journalEntries.entries.map((entry) => {
        'date': entry.value['date'],
        'id': entry.key,
      }).toList(),
    );

Map<String, dynamic>? getJournalEntryById(String entryId) {
  return _journalEntries[entryId];
}

  


  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Db_privder(40)ErrorMessage: No signed in user.');
    }
    _userId = user.uid;
    // print('################## INITIALIZING DB PROVIDER ##################');
    await fetchJournalEntrySnapshot(); // Fetch journal entries when the provider is initialized
    await loadChapters();
  }

  Future<void> fetchJournalEntrySnapshot() async {
    final uid = _userId!;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('entries')
          .get();

      Map<String, Map<String, dynamic>> entriesMap = {};
      for (var doc in snapshot.docs) {
        // Add each entry to the map with the document ID as the key
        entriesMap[doc.id] = {
          'id': doc.id,
          'entry': doc['entry'],
          'location': doc['location'],
          'activities': doc['activities'],
          'date': (doc['date'] is Timestamp)
              ? doc['date'].toDate()
              : DateTime.parse(doc['date'].toString()), // Handle date conversion
          'timestamp': DateTime.parse(doc['timestamp'].toString()),
          'imgUrls': doc['imgUrls'],
        };
      }
      _journalEntries = entriesMap; // Store the entries map
      notifyListeners();
    } catch (e) {
      // print('Error fetching journal entries: $e');
      rethrow;
    }
  }
  Future<String?> _uploadPic(XFile xfile, String uid) async {
    final storageRef = FirebaseStorage.instance.ref();
    // give it a unique name, e.g. based on timestamp + original name
    final name = '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
    final imageRef = storageRef.child('$uid/images/$name');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    try {
      if (kIsWeb) {
        // read image into memory
        final bytes = await xfile.readAsBytes();
        await imageRef.putData(bytes, metadata);
      } else {
        // on mobile/desktop you still have a real File path
        await imageRef.putFile(File(xfile.path), metadata);
      }
      return await imageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      // handle/log e.code, etc.
      print(e);
      return null;
    }
  }


  Future<void> saveEntryToFirestore({
    context,
    currentUser,
    chapterId,
    activityControllers,
    textController,
    locationTextController,
    selectedDate,
    imagePaths,
  }) async {
    if (currentUser == null) return;
    if (currentUser == null) return;
     final uid = currentUser!.uid;
     List<String> cloudStorageImgUrls = [];

    final activities = activityControllers.map((controllerMap) {
      return {
        'name': controllerMap['name']?.text ?? '',
        'description': controllerMap['description']?.text ?? '',
      };
    }).toList();

    try {
      // print(imagePaths);
      // Upload images to Firebase Storage
      if (imagePaths.isNotEmpty) {
        for (final xfile in imagePaths) {
          print('this');
          final url = await _uploadPic(XFile(xfile), uid);
           if (url != null) cloudStorageImgUrls.add(url);
          
        }
      }
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('entries')
          .add({
        'entry': textController.text,
        'location': locationTextController.text,
        'activities': activities,
        'date': selectedDate.toIso8601String(), // Store date as a field
        'timestamp': DateTime.now().toIso8601String(), // Creation timestamp
        'imgUrls': cloudStorageImgUrls
      });

      // Update the entries map with the new entry
      _journalEntries[docRef.id] = {
        'id': docRef.id,
        'entry': textController.text,
        'location': locationTextController.text,
        'activities': activities,
        'date': selectedDate,
        'timestamp': DateTime.now(),
        'imgUrls': cloudStorageImgUrls,
      };
      notifyListeners();

      if (chapterId != null) {
        await attachEntryToChapter(context, chapterId, docRef.id);
      }
      Navigator.pop(context);

      await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .set({
          'lastUse': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving entry: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save entry: $e')),
      );
    }
  }

  Future<String?> savePic(String imagePath) async {
    final storageRef = FirebaseStorage.instance.ref();
    File picFile = File(imagePath);
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;
    try {
      final imageRef = storageRef.child('$userId/images');
      await imageRef.putFile(picFile, metadata);

      String downloadURL = await imageRef.getDownloadURL();

      return downloadURL;
    } on FirebaseException catch (e) {
      e.toString();
      // print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> loadChapters() async {
    final uid = _userId!;
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chapters')
          .get();

      Map<String, Map<String, dynamic>> chaptersMap = {};
      for (var doc in querySnapshot.docs) {
        chaptersMap[doc.id] = {
          'name': doc['name'] ?? 'No Name',
          'description': doc['description'] ?? 'No Description',
          'image': doc['image'] ?? '',
          'createdAt': doc['createdAt'],
          'entryIDs': List<String>.from(doc['entryIDs'] ?? []),
          'id': doc.id,
        };
      }
      _chapters = chaptersMap; // Store the chapters map
      notifyListeners();
    } catch (e) {
      // print('Error fetching chapters: $e');
    }
  }

  // Fetch a chapter by its ID from the map
  Map<String, dynamic>? getChapterById(String chapterId) {
    return _chapters[chapterId];
  }

  Future<void> attachEntryToChapter(
      context, String chapterId, String entryId) async {
        final uid = _userId!;
    try {
      final chapterRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chapters')
          .doc(chapterId);

      final chapterDoc = await chapterRef.get();
      if (chapterDoc.exists) {
        final currentEntryIDs = List<String>.from(chapterDoc['entryIDs'] ?? []);
        currentEntryIDs.add(entryId);

        await chapterRef.update({
          'entryIDs': currentEntryIDs,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry added to chapter successfully')),
        );
      }
    } catch (e) {
      // print('Error updating chapter: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add entry to chapter')),
      );
    }
  }
}
