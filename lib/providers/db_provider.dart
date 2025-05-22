import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class JournalEntry {
  String id;
  String entry;
  String location;
  dynamic activities;
  DateTime date;
  DateTime timestamp;
  List<String> imgUrls;
  int views;

  JournalEntry({
    required this.id,
    required this.entry,
    required this.location,
    required this.activities,
    required this.date,
    required this.timestamp,
    required this.imgUrls,
    required this.views,
  });
}



class DBProvider extends ChangeNotifier {
  String? _userId;
  // Using a map to store journal entries with their Firebase document ID as the key
  Map<String, JournalEntry> _journalEntries = {};
  Map<String, Map<String, dynamic>> _chapters = {};
  List<Map<String, Object>> _journalEntryDates = [];

  String? get userId => _userId;
  set userId(String? id) {
    _userId = id;
    notifyListeners();
  }

  List<JournalEntry> _sortJournalList(List<JournalEntry> x){
    final sortedList = List<JournalEntry>.from(x);
    sortedList.sort((a, b) => b.date.compareTo(a.date));
    return sortedList;
  }


  UnmodifiableMapView<String, JournalEntry> get journalEntries =>
      UnmodifiableMapView(_journalEntries);

  UnmodifiableListView<JournalEntry> get journalEntriesSorted =>
      UnmodifiableListView(_sortJournalList(_journalEntries.values.toList()));

  UnmodifiableMapView<String, Map<String, dynamic>> get chapters =>
      UnmodifiableMapView(_chapters);
    
// Example for displaying journal entry dates
UnmodifiableListView<Map<String, dynamic>> get journalEntryDates =>
    UnmodifiableListView(
      _journalEntries.entries.map((entry) => {
        'date': entry.value.date,
        'id': entry.key,
      }).toList(),
    );

JournalEntry? getJournalEntryById(String entryId) {
  return _journalEntries[entryId];
}

UnmodifiableListView<JournalEntry> getJournalEntriesForDay(DateTime date) {
  final entriesForDay = _journalEntries.values.where((entry) =>
    entry.date.month == date.month &&
    entry.date.day == date.day
  ).toList();
  return UnmodifiableListView(entriesForDay);
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
      final data = doc.data();
      entriesMap[doc.id] = {
        'id': doc.id,
        'entry': data['entry'],
        'location': data['location'],
        'activities': data['activities'],
        'date': DateTime.parse(data['date'].toString()),
        'timestamp': DateTime.parse(data['timestamp'].toString()),
        'imgUrls': data['imgUrls'],
        'views': (data['views'] as int?) ?? 0,
      };
    }

    _journalEntries = entriesMap.map((key, value) => MapEntry(
      key,
      JournalEntry(
        id: value['id'],
        entry: value['entry'],
        location: value['location'],
        activities: value['activities'],
        date: value['date'],
        timestamp: value['timestamp'],
        imgUrls: List<String>.from(value['imgUrls'] ?? []),
        views: value['views'] ?? 0,
      ),
    ));

    _journalEntryDates  = _journalEntries.entries.map((entry) => {
        'date': entry.value.date,
        'id': entry.key,
      }).toList();

    notifyListeners();
  } catch (e) {
    rethrow;
  }
}

  Future<void> viewEntry(String uid, int prevView, User currentUser) async {

    // TODO: Implement viewEntry functionality or remove this method if not needed.
    await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('entries')
          .doc(uid)
          .set({
          'views': prevView + 1,
        }, SetOptions(merge: true));
  }


  Future<String?> _uploadPic(XFile xfile, String uid) async {
    final storageRef = FirebaseStorage.instance.ref();
    // give it a unique name, e.g. based on timestamp + original name
    final name = '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
    final imageRef = storageRef.child('users/$uid/entryImages/$name');
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
      e;
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
      _journalEntries[docRef.id] = JournalEntry(
        id: docRef.id,
        entry: textController.text,
        location: locationTextController.text,
        activities: activities,
        date: selectedDate,
        timestamp: DateTime.now(),
        imgUrls: cloudStorageImgUrls,
        views: 0,
      );

      _journalEntryDates.add({"id": docRef.id, "date": selectedDate});
      _journalEntryDates.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
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

  Future<void> saveChapter({
    required String name,
    required String description,
    String? imageUrl,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // 1) push a new doc into users/<<uid>>/chapters
    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chapters')
        .add({
      'name': name,
      'description': description,
      'image': imageUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'entryIDs': <String>[],
    });

    // 2) update your local cache
    _chapters[docRef.id] = {
      'id': docRef.id,
      'name': name,
      'description': description,
      'image': imageUrl ?? '',
      'createdAt': DateTime.now(),
      'entryIDs': <String>[],
    };

    notifyListeners();
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
