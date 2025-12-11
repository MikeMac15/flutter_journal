import 'dart:math';

import 'package:flutter/material.dart';
import 'package:journal/features/calendar/_calendar_card.dart';
import 'package:journal/pages/home/fav_chapters.dart';
import 'package:journal/pages/home/past_posts.dart';
import 'package:journal/pages/questions_home.dart';
import 'package:journal/pages/questionWalls/questions/model/question_models.dart';
import 'package:journal/pages/questionWalls/questions/provider/question_provider.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // Ensure questions are loaded when Home initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionsProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DBProvider>(context, listen: true);
    final journalEntries = dbProvider.getSortedJournalListForThisMonth();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (journalEntries.isEmpty)
            PastPosts(
              journalEntries: dbProvider.getMostRecent5Entries(),
              recent: true,
            )
          else
            PastPosts(journalEntries: journalEntries),
          
          // const SizedBox(height: 10),
          
          // --- Updated Random Question Card ---
          const RandomQuestionCard(),
          
          const SizedBox(height: 10),
          
          CalendarCard(),
          
          // Chapters Section
          Text(
            'Chapters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          
          FavChapters(),
        ],
      ),
    );
  }
}

class RandomQuestionCard extends StatefulWidget {
  const RandomQuestionCard({super.key});

  @override
  State<RandomQuestionCard> createState() => _RandomQuestionCardState();
}

class _RandomQuestionCardState extends State<RandomQuestionCard> {
  Question? _currentQuestion;
  bool _isAnswering = false;
  bool _isSaving = false;
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  /// Picks a random question from ALL available topics in the provider
  void _pickRandomQuestion(QuestionsProvider provider) {
    // 1. Flatten all questions from all topics into one list
    final allQuestions = provider.topics
        .expand((topic) => provider.getQuestionsForTopic(topic.id))
        .toList();

    if (allQuestions.isEmpty) return;

    setState(() {
      _currentQuestion = allQuestions[Random().nextInt(allQuestions.length)];
      _isAnswering = false; // Reset answering state when shuffling
      _answerController.clear();
    });
  }

  Future<void> _saveAnswer() async {
    if (_answerController.text.trim().isEmpty) return;
    if (_currentQuestion == null) return;

    setState(() => _isSaving = true);

    try {
      await context.read<QuestionsProvider>().saveAnswer(
            questionId: _currentQuestion!.id,
            text: _answerController.text.trim(),
            date: DateTime.now(),
          );
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reflection saved!')),
      );

      setState(() {
        _isAnswering = false;
        _answerController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<QuestionsProvider>();

    // Initial load logic if we don't have a question yet
    if (_currentQuestion == null && !provider.isLoading) {
      // Use a microtask to avoid setState during build
      Future.microtask(() => _pickRandomQuestion(provider));
    }

    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Header Row ---
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    color: Colors.amber.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Reflection",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  onPressed: () => _pickRandomQuestion(provider),
                  tooltip: 'Shuffle Question',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Question Text ---
            if (provider.isLoading && _currentQuestion == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_currentQuestion != null)
              Text(
                _currentQuestion!.text,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  fontSize: 18,
                ),
              )
            else
              const Text("No questions loaded."),

            const SizedBox(height: 20),

            // --- Action Area (Buttons or Text Field) ---
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isAnswering
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _answerController,
                          minLines: 3,
                          maxLines: 5,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "Write your thoughts...",
                            filled: true,
                            fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isAnswering = false;
                                  _answerController.clear();
                                });
                              },
                              child: const Text("Cancel"),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: _isSaving ? null : _saveAnswer,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send, size: 16),
                              label: Text(_isSaving ? "Saving" : "Save"),
                            ),
                          ],
                        )
                      ],
                    )
                  : Row(
                      children: [
                        // "Answer" Button
                        FilledButton.icon(
                          onPressed: () {
                            setState(() {
                              _isAnswering = true;
                            });
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Answer"),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                        ),
                        const Spacer(),
                        // "More Questions" Button
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const QuestionsHome()), // Updated navigation target
                            );
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("More Questions"),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios, size: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}