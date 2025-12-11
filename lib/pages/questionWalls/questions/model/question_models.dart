import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String text;

  Question({required this.id, required this.text});

  // Factory to create a Question from a Map Entry (Key = ID, Value = Text)
  factory Question.fromMapEntry(String key, dynamic value) {
    return Question(
      id: key,
      text: value.toString(),
    );
  }
}

class QuestionAnswer {
  final String id;
  final String text;
  final DateTime date;
  final DateTime updatedAt;

  QuestionAnswer({
    required this.id,
    required this.text,
    required this.date,
    required this.updatedAt,
  });

  factory QuestionAnswer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionAnswer(
      id: doc.id,
      text: data['text'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}