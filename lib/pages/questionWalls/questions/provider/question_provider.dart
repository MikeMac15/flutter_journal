import 'dart:async';
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
  Map<String, List<Question>> _questionsByTopic = {};
  List<Question> _masterPool = [];
  List<Question> _randomDisplay = [];
  bool _isLoading = false;

  // --- DEMO MODE STATE ---
  bool _isDemo = false;
  // Local storage for answers in Demo Mode: {'question_id': [Answer1, Answer2]}
  final Map<String, List<QuestionAnswer>> _demoAnswers = {};

  // --- GETTERS ---
  List<QuestionTopic> get topics => _topics;
  List<Question> get randomDisplay => _randomDisplay;
  bool get isLoading => _isLoading;
  bool get isDemo => _isDemo;

  String get _userId {
    if (_isDemo) return 'demo_user_id';
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.uid;
  }

  // --- ACTIONS ---

  /// ENABLE DEMO MODE
  /// Call this from LoginPage when "Recruiter Demo" is clicked.
  void enableDemoMode() {
    _isDemo = true;
    _questionsByTopic.clear();
    _masterPool.clear();
    _demoAnswers.clear();
    // We don't notify listeners yet, init() will handle the rest.
  }

Future<void> init() async {
    if (_masterPool.isNotEmpty) return; // Already loaded

    // If we are NOT in demo mode AND there is no logged-in user, STOP.
    final user = FirebaseAuth.instance.currentUser;
    if (!_isDemo && user == null) {
      return; 
    }
    // --------------------------

    _isLoading = true;
    notifyListeners();

    try {
      if (_isDemo) {
        await _initDemoData();
      } else {
        await _initFirestoreData();
      }
      refreshRandomQuestions();
    } catch (e) {
      debugPrint('Error loading questions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Picks 3 random questions from the Master Pool
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

  List<Question> getQuestionsForTopic(String topicId) {
    return _questionsByTopic[topicId] ?? [];
  }

  // ===========================================================================
  // FIRESTORE LOGIC (REAL)
  // ===========================================================================

  Future<void> _initFirestoreData() async {
    _questionsByTopic = {};
    _masterPool = [];
    await Future.wait(_topics.map((topic) => _loadSingleTopicFirestore(topic)));
  }

  Future<void> _loadSingleTopicFirestore(QuestionTopic topic) async {
    try {
      final docSnap = await _db.collection('questions').doc(topic.id).get();
      if (docSnap.exists) {
        final data = docSnap.data();
        if (data != null && data.containsKey('questions')) {
          final qMap = data['questions'] as Map<String, dynamic>;
          final qList = qMap.entries
              .map((e) => Question.fromMapEntry(e.key, e.value))
              .toList();
          _questionsByTopic[topic.id] = qList;
          _masterPool.addAll(qList);
        }
      }
    } catch (e) {
      debugPrint('Failed to load topic ${topic.title}: $e');
    }
  }

  Stream<List<QuestionAnswer>> getAnswersStream(String questionId) {
    if (_isDemo) {
      // Return a simulated stream from local memory
      final answers = _demoAnswers[questionId] ?? [];
      // Sort by date descending
      answers.sort((a, b) => b.date.compareTo(a.date));
      return Stream.value(answers);
    }

    // Real Firestore Stream
    return _db.collection('users').doc(_userId)
        .collection('question_answers').doc(questionId).collection('answers')
        .orderBy('date', descending: true).snapshots()
        .map((s) => s.docs.map((d) => QuestionAnswer.fromFirestore(d)).toList());
  }

  Future<void> saveAnswer({required String questionId, required String text, required DateTime date, String? existingId}) async {
    if (_isDemo) {
      await _saveDemoAnswer(questionId, text, date, existingId);
      return;
    }

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
    if (_isDemo) {
      if (_demoAnswers.containsKey(questionId)) {
        _demoAnswers[questionId]!.removeWhere((a) => a.id == answerId);
        notifyListeners();
      }
      return;
    }

    await _db.collection('users').doc(_userId)
        .collection('question_answers').doc(questionId)
        .collection('answers').doc(answerId).delete();
  }

  // ===========================================================================
  // DEMO LOGIC (MOCK)
  // ===========================================================================

  Future<void> _initDemoData() async {
    // Simulate network delay for realism
    await Future.delayed(const Duration(milliseconds: 500));

    _questionsByTopic.clear();
    _masterPool.clear();

    // 1. Seed Questions
    final Map<String, Map<String, String>> rawData = {
      'daily_questions': {
        "d_001": "What made you smile today?",
        "d_002": "What was the most challenging part of your day?",
        "d_003": "Name one thing you are grateful for today.",
        "d_004": "How did you practice self-care today?",
        "d_005": "If you could relive one hour from today, which would it be?",
      },
      'weekly_questions': {
        "w_001": "What was the highlight of your week?",
        "w_002": "What is something you accomplished this week?",
        "w_003": "Rate this week from 1-10 and explain why.",
      },
      'relationships': {
        "r_001": "Who is the first person you want to call with good news?",
        "r_002": "What is your favorite memory with your best friend?",
      },
      'deep_cuts': {
        "dc_001": "If you could change one thing about your past, what would it be?",
        "dc_002": "What is a fear you are proud of overcoming?",
      },
      'fun': {
        "f_001": "If you could have any superpower, what would it be?",
        "f_002": "What would your entrance theme song be?",
      },
      'nostalgia': {
        "n_001": "What was your favorite toy growing up?",
        "n_002": "What is a smell that takes you back to childhood?",
      },
      'travel': {
        "t_001": "What is the most beautiful place you have ever seen?",
        "t_002": "Where is the next place you want to fly to?",
      },
      'career': {
        "c_001": "What was your very first job?",
        "c_002": "What is the best career advice you've received?",
      }
    };

    rawData.forEach((topicId, questionsMap) {
      final qList = questionsMap.entries.map((e) {
        return Question(id: e.key, text: e.value);
      }).toList();
      _questionsByTopic[topicId] = qList;
      _masterPool.addAll(qList);
    });

    // 2. Seed Mock Answers
    _demoAnswers['d_001'] = [
      QuestionAnswer(
        id: 'mock_1',
        text: 'I saw a really cute dog on my walk to the coffee shop.',
        date: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
    ];
     _demoAnswers['d_003'] = [
      QuestionAnswer(
        id: 'mock_2',
        text: 'Grateful for the sunny weather and good coffee.',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Future<void> _saveDemoAnswer(String questionId, String text, DateTime date, String? existingId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    final answers = _demoAnswers[questionId] ?? [];

    if (existingId != null) {
      final index = answers.indexWhere((a) => a.id == existingId);
      if (index != -1) {
        answers[index] = QuestionAnswer(
          id: existingId,
          text: text,
          date: answers[index].date,
          updatedAt: DateTime.now(),
        );
      }
    } else {
      answers.add(QuestionAnswer(
        id: 'mock_ans_${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        date: date,
        updatedAt: DateTime.now(),
      ));
    }
    _demoAnswers[questionId] = answers;
    notifyListeners();
  }
}