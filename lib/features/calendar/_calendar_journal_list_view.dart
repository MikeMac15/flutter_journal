import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/features/_fade_route.dart';

import 'package:journal/pages/journal_view_page.dart';
import 'package:journal/pages/journal_entry_page.dart';
import 'package:journal/providers/db_provider.dart';

/// Horizontal list widget showing journal entries for a selected date across years,
/// with a "New Entry" button.
class CalendarJournalListView extends StatelessWidget {
  final List<JournalEntry> entries;

  const CalendarJournalListView({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    // Shared month/day header (no year)
    final headerLabel = entries.isNotEmpty
        ? DateFormat.MMMMd().format(entries.first.date)
        : DateFormat.MMMMd().format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Month-Day header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            headerLabel,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        // New Entry button

        const SizedBox(height: 8),
        if (entries.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No journal entries for this date.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final entry = entries[index];
                final yearLabel = entry.date.year.toString();

                return SizedBox(
                  width: 200,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.of(context).push(
                               fadeRoute(JournalEntryViewPage(entryId: entry.id), duration: const Duration(milliseconds: 100)),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image with year overlay
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: entry.imgUrls.isNotEmpty
                                    ? Image.network(
                                        entry.imgUrls.first,
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(12)),
                                        ),
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 32,
                                        ),
                                      ),
                              ),
                              // Year badge
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    yearLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Location row
                                Row(
                                  children: [
                                    Icon(Icons.place,
                                        size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        entry.location,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                // Entry snippet
                                Text(
                                  entry.entry.length > 80
                                      ? '${entry.entry.substring(0, 80)}…'
                                      : entry.entry,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blueGrey.shade300,
                    Colors.pink.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  final dateToUse = entries.isNotEmpty
                      ? entries.first.date
                      : DateTime.now();
                  Navigator.of(context).push(
                    fadeRoute(JournalEntryPage(selectedDate: dateToUse)),
                    );
                  
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(70, 255, 255, 255),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 28, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'New Entry',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
