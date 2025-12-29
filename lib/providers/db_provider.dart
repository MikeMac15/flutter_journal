import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/pages/questionWalls/ranked_list_memories/ranked_list_class.dart';
import 'package:journal/pages/questionWalls/yir_classes.dart';
import 'package:journal/providers/db/db_yir_helpers.dart';
import 'package:journal/services/image_compressor.dart';

enum EntryType { journal, photo }

class JournalEntry {
  final String id;
  final EntryType type;

  // Fields for both types
  final DateTime date;
  final DateTime timestamp;
  final List<String> imgUrls;
  final int views;
  final String? entry;

  // Fields for PhotoEntry (optional)

  final List<Map<String, dynamic>>? metadatas;

  // Fields for full JournalEntry (optional)
  final String? location;
  final List<Map<String, dynamic>>? activities;

  JournalEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.timestamp,
    required this.imgUrls,
    required this.entry,
    this.views = 0,
    this.metadatas,
    this.location,
    this.activities,
  });

  // A single, powerful factory to handle all cases
  factory JournalEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final type = data['type'] == 'photo' ? EntryType.photo : EntryType.journal;

    // Safely parse dates
    final parsedDate = (data['date'] is Timestamp)
        ? data['date'].toDate()
        : DateTime.tryParse(data['date'].toString()) ?? DateTime.now();

    final timestamp = (data['timestamp'] is Timestamp)
        ? data['timestamp'].toDate()
        : DateTime.now();

    return JournalEntry(
      id: doc.id,
      type: type,
      date: parsedDate,
      timestamp: timestamp,
      imgUrls: List<String>.from(data['imgUrls'] ?? []),
      views: data['views'] ?? 0,
      entry: data['entry'],
      // Photo-specific fields
      metadatas: data['metadatas'] != null
          ? List<Map<String, dynamic>>.from(data['metadatas'])
          : null,
      // Journal-specific fields
      location: data['location'],
      activities: data['activities'] != null
          ? List<Map<String, dynamic>>.from(data['activities'])
          : null,
    );
  }
}

class Chapter {
  final String id;
  final String name;
  final String description;
  final String image; // storage path or URL
  final DateTime? createdAt; // nullable until server sets it
  final DateTime? lastModified; // nullable until server sets it
  final List<String> entryIDs;

  const Chapter({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.createdAt,
    required this.lastModified,
    required this.entryIDs,
  });

  /// ---- Parsing helpers ----
  static DateTime? _asDateTime(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is int) {
      // support seconds or milliseconds since epoch
      final isSeconds = v < 100000000000; // ~ Sat Mar 03 5138 :)
      return DateTime.fromMillisecondsSinceEpoch(isSeconds ? v * 1000 : v);
    }
    if (v is String) {
      // ISO 8601 or simple date strings
      return DateTime.tryParse(v);
    }
    return null;
  }

  static List<String> _asStringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => e?.toString() ?? '')
          .where((e) => e.isNotEmpty)
          .toList(growable: false);
    }
    return const [];
  }

  /// ---- Firestore converter (read) ----
  factory Chapter.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Chapter(
      id: doc.id,
      name: (data['name'] as String?)?.trim().isNotEmpty == true
          ? data['name'] as String
          : 'No Name',
      description: (data['description'] as String?)?.trim().isNotEmpty == true
          ? data['description'] as String
          : 'No Description',
      image: (data['image'] as String?) ?? '',
      createdAt: _asDateTime(data['createdAt']),
      lastModified: _asDateTime(data['lastModified']),
      entryIDs: _asStringList(data['entryIDs']),
    );
  }

  /// ---- Firestore converter (write) ----
  Map<String, Object?> toFirestore({bool forCreate = false}) {
    return {
      'name': name,
      'description': description,
      'image': image,
      'entryIDs': entryIDs,
      if (forCreate) 'createdAt': FieldValue.serverTimestamp(),
      'lastModified': FieldValue.serverTimestamp(),
    };
  }

  /// ---- copy / equality ----
  Chapter copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    DateTime? createdAt,
    DateTime? lastModified,
    List<String>? entryIDs,
  }) {
    return Chapter(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      entryIDs: (entryIDs ?? this.entryIDs).toList(growable: false),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Chapter &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          image == other.image &&
          createdAt == other.createdAt &&
          lastModified == other.lastModified &&
          const ListEquality<String>().equals(entryIDs, other.entryIDs);

  @override
  int get hashCode => Object.hash(id, name, description, image, createdAt,
      lastModified, const ListEquality<String>().hash(entryIDs));
}

class ImageWithMetadata {
  final XFile file;
  final Map<String, dynamic> metadata;

  ImageWithMetadata({required this.file, this.metadata = const {}});
}

class DBProvider extends ChangeNotifier {
  String? _userId;
  // Using a map to store journal entries with their Firebase document ID as the key
  Map<String, JournalEntry> _journalEntries = {};

  Map<String, Chapter> _chapters = {};
  List<Map<String, Object>> _journalEntryDates = [];
  List<RankedListClass> _rankedLists = [];
  List<Yir> _allYir = [];
  List<RankedListClass> get rankedLists => _rankedLists;
  String? get userId => _userId;
  set userId(String? id) {
    if ((_userId != id && id != null) || _journalEntries.isEmpty) {
      _userId = id;
      _initOnce();
    } else {
      print(
          'DBProvider already initialized. Journal entries: ${_journalEntries.length}');
    }
  }

  bool _isInitialized = false;

  Future<void> triggerRefresh() async {
    if (!_isInitialized) return;

    try {
      await fetchJournalEntrySnapshot();
      await fetchAllRankedLists();
      await loadChapters();
    } catch (e) {
      print('Error refreshing DBProvider: $e');
    }
  }

  Future<void> _initOnce() async {
    if (_isInitialized || _journalEntries.isNotEmpty) {
      print(
          'DBProvider initialized successfully. Journal entry count: ${_journalEntryDates.length}');
      return;
    }

    if (_userId == null) {
      throw StateError('DBProvider: User ID is not set.');
    }

    try {
      print(
          '################## INITIALIZING DB PROVIDER ONCE##################');
      await fetchJournalEntrySnapshot();
      await fetchAllRankedLists();
      await loadChapters();
      _isInitialized = true;
      print(
          'DBProvider initialized successfully. Journal entry count: ${_journalEntryDates.length}');
      notifyListeners();
    } catch (e) {
      print('Error initializing DBProvider: $e');
      rethrow;
    }
  }

  List<JournalEntry> _sortJournalList(List<JournalEntry> x) {
    final sortedList = List<JournalEntry>.from(x);
    sortedList.sort((a, b) => b.date.compareTo(a.date));
    return sortedList;
  }

  List<JournalEntry> getSortedJournalListForThisMonth() {
    final filteredList = _journalEntries.values
        .where((entry) => entry.date.month == DateTime.now().month)
        .toList();
    filteredList.sort((a, b) => b.date.day.compareTo(a.date.day));
    return filteredList;
  }

  List<JournalEntry> getMostRecent5Entries() {
    final sortedList = _sortJournalList(_journalEntries.values.toList());
    return sortedList.take(5).toList();
  }

  UnmodifiableMapView<String, JournalEntry> get journalEntries =>
      UnmodifiableMapView(_journalEntries);

  UnmodifiableListView<JournalEntry> get journalEntriesSorted =>
      UnmodifiableListView(_sortJournalList(_journalEntries.values.toList()));

  UnmodifiableMapView<String, Chapter> get chapters =>
      UnmodifiableMapView(_chapters);

// Example for displaying journal entry dates
  UnmodifiableListView<Map<String, dynamic>> get journalEntryDates =>
      UnmodifiableListView(
        _journalEntries.entries
            .map((entry) => {
                  'date': entry.value.date,
                  'id': entry.key,
                })
            .toList(),
      );

  JournalEntry? getJournalEntryById(String entryId) {
    return _journalEntries[entryId];
  }

  UnmodifiableListView<JournalEntry> getJournalEntriesForDay(DateTime date) {
    final entriesForDay = _journalEntries.values
        .where((entry) =>
            entry.date.month == date.month && entry.date.day == date.day)
        .toList();
    return UnmodifiableListView(entriesForDay);
  }

  Future<void> init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Db_privder(40)ErrorMessage: No signed in user.');
    }
    _userId = user.uid;
    try {
      print('################## INITIALIZING DB PROVIDER ##################');
      await fetchJournalEntrySnapshot(); // Fetch journal entries when the provider is initialized
      await fetchAllRankedLists(); // Fetch ranked lists when the provider is initialized
      await loadChapters();
    } catch (e) {
      print('Error initializing DBProvider: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    _userId = null;
    _journalEntries.clear();
    _chapters.clear();
    _journalEntryDates.clear();
    _rankedLists.clear();
    _allYir.clear();
    _isInitialized = false;
    notifyListeners();
  }

  Future<void> fetchJournalEntrySnapshot() async {
    if (_userId == null) return;
    final uid = _userId!;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('entries')
          .get();

      // Create a temporary map to hold the new data.
      Map<String, JournalEntry> tempEntries = {};

      for (var doc in snapshot.docs) {
        // Use the single, unified factory constructor.
        // It handles the logic of determining the type and parsing correctly.
        tempEntries[doc.id] = JournalEntry.fromFirestore(doc);
      }

      // Replace the old map with the new one.
      _journalEntries = tempEntries;

      // This now correctly includes ALL entries (journals and photos).
      _journalEntryDates = _journalEntries.entries
          .map((entry) => {
                'date': entry.value.date,
                'id': entry.key,
                'type': entry.value.type, // Good to include the type here!
              })
          .toList();

      // It's good practice to sort this list right after creating it.
      _journalEntryDates.sort(
          (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

      notifyListeners();
    } catch (e) {
      print('Error fetching entry snapshot: $e');
      rethrow;
    }
  }

  Future<void> viewEntry(String uid, int prevView, User currentUser) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('entries')
        .doc(uid)
        .set({
      'views': prevView + 1,
    }, SetOptions(merge: true));
  }

  Future<void> deletePicture(String pictureUrl, String entryId) async {
    if (userId == null) throw StateError('userId is null');

    final fs = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    final entryRef =
        fs.collection('users').doc(userId).collection('entries').doc(entryId);

    try {
      // 1) Atomically update Firestore
      await entryRef.update({
        'imgUrls': FieldValue.arrayRemove([pictureUrl]),
      });

      // 2) Delete the storage file (best-effort)
      await storage.refFromURL(pictureUrl).delete();
    } on FirebaseException catch (e) {
      print('Storage delete failed: ${e.code} ${e.message}');
    }

    // 3) Update local cache/UI
    final updatedEntry = _journalEntries[entryId];
    if (updatedEntry != null) {
      updatedEntry.imgUrls.remove(pictureUrl);
      _journalEntries[entryId] = updatedEntry;
    }
    notifyListeners();
  }

  /// Saves a new photo-only entry to Firestore and attaches it to a chapter.
  ///
  /// Returns the ID of the newly created entry document.
  /// Throws an error if the upload or database write fails.
  Future<String> savePhotoEntry({
    required List<ImageWithMetadata> imageFilesWithMetadata,
    required String entry,
    required DateTime date,
    required String chapterId,
    List<Map<String, dynamic>>? metadata,
  }) async {
    // 1. Ensure the user is logged in.
    if (_userId == null) {
      throw StateError('User is not logged in. Cannot save photo entry.');
    }
    final uid = _userId!;

    try {
      // 1. UPLOAD PHOTOS AND KEEP TRACK OF URLS
      // This part is key. We map each file to its upload future.
      final List<Future<String?>> uploadFutures =
          imageFilesWithMetadata.map((img) {
        return _getOrUploadPic(img.file); // Your duplicate check function
      }).toList();

      // Wait for all uploads to complete
      final List<String?> uploadedUrls = await Future.wait(uploadFutures);

      // 2. CREATE THE LINKED METADATA LIST
      final List<Map<String, dynamic>> finalMetadatas = [];
      final List<String> finalImageUrls = [];

      for (int i = 0; i < uploadedUrls.length; i++) {
        final url = uploadedUrls[i];
        if (url != null) {
          // If the upload was successful, add the URL to our final list
          finalImageUrls.add(url);

          // Add the corresponding metadata from the original list
          // We also add the 'url' to the metadata map itself for easy lookup later!
          final metadata = imageFilesWithMetadata[i].metadata;
          metadata['url'] = url; // Link the URL directly
          finalMetadatas.add(metadata);
        }
      }

      // 3. Create the new entry document in the 'entries' collection.
      // We use the same collection as full journal entries for simplicity.
      final entryRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('entries')
          .doc(); // Let Firestore generate a unique ID.

      // 4. Set the data for the new photo entry.
      // It's crucial to add a 'type' field to differentiate it from full journal entries.
      await entryRef.set({
        'type': 'photo', // Explicitly define the type for future use.
        'imgUrls':
            finalImageUrls, // Use the correct list of uploaded image URLs.
        'entry': entry,
        'date': Timestamp.fromDate(date),
        'metadatas': finalMetadatas, // Use the correct list of metadatas.
        'timestamp':
            FieldValue.serverTimestamp(), // Firestore server-side timestamp.

        // Explicitly set other fields to null for data consistency.
        'location': null,
        'activities': null,
      });

      // 5. Attach the new entry's ID to the specified chapter.
      await attachEntryToChapter(chapterId, entryRef.id);

      // 6. Optionally, update your local state here if you keep a cache.
      _journalEntries[entryRef.id] = JournalEntry(
        id: entryRef.id,
        type: EntryType.photo,
        date: date,
        timestamp: DateTime.now(),
        imgUrls: finalImageUrls,
        entry: entry,
        metadatas: finalMetadatas,
        views: 0, // Default views to 0 for new entries
      );

      // _photoEntries[entryRef.id] = PhotoEntry(...);
      // notifyListeners();

      // 7. Return the new document ID so the UI can navigate to it.
      return entryRef.id;
    } catch (e) {
      // If any step fails, log the error and re-throw it so the UI can handle it.
      print('Failed to save photo entry: $e');
      rethrow;
    }
  }

Future<void> preSavePhoto(XFile file) async {

  // 2. Extract Metadata (You need this for the journal entry anyway)


  // 3. Trigger background upload using the hash logic we discussed
  unawaited(_getOrUploadPic(file));
}



  final Map<String, Future<String?>> _activeUploads = {};
Future<String?> getOrUploadPic(XFile file)async{
    return _getOrUploadPic(file);
}
Future<String?> _getOrUploadPic(XFile xfile) async {
  final String imageHash = await calculateImageHash(xfile);

  // 1. Check if this exact hash is CURRENTLY being uploaded right now
  if (_activeUploads.containsKey(imageHash)) {
    return _activeUploads[imageHash];
  }

  // 2. Start the process and store the Future in our map
  final uploadFuture = () async {
    // Check Firestore for existing record
    final hashDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('imageHashes')
        .doc('userImageHashes');

    final hashDoc = await hashDocRef.get();

    if (hashDoc.exists && hashDoc.data()!.containsKey(imageHash)) {
      return hashDoc.data()![imageHash] as String;
    }

    // New Image: Upload
    final String? downloadUrl = await _uploadPic(xfile);

    if (downloadUrl != null) {
      await hashDocRef.set({imageHash: downloadUrl}, SetOptions(merge: true));
    }
    return downloadUrl;
  }();

  _activeUploads[imageHash] = uploadFuture;
  
  try {
    return await uploadFuture;
  } finally {
    // Clean up map once done
    _activeUploads.remove(imageHash);
  }
}
  Future<List<String>> uploadMultiPics(List<XFile> xfiles) async {
    if (_userId == null) {
      throw StateError('DBProvider: User ID is not set.');
    }
    final List<String> urls = [];
    for (final xfile in xfiles) {
      final url = await _getOrUploadPic(xfile);
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }

  Future<String?> _uploadPic(XFile xfile) async {
    final storageRef = FirebaseStorage.instance.ref();
    final name =
        '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}_${Random().nextInt(99999)}';
    final imageRef = storageRef.child('users/$userId/entryImages/$name');
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    try {
      if (kIsWeb) {
        final bytes = await xfile.readAsBytes();
        await imageRef.putData(bytes, metadata);
      } else {
        await imageRef.putFile(File(xfile.path), metadata);
      }
      return await imageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      // This catches specific Firebase errors (e.g., permissions)
      print('Firebase error during upload for ${xfile.name}: ${e.code}');
      return null; // Return null on failure, don't throw
    } catch (e, stackTrace) {
      // MODIFICATION: Add a generic catch-all for other errors
      print('Generic error during upload for ${xfile.name}: $e');
      print(stackTrace);
      return null; // Return null on failure, don't throw
    }
  }

// MODIFICATION: Refactored to throw on error instead of using callbacks for completion/error handling
  Future<String> saveEntryToFirestore({
    required User currentUser,
    String? chapterId,
    required List<Map<String, TextEditingController>> activityControllers,
    required TextEditingController textController,
    required TextEditingController locationTextController,
    required DateTime selectedDate,
    required List<ImageWithMetadata> imagesWithMetadata,
    void Function(int uploadedCount, int totalCount)? onProgress,
  }) async {
    // Returns the new entry ID on success
    final uid = currentUser.uid;
    final activities = activityControllers.map((controllerMap) {
      return {
        'name': controllerMap['name']?.text ?? '',
        'description': controllerMap['description']?.text ?? '',
      };
    }).toList();

    // 1. UPLOAD PHOTOS AND KEEP TRACK OF URLS
    // This part is key. We map each file to its upload future.
    final List<Future<String?>> uploadFutures = imagesWithMetadata.map((img) {
      return _getOrUploadPic(img.file); // Your duplicate check function
    }).toList();

    // Wait for all uploads to complete
    final List<String?> uploadedUrls = await Future.wait(uploadFutures);
    print(uploadedUrls);
    // 2. CREATE THE LINKED METADATA LIST
    final List<Map<String, dynamic>> finalMetadatas = [];
    final List<String> finalImageUrls = [];

    for (int i = 0; i < uploadedUrls.length; i++) {
      final url = uploadedUrls[i];
      if (url != null) {
        // If the upload was successful, add the URL to our final list
        finalImageUrls.add(url);

        // Add the corresponding metadata from the original list
        // We also add the 'url' to the metadata map itself for easy lookup later!
        final metadata = imagesWithMetadata[i].metadata;
        metadata['url'] = url; // Link the URL directly
        finalMetadatas.add(metadata);
      }
    }

    // 2) ADD FIRESTORE DOCUMENT
    final docRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('entries')
        .add({
      'entry': textController.text,
      'location': locationTextController.text,
      'activities': activities,
      'date': selectedDate.toIso8601String(),
      'timestamp': Timestamp.now(),
      'imgUrls': finalImageUrls, // The list of successful URLs
      'metadatas': finalMetadatas, // The corresponding list of metadata maps
    });

    // 3) UPDATE LOCAL STATE
    _journalEntries[docRef.id] = JournalEntry(
      id: docRef.id,
      type: EntryType.journal,
      entry: textController.text,
      location: locationTextController.text,
      activities: activities,
      date: selectedDate,
      timestamp: Timestamp.now().toDate(),
      imgUrls: finalImageUrls,
      metadatas: finalMetadatas,
      views: 0,
    );
    _journalEntryDates.add({'id': docRef.id, 'date': selectedDate});
    _journalEntryDates.sort(
        (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    // 4) OPTIONALLY ATTACH TO A CHAPTER
    if (chapterId != null) {
      await attachEntryToChapter(chapterId, docRef.id);
    }

    // 5) UPDATE “lastUse” TIMESTAMP FOR USER
    await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'lastUse': FieldValue.serverTimestamp()}, SetOptions(merge: true));

    // 6) Return the ID and notify listeners
    notifyListeners();
    return docRef.id;
  }

  CollectionReference<Map<String, dynamic>> _chaptersCol(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('chapters');

  Future<Chapter> saveChapter({
    required String name,
    required String description,
    String? imageUrl,
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 1) Create a new doc id
    final docRef = _chaptersCol(uid).doc();

    // 2) Write with server timestamps
    await docRef.set({
      'name': name,
      'description': description,
      'image': imageUrl ?? '',
      'entryIDs': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'lastModified': FieldValue.serverTimestamp(),
    });

    // 3) Read back to get resolved server timestamps
    final snap = await docRef.get();
    final chapter =
        Chapter.fromFirestore(snap);

    // 4) Update local cache with authoritative values
    _chapters[chapter.id] = chapter;
    notifyListeners();

    return chapter;
  }

  Future<void> loadChapters() async {
  if (_userId == null) return;

  try {
    final qs = await _chaptersCol(_userId!).withConverter<Chapter>(
      fromFirestore: (snap, _) => Chapter.fromFirestore(snap),
      toFirestore: (_, __) => {},
    ).get();

    // Sort in memory: lastModified DESC, fallback to createdAt DESC
    final list = qs.docs.map((d) => d.data()).toList()
      ..sort((a, b) {
        final da = a.lastModified ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.lastModified ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da); // DESC
      });

    _chapters = { for (final ch in list) ch.id: ch };
    print('_chapters loaded successfully: ${_chapters.length} items.');
  } catch (e, st) {
    print('Error fetching chapters: $e');
    print(st);
  } finally {
    notifyListeners();
  }
}


  Future<Chapter> updateChapter(
    String chapterId, {
    String? name,
    String? description,
    String? imageUrl,
    List<String>?
        entryIDs, // if provided, either replaces or merges (see mergeEntryIDs)
    bool mergeEntryIDs = false,
  }) async {
    final uid = _userId ?? FirebaseAuth.instance.currentUser!.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chapters')
        .doc(chapterId);

    // Build a sparse update map
    final Map<String, Object?> update = {
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (imageUrl != null) 'image': imageUrl,
      'lastModified': FieldValue.serverTimestamp(),
    };

    // Handle entryIDs (replace vs merge)
    if (entryIDs != null) {
      if (mergeEntryIDs) {
        update['entryIDs'] = FieldValue.arrayUnion(entryIDs);
      } else {
        update['entryIDs'] = entryIDs;
      }
    }

    // If nothing to change besides lastModified, still do it
    await docRef.set(update, SetOptions(merge: true));

    // Read back to get resolved timestamps and normalized data
    final snap = await docRef.get();
    final chapter =
        Chapter.fromFirestore(snap);

    // Update local cache
    _chapters[chapter.id] = chapter;
    notifyListeners();

    return chapter;
  }

// Fetch a chapter by its ID from the map
  Chapter? getChapterById(String chapterId) {
    return _chapters[chapterId];
  }

  Future<Chapter> renameChapter(String chapterId, String newName) {
    return updateChapter(chapterId, name: newName);
  }

  Future<Chapter> updateChapterDescription(
      String chapterId, String newDescription) {
    return updateChapter(chapterId, description: newDescription);
  }

  Future<Chapter> updateChapterImage(String chapterId, String newImageUrl) {
    return updateChapter(chapterId, imageUrl: newImageUrl);
  }

  Future<Chapter> replaceChapterEntries(
      String chapterId, List<String> newOrder) {
    return updateChapter(chapterId, entryIDs: newOrder, mergeEntryIDs: false);
  }

  Future<Chapter> addEntriesToChapter(String chapterId, List<String> ids) {
    return updateChapter(chapterId,
        entryIDs: ids, mergeEntryIDs: true); // uses arrayUnion
  }

  Future<void> attachEntryToChapter(String chapterId, String entryId) async {
    final uid = _userId!;
    final chapterRef = _chaptersCol(uid).doc(chapterId);

    await chapterRef.update({
      'entryIDs':
          FieldValue.arrayUnion([entryId]), // ✅ no dupes, safe under contention
      'lastModified': FieldValue.serverTimestamp(),
    });

    // Optional: optimistically reflect in cache
    final current = _chapters[chapterId];
    if (current != null && !current.entryIDs.contains(entryId)) {
      _chapters[chapterId] = current.copyWith(
        entryIDs: [...current.entryIDs, entryId],
        lastModified: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> detachEntryFromChapter(String chapterId, String entryId) async {
    final uid = _userId!;
    final chapterRef = _chaptersCol(uid).doc(chapterId);

    await chapterRef.update({
      'entryIDs': FieldValue.arrayRemove([entryId]),
      'lastModified': FieldValue.serverTimestamp(),
    });

    final current = _chapters[chapterId];
    if (current != null && current.entryIDs.contains(entryId)) {
      final next = [...current.entryIDs]..remove(entryId);
      _chapters[chapterId] = current.copyWith(
        entryIDs: next,
        lastModified: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> fetchAllRankedLists() async {
    if (_userId == null) {
      throw StateError('DBProvider: User ID is not set.');
    }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('rankedLists')
          .get();

      // Map each document into your model
      final userRankedLists = snapshot.docs.map((doc) {
        final data = doc.data();
        return RankedListClass(
          title: data['title'] as String,
          topFive: List<String>.from(data['topFive'] ?? []),
          relatedMemories: List<String>.from(data['relatedMemories'] ?? []),
        );
      }).toList();

      _rankedLists = userRankedLists;
      notifyListeners();
    } catch (e) {
      // You might log or rethrow
      debugPrint('Error fetching ranked lists: $e');
      rethrow;
    }
  }

  Future<void> addRankedList(RankedListClass rankedList) async {
    if (_userId == null) {
      throw StateError('DBProvider: User ID is not set.');
    }
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('rankedLists')
          .add({
        'title': rankedList.title,
        'topFive': rankedList.topFive,
        'relatedMemories': rankedList.relatedMemories,
      });

      // Add the new RankedListClass to the local list
      _rankedLists.add(rankedList);
      notifyListeners();
    } catch (e) {
      debugPrint(
          '///////////////////////////////////////////////////  Error adding ranked list: $e');
      rethrow;
    }
  }

  Future<void> updateRankedList(RankedListClass rankedList) async {
    if (_userId == null) {
      throw StateError('DBProvider: User ID is not set.');
    }
    try {
      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('ranked_lists')
          .doc(rankedList.title);

      await docRef.update({
        'topFive': rankedList.topFive,
        'relatedMemories': rankedList.relatedMemories,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update the local list
      final index =
          _rankedLists.indexWhere((list) => list.title == rankedList.title);
      if (index != -1) {
        _rankedLists[index] = rankedList;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating ranked list: $e');
      rethrow;
    }
  }

////////////      YIR

  Future<void> _refreshYirInMemory(String year) async {
    final snap = await yirDocRef(year).get();
    if (!snap.exists) return;
    final y = Yir.fromDoc(snap);
    final i = _allYir.indexWhere((e) => e.year == year);
    if (i == -1) {
      _allYir.add(y);
    } else {
      _allYir[i] = y;
    }
    notifyListeners();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getYirDocument(
      String year) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('yir')
        .doc(year)
        .get();
  }

  DocumentReference<Map<String, dynamic>> yirDocRef(String year) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('yir')
        .doc(year);
  }

  Future<void> fetchAllYIR() async {
    if (_userId == null) {
      throw StateError('DBProvider: User ID is not set.');
    }
    try {
      final uid = _userId!;
      _allYir = await collectAllYir(uid);

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching Year In Review questions: $e');
      rethrow;
    }
  }

  List<Yir> get allYir => _allYir;

  Future<void> saveYir(Yir yir) async {
    await yirDocRef(yir.year).set(yir.toMap(), SetOptions(merge: true));
  }

  Future<void> updateYir(Yir yir) async {
    if (_userId == null) {
      throw StateError('DBProvider: User ID is not set.');
    }
    try {
      final docRef = yirDocRef(yir.year);

      await docRef.update(yir.toMap());

      // Update the local list
      final index = _allYir.indexWhere((item) => item.year == yir.year);
      if (index != -1) {
        _allYir[index] = yir;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating Year In Review question: $e');
      rethrow;
    }
  }

  Future<void> addCategory(String year, YirCategory newCategory,
      {bool preventDuplicateTitle = true}) async {
    final fs = FirebaseFirestore.instance;
    final docRef = yirDocRef(year);

    await fs.runTransaction((tx) async {
      final snap = await tx.get(docRef);

      if (!snap.exists) {
        tx.set(docRef, {
          'year': year,
          'categories': [newCategory.toMap()],
          'recaps': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      final data = snap.data() as Map<String, dynamic>;
      final List cats = List.from((data['categories'] as List?) ?? []);

      if (preventDuplicateTitle) {
        final t = newCategory.title.trim().toLowerCase();
        final exists = cats.any((c) => (c is Map &&
            (c['title'] ?? '').toString().trim().toLowerCase() == t));
        if (exists) return; // no-op
      }

      cats.add(newCategory.toMap());

      tx.update(docRef, {
        'categories': cats,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _refreshYirInMemory(year);
  }

  Future<void> deleteItemFromCategory(
    String year,
    String categoryTitle,
    int itemIndex,
  ) async {
    final ref = yirDocRef(year);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data() as Map<String, dynamic>;
      final List cats = List.from((data['categories'] as List?) ?? []);
      final idx = cats
          .indexWhere((c) => (c is Map) && (c['title'] ?? '') == categoryTitle);
      if (idx == -1) return;

      final Map cat = Map<String, dynamic>.from(cats[idx] as Map);
      final List items = List.from((cat['items'] as List?) ?? []);
      if (itemIndex < 0 || itemIndex >= items.length) return;

      items.removeAt(itemIndex);
      cat['items'] = items;
      cats[idx] = cat;

      tx.update(ref, {
        'categories': cats,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _refreshYirInMemory(year);
  }

  Future<void> updateCategoryItems(
      String year, YirCategory updatedCategory) async {
    final ref = yirDocRef(year);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;

      final data = snap.data() as Map<String, dynamic>;
      final List cats = List.from((data['categories'] as List?) ?? []);
      final idx = cats.indexWhere(
          (c) => (c is Map) && (c['title'] ?? '') == updatedCategory.title);
      if (idx == -1) return;

      final Map cat = Map<String, dynamic>.from(cats[idx] as Map);
      cat['items'] = updatedCategory.items.map((e) => e.toMap()).toList();
      cats[idx] = cat;

      tx.update(ref, {
        'categories': cats,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _refreshYirInMemory(year);
  }

  Future<void> addItemToCategory(
    String year,
    String categoryTitle,
    YirItem newItem,
  ) async {
    final ref = yirDocRef(year);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        // If year doc doesn't exist yet, create it with this category & item.
        tx.set(ref, {
          'year': year,
          'categories': [
            {
              'title': categoryTitle,
              'items': [newItem.toMap()]
            }
          ],
          'recaps': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }

      final data = snap.data() as Map<String, dynamic>;
      final List cats = List.from((data['categories'] as List?) ?? []);
      final idx = cats
          .indexWhere((c) => (c is Map) && (c['title'] ?? '') == categoryTitle);

      if (idx == -1) {
        cats.add({
          'title': categoryTitle,
          'items': [newItem.toMap()]
        });
      } else {
        final Map cat = Map<String, dynamic>.from(cats[idx] as Map);
        final List items = List.from((cat['items'] as List?) ?? []);
        items.add(newItem.toMap());
        cat['items'] = items;
        cats[idx] = cat;
      }

      tx.update(ref, {
        'categories': cats,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    await _refreshYirInMemory(year);
  }

/////////////// RECAPS //////////////////////
  Future<void> addRecap(String year, YirRecap recap) async {
    final ref = yirDocRef(year);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        tx.set(ref, {
          'year': year,
          'categories': [],
          'recaps': [recap.toMap()],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return;
      }
      final data = snap.data() as Map<String, dynamic>;
      final List recaps = List.from((data['recaps'] as List?) ?? []);
      recaps.add(recap.toMap());
      tx.update(
          ref, {'recaps': recaps, 'updatedAt': FieldValue.serverTimestamp()});
    });
    await _refreshYirInMemory(year);
  }

  Future<void> updateRecap(String year, int index, YirRecap recap) async {
    final ref = yirDocRef(year);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final List recaps = List.from((data['recaps'] as List?) ?? []);
      if (index < 0 || index >= recaps.length) return;
      recaps[index] = recap.toMap();
      tx.update(
          ref, {'recaps': recaps, 'updatedAt': FieldValue.serverTimestamp()});
    });
    await _refreshYirInMemory(year);
  }

  Future<void> deleteRecap(String year, int index) async {
    final ref = yirDocRef(year);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;
      final List recaps = List.from((data['recaps'] as List?) ?? []);
      if (index < 0 || index >= recaps.length) return;
      recaps.removeAt(index);
      tx.update(
          ref, {'recaps': recaps, 'updatedAt': FieldValue.serverTimestamp()});
    });
    await _refreshYirInMemory(year);
  }
}
