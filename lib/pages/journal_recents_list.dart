import 'package:flutter/material.dart';
import 'package:journal/features/cards/_journal_vertical_card_pager.dart';
import 'package:journal/features/grid/_recents_grid_view.dart';

import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class JournalRecentsList extends StatefulWidget {
  const JournalRecentsList({super.key});

  @override
  JournalRecentsListState createState() => JournalRecentsListState();
}

class JournalRecentsListState extends State<JournalRecentsList> {
  List<JournalEntry> _journalEntries = [];
  bool _showGrid = false; // ← track which view to show

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final entries =
          Provider.of<DBProvider>(context, listen: false).journalEntriesSorted;
      setState(() => _journalEntries = entries);
    } catch (e) {
      // handle error...
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const baseWidth = 375.0;
    final scale = (screenWidth / baseWidth).clamp(0.8, 1.4);
    final horizontalPadding = 16.0 * scale;
    final verticalPadding = 12.0 * scale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recent Journal Entries',
          style: TextStyle(fontSize: 20.0 * scale),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Column(
          children: [
            // ─── Toggle Switch Row ───────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Grid View', style: TextStyle(fontSize: 14 * scale)),
                SizedBox(width: 8 * scale),
                Switch(
                  value: _showGrid,
                  onChanged: (val) => setState(() => _showGrid = val),
                ),
              ],
            ),

            // ─── Content ──────────────────────────────────────────
            Expanded(
              child: _journalEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No recent entries found.',
                        style: TextStyle(fontSize: 16.0 * scale),
                      ),
                    )
                  : _showGrid
                      // your custom grid widget (pass entries + scale)
                      ? RecentsGridView(
                          entries: _journalEntries,
                          scale: scale,
                        )
                      // the existing vertical pager
                      : JournalVerticalPager(),
            ),
          ],
        ),
      ),
    );
  }
}