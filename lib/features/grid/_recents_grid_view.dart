// recents_grid_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/pages/journal_view_page.dart';
import 'package:journal/providers/db_provider.dart';

class RecentsGridView extends StatelessWidget {
  final List<JournalEntry> entries;
  final double scale;

  const RecentsGridView({
    super.key,
    required this.entries,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200 * scale,  // max width per card
        mainAxisSpacing: 12 * scale,
        crossAxisSpacing: 12 * scale,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, i) {
        final entry = entries[i];
        final date = entry.date;
        final snippet = entry.entry;
        final location = entry.location as String?;
        final imgUrls = entry.imgUrls.cast<String>();
        
        return Card(
          
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          elevation: 4,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => JournalEntryViewPage(
                    entryId: entry.id,
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imgUrls.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8 * scale),
                        child: Image.network(
                          imgUrls.first,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  SizedBox(height: 8 * scale),
                  Text(
                    DateFormat.yMMMd().format(date),
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (location != null && location.isNotEmpty) ...[
                    SizedBox(height: 4 * scale),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 12 * scale,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  SizedBox(height: 6 * scale),
                  Expanded(
                    child: Text(
                      snippet,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12 * scale, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
