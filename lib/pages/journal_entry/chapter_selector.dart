import 'package:flutter/material.dart';

import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class ChapterSelector extends StatefulWidget {
  final Function(String? chapterId, String? chapterName) onChapterSelected; // Callback to notify the parent

  const ChapterSelector({super.key, required this.onChapterSelected});

  @override
  State<ChapterSelector> createState() => _ChapterSelectorState();
}

class _ChapterSelectorState extends State<ChapterSelector> {
  List<Map<String, String>> _chapterNames = [];
  String? _selectedChapterId;
  String? _selectedChapterName;

  @override
  void initState() {
    super.initState();
    _loadChapterNames();
  }

  Future<void> _loadChapterNames() async {
    try {
      final chapters = Provider.of<DBProvider>(context, listen: false).chapters;
      setState(() {
        if (chapters.isNotEmpty) {
          _chapterNames = chapters.entries.map((entry) {
            return {
              'id': entry.value['id'] as String,
              'name': entry.value['name'] as String,
            };
          }).toList();
        }
      });
    } catch (e) {
      // print('Error fetching chapters: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _chapterNames.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: _selectedChapterId,
                    hint: const Text('Choose a chapter (optional)'),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedChapterId = newValue;
                        _selectedChapterName = _chapterNames
                            .firstWhere((chapter) => chapter['id'] == newValue)['name'];
                      });
                      // Notify parent widget (JournalEntryPage) about the selected chapter
                      widget.onChapterSelected(_selectedChapterId, _selectedChapterName);
                    },
                    items: _chapterNames.map((chapter) {
                      return DropdownMenuItem<String>(
                        value: chapter['id'],
                        child: Text(chapter['name'] ?? 'No Name'),
                      );
                    }).toList(),
                  ),
                ],
              ),
      ],
    );
  }
}
