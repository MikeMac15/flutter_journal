import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/ranked_list_memories/_all_lists_view.dart';
import 'package:journal/features/ranked_list_memories/ranked_list_class.dart';
import 'package:journal/features/ranked_list_memories/ranked_list_memory.dart';
import 'package:journal/features/text/text_entry.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class RankedListHome extends StatefulWidget {
  const RankedListHome({super.key});

  @override
  State<RankedListHome> createState() => _RankedListHomeState();
}

class _RankedListHomeState extends State<RankedListHome> {
  final TextEditingController _titleController = TextEditingController();
  String _title = '';

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final dbProvider = context.watch<DBProvider>();
    final List<RankedListClass>  allRankedLists = dbProvider.rankedLists;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranked Lists'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Ranked Lists',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RankedListsList(rankedLists: allRankedLists, onTap: (rankedList) {
              Navigator.of(context).push(
                fadeRoute(RankedListMemoryWall(rankedList: rankedList)),
              );
            }),
            const SizedBox(height: 20),
            TextEntry(
              isMultiLine: false,
              controller: _titleController,
              labelText: 'Enter a title for your ranked list',
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _title.isNotEmpty
                  ? () {
                      final rankedList = RankedListClass(title: _title);
                      dbProvider.addRankedList(rankedList);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RankedListMemoryWall(rankedList: rankedList),
                        ),
                      );
                    }
                  : null,
              child: const Text('Create New Ranked List'),
            ),
          ],
        ),
      ),
    );
  }
}
