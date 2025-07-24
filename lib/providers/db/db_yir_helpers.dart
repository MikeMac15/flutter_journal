import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journal/features/questionWalls/YIR_Classes.dart';

Future<List<Yir>> collectAllYir(String uid) async {
  if (uid.isEmpty) return [];
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('yir')
        .get();

    List<Yir> allYir = snapshot.docs.map((doc) => Yir.fromDoc(doc)).toList();
    return allYir;
  } catch (e) {
    print('Error collecting YIR: $e');
    return [];
  }
}