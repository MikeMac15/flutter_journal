import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';



String userId = FirebaseAuth.instance.currentUser!.uid;

class RankedListClass {
  String title;
  List<String> topFive;
  List<String> relatedMemories;

  RankedListClass({
    required this.title,
    List<String>? topFive,
    List<String>? relatedMemories,
  })  : topFive = topFive ?? [],
        relatedMemories = relatedMemories ?? [];
 
  // Method to display the ranked list
  String displayRankedList() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('Ranked List: $title');
    buffer.writeln('Top 5 Memories:');
    for (int i = 0; i < topFive.length; i++) {
      buffer.writeln('${i + 1}. ${topFive[i]}');
    }
    buffer.writeln('Related Memories:');
    for (String memoryFirestoreID in relatedMemories) {
      buffer.writeln('- $memoryFirestoreID');
    }
    return buffer.toString();
  }

  Future<List<String>> adjustTopFive(List<String> newTopFive) async {
    topFive.clear();
    topFive.addAll(newTopFive);

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('rankedLists')
        .doc(title); // Assuming title is unique for each ranked list
      await docRef.update({
        'topFive': topFive,
        'updatedAt': Timestamp.now(),
      });
    return topFive;
  }

  Future<void> addRelatedMemory(String memoryFirestoreID) async {
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('rankedLists')
      .doc(title);

  docRef.update({
    'relatedMemories': FieldValue.arrayUnion([memoryFirestoreID]),
    'updatedAt': Timestamp.now(),
  });
}

  Future<void> removeRelatedMemory(String memoryFirestoreID) async {
    relatedMemories.remove(memoryFirestoreID);
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('rankedLists')
        .doc(title);
    docRef.update({
      'relatedMemories': FieldValue.arrayRemove([memoryFirestoreID]),
      'updatedAt': Timestamp.now(),
    });
  }

  




}