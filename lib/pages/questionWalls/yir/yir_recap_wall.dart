import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:journal/pages/questionWalls/yir_classes.dart';


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
  int deleteCount = 0;

 

  void _showEditDialog(BuildContext context, YirRecap recap, int index) {
    _textController.text = recap.recapText;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                await context.read<DBProvider>().updateRecap(
                  widget.year,
                  index,
                  YirRecap(
                    date: recap.date,
                    recapText: _textController.text.trim(),
                  ),
                );
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () async {
                if (deleteCount > 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Press delete again ${deleteCount == 2 ?'twice ': ''}to confirm')),
                  );
                  return;
                }
                deleteCount++;
                await context.read<DBProvider>().deleteRecap(widget.year, index);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

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
                      fontStyle: FontStyle.italic
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
                          child: TextButton(
                            onPressed: () {
                              // Show the edit dialog
                              _showEditDialog(context, recap, index);
                            },
                            child: Text(
                              recap.recapText,
                              style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.4, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                     
                    
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
            padding: const EdgeInsets.symmetric(horizontal: 60),
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
