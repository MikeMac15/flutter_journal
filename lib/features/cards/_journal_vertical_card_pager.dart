// lib/pages/journal_vertical_pager.dart

import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/cards/_recent_post_card.dart';
import 'package:journal/pages/journal_view_page.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

class JournalVerticalPager extends StatefulWidget {
  const JournalVerticalPager({super.key});

  @override
  _JournalVerticalPagerState createState() => _JournalVerticalPagerState();
}

class _JournalVerticalPagerState extends State<JournalVerticalPager> {
  List<JournalEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries =
        Provider.of<DBProvider>(context, listen: false).journalEntriesSorted;
    setState(() => _entries = entries);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const baseWidth = 375.0;
    final scale = (screenWidth / baseWidth).clamp(0.8, 1.4);

    // use truly empty titles
    final titles = List<String>.filled(_entries.length, '');

    final cards = _entries.map((entry) {
      return JournalPostCard(
        entry: entry,
        scale: scale,
        onViewFull: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JournalEntryViewPage(
                entryId: entry.id,
              ),
            ),
          );
        },
      );
    }).toList();

    return SafeArea(
        child: _entries.isEmpty
            ? const Center(child: CircularProgressIndicator())
            // no Center() here so pager can expand
            : SizedBox.expand(
                child: VerticalCardPager(
                  titles: titles,
                  images: cards,
                  // fontSize 0 is fine, but empty titles means no text
                  textStyle: TextStyle(fontSize: 0),
                  align: ALIGN.CENTER,
                  onPageChanged: (_) {},
                  onSelectedItem: (index) {
                    Navigator.of(context).push(
                      fadeRoute(JournalEntryViewPage(
                          entryId: _entries[index].id
                      )),
                    );
                  },
                ),
              ),
      );
  }
}
