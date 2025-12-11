import 'package:flutter/material.dart';
import 'package:journal/pages/questionWalls/questions/model/question_models.dart';
import 'package:journal/pages/questionWalls/questions/provider/question_provider.dart';
import 'package:provider/provider.dart';
import 'package:journal/features/_fade_route.dart';
import 'question_detail_page.dart';

class RandomQuestionsPage extends StatefulWidget {
  const RandomQuestionsPage({super.key});

  @override
  State<RandomQuestionsPage> createState() => _RandomQuestionsPageState();
}

class _RandomQuestionsPageState extends State<RandomQuestionsPage> {
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
    final provider = context.watch<QuestionsProvider>();

    if (provider.isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Title fades out when a question is selected to save space
                  AnimatedCrossFade(
                    firstChild: const Padding(
                      padding: EdgeInsets.only(bottom: 24.0),
                      child: Text(
                        "Here are 3 questions for you:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                    crossFadeState: _selectedQuestionId == null 
                        ? CrossFadeState.showFirst 
                        : CrossFadeState.showSecond,
                    duration: const Duration(milliseconds: 300),
                  ),

                  if (provider.randomDisplay.isEmpty)
                    const Text("No questions loaded."),
                  
                  ...provider.randomDisplay.map((question) {
                    return _buildQuestionCard(context, question);
                  }),

                  const SizedBox(height: 24),

                  // Shuffle button hides when a question is selected
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _selectedQuestionId == null ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: _selectedQuestionId != null,
                      child: FilledButton.icon(
                        onPressed: provider.refreshRandomQuestions,
                        icon: const Icon(Icons.shuffle),
                        label: const Text("Shuffle Questions"),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
  }

  Widget _buildQuestionCard(BuildContext context, Question question) {
  final isSelected = _selectedQuestionId == question.id;
  final isAnySelected = _selectedQuestionId != null;
  final isDimmed = isAnySelected && !isSelected;

  return AnimatedOpacity(
    duration: const Duration(milliseconds: 350),
    curve: Curves.easeInOut,
    opacity: isDimmed ? 0.0 : 1.0,
    child: AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isDimmed
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                scale: isSelected ? 1.03 : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                            ],
                          )
                        ,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .inverseSurface
                              .withAlpha(15),
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
                          child: 
                              // Question text
                            Column(
                              children: [
                                //Button to close when expanded
                                if (isSelected)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 20,
                                      color: const Color.fromARGB(103, 255, 82, 82),
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
                            )
                        ),
                      ),

                      // === EXPANDED ANSWER AREA ===
                      AnimatedSize(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: isSelected
                            ? Padding(
                                padding:
                                    const EdgeInsets.only(top: 16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextField(
                                      controller: _answerController,
                                      minLines: 4,
                                      maxLines: 6,
                                      autofocus: true,
                                      
                                      decoration: InputDecoration(
                                        hintText:
                                            "Write your answer here...",
                                        hintStyle: TextStyle(
                                          
                                        ),
                                        filled: true,
                                        fillColor: Theme.of(context).colorScheme.inverseSurface
                                            .withAlpha(8),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide.none,
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                          child: StreamBuilder<
                                              List<QuestionAnswer>>(
                                            stream: context
                                                .read<
                                                    QuestionsProvider>()
                                                .getAnswersStream(
                                                    question.id),
                                            builder:
                                                (context, snapshot) {
                                              final count =
                                                  snapshot.data?.length ??
                                                      0;
                                              if (count == 0) {
                                                return const SizedBox
                                                    .shrink();
                                              }
                                              return TextButton.icon(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .push(
                                                    fadeRoute(
                                                      QuestionDetailPage(
                                                        question:
                                                            question,
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
                                              : () => _saveAnswer(
                                                  question.id),
                                          icon: _isSaving
                                              ? const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.send_rounded,
                                                ),
                                          label: Text(_isSaving
                                              ? "Saving..."
                                              : "Save"),
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
    ),
  );
}
}