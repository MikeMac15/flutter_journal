import 'package:flutter/material.dart';
import 'package:journal/features/questionWalls/YIR_Classes.dart';
import 'package:journal/features/questionWalls/yir/yir_ranked_lists.dart';
import 'package:journal/features/questionWalls/yir/yir_recap_wall.dart';
import 'package:provider/provider.dart';
import 'package:journal/providers/db_provider.dart';

class YirDetailPage extends StatefulWidget {
  final String year;

  const YirDetailPage({super.key, required this.year});

  @override
  State<YirDetailPage> createState() => _YirDetailPageState();
}

class _YirDetailPageState extends State<YirDetailPage> {
  

  @override
  Widget build(BuildContext context) {
    // final themeProv = context.watch<ThemeProvider>();

    return Consumer<DBProvider>(
      builder: (context, dbProvider, _) {
        final yir = dbProvider.allYir.firstWhere((y) => y.year == widget.year);

        return Scaffold(
            appBar: AppBar(title: Text(yir.year)),
            floatingActionButton: 
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.extended(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Add Message'),
                      content: TextField(
                        controller: TextEditingController(),
                        decoration: const InputDecoration(hintText: 'Enter your message'),
                        // expands: true,

                        maxLines: 8,
                        minLines: 1,),
                      actions: [
                         IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = context.read<TextEditingController>().text.trim();
                    if (text.isNotEmpty) {
                      final recap = YirRecap(
                        date: DateTime.now().toIso8601String(),
                        recapText: text,
                      );
                      await dbProvider.addRecap(widget.year, recap);
                      context.read<TextEditingController>().clear();
                      Navigator.of(context).pop();
                    }
                  },
                )
                      ],
                    ),
                  ),
                  backgroundColor: Colors.indigo,
                  // shape: const CircleBorder(),
                  elevation: 10.0,
                  icon: const Icon(Icons.add, color: Colors.white, size: 32.0),
                  label: const Text('Add Message', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),

                FloatingActionButton.extended(
                  onPressed: () => print("FAB Pressed!"),
                  backgroundColor: Colors.indigo,
                  // shape: const CircleBorder(),
                  elevation: 10.0,
                  icon: const Icon(Icons.add, color: Colors.white, size: 32.0),
                  label: const Text('Add Memory', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            // FloatingActionButton.large(
            //   onPressed: () => print("FAB Pressed!"),
            //   backgroundColor: Colors.indigo,
            //   shape: const CircleBorder(),
            //   elevation: 10.0,
            //   child: const Icon(Icons.add, color: Colors.white, size: 32.0),
            // ),
            body: Column(children: [

              Expanded(child: YirRecapWall(year: yir.year, yirRecaps: yir.recaps)), // Display the recap wall
              const SizedBox(height: 16),
              Expanded(child: YirRankedLists(yir: yir)),
              
            ]));
      },
    );
  }
}
