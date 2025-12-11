import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:journal/pages/questionWalls/questions/model/question_models.dart';

class QuestionTopic {
  final String id;    // Firestore document ID
  final String title; // Display title
  final String? description;

  QuestionTopic({required this.id, required this.title, this.description});
}

class QuestionsProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- CONFIGURATION ---
  // Define your available topics here. These match document IDs in 'app_content'.
  final List<QuestionTopic> _topics = [
    QuestionTopic(id: 'daily_questions', title: 'Daily Reflections', description: 'Small checks-ins for every day.'),
    QuestionTopic(id: 'weekly_questions', title: 'Weekly Recap', description: 'Look back at your week.'),
    QuestionTopic(id: 'relationships', title: 'Relationships', description: 'Questions about love and friendship.'),
    QuestionTopic(id: 'deep_cuts', title: 'Deep Cuts', description: 'Thought-provoking questions.'),
    QuestionTopic(id: 'fun', title: 'Just for Fun', description: 'Lighter questions to break the ice.'),
    QuestionTopic(id: 'nostalgia', title: 'Nostalgia', description: 'Blast from the past.'),
    QuestionTopic(id: 'travel', title: 'Travel', description: 'Adventures near and far.'),
    QuestionTopic(id: 'career', title: 'Career', description: 'Work life and goals.'),
  ];

  // --- STATE ---
  // Stores questions organized by Topic ID: {'daily_questions': [Q1, Q2...], ...}
  Map<String, List<Question>> _questionsByTopic = {};
  
  // A flat list of ALL questions for the randomizer
  List<Question> _masterPool = [];
  
  // The 3 currently displayed random questions
  List<Question> _randomDisplay = [];
  
  bool _isLoading = false;

  // --- GETTERS ---
  List<QuestionTopic> get topics => _topics;
  List<Question> get randomDisplay => _randomDisplay;
  bool get isLoading => _isLoading;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  // --- ACTIONS ---

  /// Fetches ALL topics to build the master pool. 
  /// Since we are reading single documents per topic, this is efficient (e.g. 5 reads for 5 topics).
  Future<void> init() async {
    if (_masterPool.isNotEmpty) return; // Already loaded

    _isLoading = true;
    notifyListeners();

    try {
      _questionsByTopic = {};
      _masterPool = [];

      // Fetch all topics in parallel
      await Future.wait(_topics.map((topic) => _loadSingleTopic(topic)));

      refreshRandomQuestions();
    } catch (e) {
      debugPrint('Error loading questions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSingleTopic(QuestionTopic topic) async {
    try {
      final docSnap = await _db.collection('questions').doc(topic.id).get();
      if (docSnap.exists) {
        final data = docSnap.data();
        if (data != null && data.containsKey('questions')) {
          final qMap = data['questions'] as Map<String, dynamic>;
          
          // Convert map to list of objects
          final qList = qMap.entries
              .map((e) => Question.fromMapEntry(e.key, e.value))
              .toList();

          // Store in state
          _questionsByTopic[topic.id] = qList;
          _masterPool.addAll(qList);
        }
      }
    } catch (e) {
      debugPrint('Failed to load topic ${topic.title}: $e');
    }
  }

  /// Picks 3 random questions from the Master Pool (all topics combined)
  void refreshRandomQuestions() {
    if (_masterPool.isEmpty) {
      _randomDisplay = [];
    } else {
      final random = Random();
      final List<Question> temp = List.from(_masterPool);
      temp.shuffle(random);
      final count = min(3, temp.length);
      _randomDisplay = temp.take(count).toList();
    }
    notifyListeners();
  }

  /// Get questions specific to a topic ID
  List<Question> getQuestionsForTopic(String topicId) {
    return _questionsByTopic[topicId] ?? [];
  }

  // --- ANSWER HANDLING (Standard CRUD) ---
  
  Stream<List<QuestionAnswer>> getAnswersStream(String questionId) {
    return _db.collection('users').doc(_userId)
        .collection('question_answers').doc(questionId).collection('answers')
        .orderBy('date', descending: true).snapshots()
        .map((s) => s.docs.map((d) => QuestionAnswer.fromFirestore(d)).toList());
  }

  Future<void> saveAnswer({required String questionId, required String text, required DateTime date, String? existingId}) async {
    final ref = _db.collection('users').doc(_userId)
        .collection('question_answers').doc(questionId).collection('answers');
        
    final data = {
      'text': text, 
      'date': Timestamp.fromDate(date), 
      'updatedAt': FieldValue.serverTimestamp()
    };

    if (existingId != null) {
      await ref.doc(existingId).update(data);
    } else {
      await ref.add(data);
    }
  }

  Future<void> deleteAnswer(String questionId, String answerId) async {
    await _db.collection('users').doc(_userId)
        .collection('question_answers').doc(questionId)
        .collection('answers').doc(answerId).delete();
  }
}