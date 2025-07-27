import 'package:flutter/material.dart';
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
            body: Column(children: [

              Expanded(child: YirRecapWall(year: yir.year, yirRecaps: yir.recaps)), // Display the recap wall
              const SizedBox(height: 16),
              Expanded(child: YirRankedLists(yir: yir)),
              
            ]));
      },
    );
  }
}
