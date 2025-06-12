import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/ranked_list_memories/_all_event_list.dart';
import 'package:journal/features/ranked_list_memories/_top_5_list.dart';
import 'package:journal/features/ranked_list_memories/ranked_list_class.dart';
import 'package:journal/pages/journal_view_page.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class RankedListMemoryWall extends StatefulWidget {
  final RankedListClass rankedList;
  const RankedListMemoryWall({
    super.key,
    required this.rankedList,
  });

  @override
  State<RankedListMemoryWall> createState() => _RankedListMemoryState();
}

class _RankedListMemoryState extends State<RankedListMemoryWall> {
  @override
  Widget build(BuildContext context) {
    final dbProvider = context.watch<DBProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rankedList.title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top 5:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TopFiveListView(
              topFive: widget.rankedList.topFive),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add to Top 5'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                  String text = '';
                  return AlertDialog(
                    title: const Text('Add to Top 5'),
                    content: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      labelText: 'Element name',
                    ),
                    onChanged: (value) {
                      text = value;
                    },
                    ),
                    actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                      if (text.trim().isNotEmpty) {
                        setState(() {
                        widget.rankedList.topFive.add(text.trim());
                        });
                        Navigator.of(context).pop();
                      }
                      },
                      child: const Text('Add'),
                    ),
                    ],
                  );
                  },
                );
              },
            ),
            const Divider(height: 32),
            const Text(
              'Related Memories:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: MemoryEntriesList(
                entryIds: widget.rankedList.relatedMemories,
                entryMap: dbProvider.journalEntries,
                onTap: (entry) {
                  Navigator.of(context).push(
                    fadeRoute(JournalEntryViewPage(entryId: entry.id)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
