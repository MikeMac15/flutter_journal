import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/pages/questionWalls/questions/model/question_models.dart';
import 'package:journal/pages/questionWalls/questions/provider/question_provider.dart';
import 'package:provider/provider.dart';

class QuestionDetailPage extends StatefulWidget {
  final Question question;

  const QuestionDetailPage({super.key, required this.question});

  @override
  State<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  // If we are editing, we store the ID here.
  String? _editingAnswerId;
  final TextEditingController _editController = TextEditingController();

  void _showEditDialog(QuestionAnswer answer) {
    _editController.text = answer.text;
    _editingAnswerId = answer.id;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Answer"),
        content: TextField(
          controller: _editController,
          maxLines: 5,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () async {
              await context.read<QuestionsProvider>().saveAnswer(
                questionId: widget.question.id,
                text: _editController.text.trim(),
                date: answer.date, // Keep original date
                existingId: _editingAnswerId,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAnswer(String answerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Answer'),
        content: const Text('Are you sure you want to delete this memory?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context
          .read<QuestionsProvider>()
          .deleteAnswer(widget.question.id, answerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Memory Lane")),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              widget.question.text,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const Divider(height: 1),

          // History List
          Expanded(
            child: StreamBuilder<List<QuestionAnswer>>(
              stream: context
                  .read<QuestionsProvider>()
                  .getAnswersStream(widget.question.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final answers = snapshot.data ?? [];

                if (answers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history_edu, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text(
                          "No history found.\nCheck back after you've saved an answer!",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: answers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final answer = answers[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat.yMMMd().add_jm().format(answer.date),
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12),
                                ),
                                PopupMenuButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.more_horiz),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                        value: 'edit', child: Text('Edit')),
                                    const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete',
                                            style: TextStyle(color: Colors.red))),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'edit') _showEditDialog(answer);
                                    if (value == 'delete') _deleteAnswer(answer.id);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              answer.text,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}