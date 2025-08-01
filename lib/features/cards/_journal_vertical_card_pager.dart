// lib/pages/journal_vertical_pager.dart

import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/cards/_recent_post_card.dart';
import 'package:journal/pages/journal_view_page.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';

class JournalVerticalPager extends StatefulWidget {
  const JournalVerticalPager({super.key, required this.entries});

  final List<JournalEntry> entries;

  @override
  JournalVerticalPagerState createState() => JournalVerticalPagerState();
}

class JournalVerticalPagerState extends State<JournalVerticalPager> {
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const baseWidth = 375.0;
    final scale = (screenWidth / baseWidth).clamp(0.8, 1.4);

    // use truly empty titles
    final titles = List<String>.filled(widget.entries.length, '');

    final cards = widget.entries.map((entry) {
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
        child: widget.entries.isEmpty
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
                          entryId: widget.entries[index].id
                      )),
                    );
                  },
                ),
              ),
      );
  }
}
