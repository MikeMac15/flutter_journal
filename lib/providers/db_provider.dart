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
  final parsed = DateTime.parse(data['date'].toString());
  final dateOnly = DateTime(parsed.year, parsed.month, parsed.day);
  
      entriesMap[doc.id] = {
        'id': doc.id,
        'entry': data['entry'],
        'location': data['location'],
        'activities': data['activities'],
        'date': dateOnly,
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
//   Future<List<String>> _uploadPicsBatch(List<XFile> files, String uid) async {
//   const int chunkSize = 4;
//   final List<String> allUrls = [];

//   for (var i = 0; i < files.length; i += chunkSize) {
//     // Take a slice of up to 4 files
//     final chunk = files.sublist(
//       i,
//       (i + chunkSize > files.length) ? files.length : i + chunkSize,
//     );

//     // Start uploads for that chunk in parallel
//     final futures = chunk.map((xfile) => _uploadPic(xfile, uid)).toList();
//     final results = await Future.wait(futures);

//     // Keep only non-null URLs
//     allUrls.addAll(results.whereType<String>());
//   }

//   return allUrls;
// }

//   Future<List<String>> _uploadPicsBatch(List<XFile> files, String uid) async {
//   // 1) Map each XFile to one Future<String?> using your existing _uploadPic:
//   final uploads = files.map((xfile) {
//     return _uploadPic(xfile, uid);
//   }).toList();

//   // 2) Wait for all of them to finish in parallel:
//   final results = await Future.wait(uploads);

//   // 3) Filter out any nulls (failed uploads) and return only non‐null URLs:
//   return results.whereType<String>().toList();
// }


  Future<void> saveEntryToFirestore({
    required BuildContext context,
    required User currentUser,
    String? chapterId,
    required List<Map<String, TextEditingController>> activityControllers,
    required TextEditingController textController,
    required TextEditingController locationTextController,
    required DateTime selectedDate,
    required List<String> imagePaths, // local file paths of picked images
    // NEW:
    void Function(int uploadedCount, int totalCount)? onProgress,
    VoidCallback? onComplete,
  }) async {
    // currentUser is required and non-nullable
    final uid = currentUser.uid;

    // Build activities list
    final activities = activityControllers.map((controllerMap) {
      return {
        'name': controllerMap['name']?.text ?? '',
        'description': controllerMap['description']?.text ?? '',
      };
    }).toList();

    try {
      // 1) UPLOAD PHOTOS IN PARALLEL, REPORTING PROGRESS
      final int total = imagePaths.length;
      int uploaded = 0;

      // Create a List<Future<String?>> but wrap each with a `.then(...)` that calls onProgress
      final List<Future<String?>> uploadFutures = imagePaths.map((localPath) {
        return _uploadPic(XFile(localPath), uid).then((url) {
          // Each time one single upload finishes, increment & report:
          uploaded++;
          if (onProgress != null) {
            if (uploaded < total) {
              onProgress(uploaded, total); // e.g. "1/7 uploaded" … "6/7 uploaded"
            } else {
              // uploaded == total
              onProgress(total, total);   // "7/7 uploaded"
            }
          }
          return url; // pass along the URL (or null) for Future.wait to collect
        });
      }).toList();

      // Wait until all finish (in parallel)
      final List<String?> maybeUrls = await Future.wait(uploadFutures);
      final List<String> cloudStorageImgUrls = maybeUrls.whereType<String>().toList();

      // At this point, we have already called onProgress(total, total). Caller can interpret that as:
      // "All photos uploaded. Now saving the entry…"

      // 2) ADD FIRESTORE DOCUMENT IN ONE SHOT
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('entries')
          .add({
        'entry': textController.text,
        'location': locationTextController.text,
        'activities': activities,
        'date': selectedDate.toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
        'imgUrls': cloudStorageImgUrls,
      });

      // 3) UPDATE LOCAL STATE
      _journalEntries[docRef.id] = JournalEntry(
        id: docRef.id,
        entry: textController.text,
        location: locationTextController.text,
        activities: activities,
        date: selectedDate,
        timestamp: DateTime.now(),
        // NOTE: store cloud URLs, not local file paths
        imgUrls: cloudStorageImgUrls,
        views: 0,
      );
      _journalEntryDates.add({'id': docRef.id, 'date': selectedDate});
      _journalEntryDates.sort((a, b) =>
          (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      notifyListeners();

      // 4) OPTIONALLY ATTACH TO A CHAPTER
      if (chapterId != null) {
        await _attachEntryToChapter(context, chapterId, docRef.id);
      }

      // 5) NAVIGATE BACK (CLOSE ANY SCREENS AS BEFORE)
      Navigator.pop(context);

      // 6) UPDATE “lastUse” TIMESTAMP FOR USER
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'lastUse': FieldValue.serverTimestamp()}, SetOptions(merge: true));

      // 7) CALL onComplete() TO SIGNAL “ENTRY SAVED”
      if (onComplete != null) {
        onComplete();
      }
    } catch (e) {
      // If anything fails, show a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save entry: $e')),
      );
    }
  }
  // Future<String?> savePic(String imagePath) async {
  //   final storageRef = FirebaseStorage.instance.ref();
  //   File picFile = File(imagePath);
  //   final metadata = SettableMetadata(contentType: 'image/jpeg');
  //   final String? userId = FirebaseAuth.instance.currentUser?.uid;
  //   if (userId == null) return null;
  //   try {
  //     final imageRef = storageRef.child('$userId/images');
  //     await imageRef.putFile(picFile, metadata);

  //     String downloadURL = await imageRef.getDownloadURL();

  //     return downloadURL;
  //   } on FirebaseException catch (e) {
  //     e.toString();
  //     // print("Error uploading image: $e");
  //     return null;
  //   }
  // }

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

  Future<void> _attachEntryToChapter(
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
