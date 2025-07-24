import 'package:flutter/material.dart';
import 'package:journal/features/questionWalls/YIR_Classes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:journal/providers/db_provider.dart';

class YirRecapWall extends StatefulWidget {
  final String year;
  final List<YirRecap> yirRecaps;

  const YirRecapWall({super.key, required this.year, required this.yirRecaps});

  @override
  State<YirRecapWall> createState() => _YirRecapWallState();
}

class _YirRecapWallState extends State<YirRecapWall> {
  bool _isEditing = false;
  bool _isAdding = false;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dbProvider = context.read<DBProvider>();
    final sortedRecaps = [...widget.yirRecaps]
      ..sort((a, b) => a.date.compareTo(b.date)); 

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: sortedRecaps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final recap = sortedRecaps[index];
              final formattedDate = _formatDate(recap.date);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            recap.recapText,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        if (_isEditing)
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                await dbProvider.deleteRecap(widget.year, index);
                                setState(() {});
                              } else if (value == 'edit') {
                                _textController.text = recap.recapText;
                                await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Edit Recap'),
                                    content: TextField(
                                      controller: _textController,
                                      autofocus: true,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await dbProvider.updateRecap(
                                            widget.year,
                                            index,
                                            YirRecap(
                                              date: recap.date,
                                              recapText: _textController.text.trim(),
                                            ),
                                          );
                                          Navigator.pop(context);
                                          setState(() {});
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          )
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (_isAdding)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Write a recap...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = _textController.text.trim();
                    if (text.isNotEmpty) {
                      final recap = YirRecap(
                        date: DateTime.now().toIso8601String(),
                        recapText: text,
                      );
                      await dbProvider.addRecap(widget.year, recap);
                      _textController.clear();
                      setState(() => _isAdding = false);
                    }
                  },
                )
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _isAdding = true),
              icon: const Icon(Icons.add_comment),
              label: const Text('Add Recap'),
            ),
          ),
      ],
    );
  }

  String _formatDate(String isoOrSimpleDate) {
    try {
      final date = DateTime.parse(isoOrSimpleDate);
      return DateFormat.yMMMMd().format(date);
    } catch (_) {
      return isoOrSimpleDate;
    }
  }
}
