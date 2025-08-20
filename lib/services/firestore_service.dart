import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Save a journal entry for a specific user and date.
  Future<void> saveEntry({
    required String userId,
    required DateTime date,
    required String content,
  }) async {
    final docId = _formatDate(date);
    await _db
        .collection('journals')
        .doc(userId)
        .collection('entries')
        .doc(docId)
        .set({
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Retrieve a journal entry for a specific user and date.
  Future<String?> getEntry({
    required String userId,
    required DateTime date,
  }) async {
    final docId = _formatDate(date);
    final doc = await _db
        .collection('journals')
        .doc(userId)
        .collection('entries')
        .doc(docId)
        .get();

    if (doc.exists) {
      return doc.data()?['content'];
    }
    return null;
  }

  /// Get all journal entries for a user (optional utility method).
  Future<Map<DateTime, String>> getAllEntries(String userId) async {
    final snapshot = await _db
        .collection('journals')
        .doc(userId)
        .collection('entries')
        .get();

    final Map<DateTime, String> entries = {};
    for (var doc in snapshot.docs) {
      final date = DateTime.parse(doc.id); // doc.id is "yyyy-MM-dd"
      final content = doc.data()['content'] as String;
      entries[date] = content;
    }
    return entries;
  }

  /// Format date as 'yyyy-MM-dd'
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
           '-${date.month.toString().padLeft(2, '0')}'
           '-${date.day.toString().padLeft(2, '0')}';
  }
}
