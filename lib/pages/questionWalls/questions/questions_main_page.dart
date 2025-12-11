import 'package:flutter/material.dart';
import 'package:journal/pages/questionWalls/questions/provider/question_provider.dart';
import 'package:journal/pages/questionWalls/questions/random_questions_page.dart';
import 'package:journal/pages/questionWalls/questions/topic_browser_page.dart';
import 'package:provider/provider.dart';

enum QuestionView { dailyMix, topics }

class QuestionsMainPage extends StatefulWidget {
  const QuestionsMainPage({super.key});

  @override
  State<QuestionsMainPage> createState() => _QuestionsMainPageState();
}

class _QuestionsMainPageState extends State<QuestionsMainPage> {
  QuestionView _currentView = QuestionView.dailyMix;

  @override
  void initState() {
    super.initState();
    // Initialize data once at the parent level
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionsProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // Taller app bar to accommodate the button comfortably
        title: SegmentedButton<QuestionView>(
          style: ButtonStyle(
            visualDensity: VisualDensity.comfortable,
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24, vertical: 0)),
          ),
          segments: const [
            ButtonSegment<QuestionView>(
              value: QuestionView.dailyMix,
              label: Text('Daily Mix'),
              icon: Icon(Icons.shuffle),
            ),
            ButtonSegment<QuestionView>(
              value: QuestionView.topics,
              label: Text('Topics'),
              icon: Icon(Icons.library_books),
            ),
          ],
          selected: {_currentView},
          onSelectionChanged: (Set<QuestionView> newSelection) {
            setState(() {
              _currentView = newSelection.first;
            });
          },
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _currentView == QuestionView.dailyMix
            ? const RandomQuestionsPage()
            : const TopicBrowserContent(),
      ),
    );
  }
}