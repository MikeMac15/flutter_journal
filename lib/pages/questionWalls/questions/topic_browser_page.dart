import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/pages/questionWalls/questions/model/question_models.dart';
import 'package:journal/pages/questionWalls/questions/provider/question_provider.dart';
import 'package:journal/pages/questionWalls/questions/question_detail_page.dart';
import 'package:provider/provider.dart';

class TopicBrowserContent extends StatelessWidget {
  const TopicBrowserContent({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuestionsProvider>();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.topics.length,
      itemBuilder: (context, index) {
        final topic = provider.topics[index];
        final questionCount = provider.getQuestionsForTopic(topic.id).length;

        return Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                fadeRoute(TopicQuestionsListPage(topic: topic)),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.folder_open_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (topic.description != null)
                          Text(
                            topic.description!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(
                      '$questionCount',
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A Page that lists all questions in a specific topic
/// Users can answer questions directly inline here.
class TopicQuestionsListPage extends StatefulWidget {
  final QuestionTopic topic;

  const TopicQuestionsListPage({super.key, required this.topic});

  @override
  State<TopicQuestionsListPage> createState() => _TopicQuestionsListPageState();
}

class _TopicQuestionsListPageState extends State<TopicQuestionsListPage> {
  String? _selectedQuestionId; // Tracks which question is expanded
  final TextEditingController _answerController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuestionsProvider>().init();
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _handleQuestionTap(String id) {
    setState(() {
      _selectedQuestionId = (_selectedQuestionId == id) ? null : id;
      _answerController.clear(); // Clear text when switching/closing
    });
  }

  Future<void> _saveAnswer(String questionId) async {
    if (_answerController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      await context.read<QuestionsProvider>().saveAnswer(
            questionId: questionId,
            text: _answerController.text.trim(),
            date: DateTime.now(),
          );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answer saved successfully!')),
      );

      // Optionally close the expansion after saving
      setState(() {
        _selectedQuestionId = null;
        _answerController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    final questions = context.read<QuestionsProvider>().getQuestionsForTopic(widget.topic.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
      ),
      body: questions.isEmpty
          ? const Center(child: Text("No questions loaded."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                return _buildQuestionCard(context, question);
              },
            ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, Question question) {
  final isSelected = _selectedQuestionId == question.id;
  final isAnySelected = _selectedQuestionId != null;
  final isDimmed = isAnySelected && !isSelected;

  return AnimatedOpacity(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeInOut,
    // Still visible, just faded a bit when another is active
    opacity: isDimmed ? 0.35 : 1.0,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        scale: isSelected
            ? 1.03
            : (isDimmed ? 0.97 : 1.0), // tiny shrink for background cards
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.surfaceContainerHighest,
                Theme.of(context).colorScheme.surfaceContainerLowest,
              ],
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .inverseSurface
                      .withAlpha(35),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === QUESTION HEADER (tap to open / close) ===
              InkWell(
                onTap: () => _handleQuestionTap(question.id),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSelected)
                        Align(
                          alignment: Alignment.topRight,
                          child: InkWell(
                            onTap: () => _handleQuestionTap(question.id),
                            borderRadius: BorderRadius.circular(999),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: Color.fromARGB(160, 255, 82, 82),
                            ),
                          ),
                        ),
                      Text(
                        question.text,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: isSelected ? 20 : 16,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // === EXPANDED ANSWER AREA ===
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _answerController,
                              minLines: 4,
                              maxLines: 6,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: "Write your answer here...",
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .inverseSurface
                                    .withAlpha(8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(18),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Past answers button
                                Expanded(
                                  child: StreamBuilder<List<QuestionAnswer>>(
                                    stream: context
                                        .read<QuestionsProvider>()
                                        .getAnswersStream(question.id),
                                    builder: (context, snapshot) {
                                      final count =
                                          snapshot.data?.length ?? 0;
                                      if (count == 0) {
                                        return const SizedBox.shrink();
                                      }
                                      return TextButton.icon(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            fadeRoute(
                                              QuestionDetailPage(
                                                question: question,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.history_rounded,
                                          size: 18,
                                        ),
                                        label: Text(
                                          "$count past answer${count == 1 ? '' : 's'}",
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Save button
                                FilledButton.icon(
                                  onPressed: _isSaving
                                      ? null
                                      : () => _saveAnswer(question.id),
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.send_rounded),
                                  label: Text(
                                    _isSaving ? "Saving..." : "Save",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
