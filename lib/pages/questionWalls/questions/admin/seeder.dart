import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class QuestionSeeder {
  /// Uploads all question categories to the 'app_content' collection.
  /// Run this once to populate your database.
  static Future<void> seedDatabase() async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // Loop through our data and prepare the batch writes
    for (final topic in _allTopics) {
      final docRef = firestore.collection('questions').doc(topic['id'] as String);
      
      batch.set(docRef, {
        'title': topic['title'],
        'description': topic['description'],
        'questions': topic['questions'],
      });
    }

    try {
      await batch.commit();
      debugPrint('✅ SUCCESS: All question topics have been uploaded to Firestore!');
    } catch (e) {
      debugPrint('❌ ERROR: Failed to upload questions: $e');
    }
  }

  // ==============================================================================
  // DATA DEFINITIONS
  // ==============================================================================

  static final List<Map<String, dynamic>> _allTopics = [
    {
      'id': 'daily_questions',
      'title': 'Daily Reflections',
      'description': 'Small checks-ins for every day.',
      'questions': {
        "d_001": "What made you smile today?",
        "d_002": "What was the most challenging part of your day?",
        "d_003": "Name one thing you are grateful for today.",
        "d_004": "How did you practice self-care today?",
        "d_005": "If you could relive one hour from today, which would it be?",
        "d_006": "What is something new you learned today?",
        "d_007": "How was your energy level today?",
        "d_008": "Who is one person that made your day better?",
        "d_009": "What is a song that fits your mood today?",
        "d_010": "What are you looking forward to tomorrow?"
      }
    },
    {
      'id': 'weekly_questions',
      'title': 'Weekly Recap',
      'description': 'Look back at your week.',
      'questions': {
        "w_001": "What was the highlight of your week?",
        "w_002": "What is something you accomplished this week that you are proud of?",
        "w_003": "Rate this week from 1-10 and explain why.",
        "w_004": "What was the biggest lesson you learned this week?",
        "w_005": "What is one thing you want to do differently next week?",
        "w_006": "Did you make time for your hobbies this week?",
        "w_007": "Who did you enjoy connecting with this week?",
        "w_008": "What was the best meal you ate this week?",
        "w_009": "What drained your energy the most this week?",
        "w_010": "Describe this week in three words."
      }
    },
    {
      'id': 'relationships',
      'title': 'Relationships',
      'description': 'Questions about love and friendship.',
      'questions': {
        "r_001": "Who is the first person you want to call with good news?",
        "r_002": "What is your favorite memory with your partner/best friend?",
        "r_003": "What is a quality you admire most in your closest friend?",
        "r_004": "How do you prefer to receive love (words, gifts, acts of service)?",
        "r_005": "Who is someone you miss right now?",
        "r_006": "What is the best relationship advice you have ever received?",
        "r_007": "What is a small act of kindness someone did for you recently?",
        "r_008": "Who has had the biggest positive influence on your life?",
        "r_009": "What is a tradition you have with your family or friends?",
        "r_010": "When did you last feel truly understood by someone?"
      }
    },
    {
      'id': 'deep_cuts',
      'title': 'Deep Cuts',
      'description': 'Thought-provoking questions.',
      'questions': {
        "dc_001": "If you could change one thing about your past, what would it be?",
        "dc_002": "What is a fear you are proud of overcoming?",
        "dc_003": "What does 'success' mean to you personally?",
        "dc_004": "When was the last time you cried, and why?",
        "dc_005": "What is a dream you have let go of?",
        "dc_006": "If you knew you couldn't fail, what would you try?",
        "dc_007": "What do you want to be remembered for?",
        "dc_008": "What is the hardest truth you've had to accept?",
        "dc_009": "In what ways have you changed in the last 5 years?",
        "dc_010": "What is a question you wish someone would ask you?"
      }
    },
    {
      'id': 'fun',
      'title': 'Just for Fun',
      'description': 'Lighter questions to break the ice.',
      'questions': {
        "f_001": "If you could have any superpower, what would it be?",
        "f_002": "What would your entrance theme song be?",
        "f_003": "If you could eat only one food for the rest of your life, what would it be?",
        "f_004": "Which movie universe would you want to live in?",
        "f_005": "If you were an animal, what would you be?",
        "f_006": "What is the weirdest thing you have ever eaten?",
        "f_007": "If you won the lottery today, what is the first thing you would buy?",
        "f_008": "Who would play you in a movie about your life?",
        "f_009": "What is a useless talent you have?",
        "f_010": "If you could teleport anywhere right now, where would you go?"
      }
    },
    {
      'id': 'nostalgia',
      'title': 'Nostalgia',
      'description': 'Blast from the past.',
      'questions': {
        "n_001": "What was your favorite toy growing up?",
        "n_002": "What is a smell that takes you back to childhood?",
        "n_003": "Who was your favorite teacher and why?",
        "n_004": "What was the first album or CD you ever bought?",
        "n_005": "What is a TV show you loved as a kid?",
        "n_006": "Describe your childhood bedroom.",
        "n_007": "What did you want to be when you grew up?",
        "n_008": "What was your favorite family vacation?",
        "n_009": "What is a food you hated as a kid but love now?",
        "n_010": "What is your earliest clear memory?"
      }
    },
    {
      'id': 'travel',
      'title': 'Travel',
      'description': 'Adventures near and far.',
      'questions': {
        "t_001": "What is the most beautiful place you have ever seen?",
        "t_002": "Where is the next place you want to fly to?",
        "t_003": "Do you prefer relaxing beach trips or active city exploration?",
        "t_004": "What is your favorite travel memory?",
        "t_005": "What is the best meal you've had while traveling?",
        "t_006": "Who is your favorite travel companion?",
        "t_007": "What is a city you could see yourself living in?",
        "t_008": "What is the biggest mishap you've had while traveling?",
        "t_009": "What is one item you never travel without?",
        "t_010": "If you could take a road trip anywhere, where would it be?"
      }
    },
    {
      'id': 'career',
      'title': 'Career',
      'description': 'Work life and goals.',
      'questions': {
        "c_001": "What was your very first job?",
        "c_002": "What is the best career advice you've received?",
        "c_003": "Do you prefer working alone or in a team?",
        "c_004": "What is a professional achievement you are proud of?",
        "c_005": "If money wasn't an issue, what job would you do?",
        "c_006": "What is a skill you are currently trying to improve?",
        "c_007": "Who is a mentor or figure you look up to professionally?",
        "c_008": "How do you handle stress at work?",
        "c_009": "What is your favorite part of your current job?",
        "c_010": "Where do you see yourself in your career in 5 years?"
      }
    }
  ];
}