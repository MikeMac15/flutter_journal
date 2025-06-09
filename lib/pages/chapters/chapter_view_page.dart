// lib/pages/chapters/chapter_detail_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/pages/journal_view_page.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

/// This page shows one chapter’s details (name, description, image) and
/// then a list of all the JournalEntry objects whose IDs are in that chapter.
class ChapterDetailPage extends StatelessWidget {
  /// We expect to receive the chapterId from ChaptersPage when the user taps it.
  final String chapterId;

  const ChapterDetailPage({super.key, required this.chapterId});

  @override
  Widget build(BuildContext context) {
    // Grab the provider so we can look up chapter data and entries.
    final db = Provider.of<DBProvider>(context);
    // Fetch the raw chapter map from DBProvider. It has keys: 'name', 'description',
    // 'image', 'entryIDs' (a List<String>), etc.
    final chapterData = db.getChapterById(chapterId);

    // If for some reason the chapterId is invalid, show an error.
    if (chapterData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chapter Not Found')),
        body: const Center(child: Text('Could not find that chapter.')),
      );
    }

    // Extract fields from the chapterData map
    final String chapterName = chapterData['name'] as String;
    final String chapterDescription = chapterData['description'] as String;
    final String? chapterImageUrl =
        (chapterData['image'] as String?)?.isNotEmpty == true
            ? (chapterData['image'] as String)
            : null;
    // entryIDs is a List<String> of journal entry document IDs.
    final List<String> entryIds =
        List<String>.from(chapterData['entryIDs'] as List<dynamic>);

    // Now, gather the JournalEntry objects for those IDs. DBProvider stores
    // everything in-memory already, so this is just a lookup.
    final List<JournalEntry> entriesForChapter = entryIds
        .map((id) => db.getJournalEntryById(id))
        .whereType<JournalEntry>()
        .toList();

    // If you want the list sorted by date (newest first):
    entriesForChapter.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(
        title: Text(chapterName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ---- Chapter Image (if present) ----
            if (chapterImageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  chapterImageUrl,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  loadingBuilder: (ctx, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (ctx, error, stack) => SizedBox(
                    height: 200,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ---- Chapter Name & Description ----
            Text(
              chapterName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              chapterDescription.isNotEmpty
                  ? chapterDescription
                  : 'No description provided.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // ---- Section Header: Entries List ----
            Text(
              'Entries in this Chapter',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            // ---- If there are no entries, show a placeholder ----
            if (entriesForChapter.isEmpty) ...[
              Center(
                child: Text(
                  'No entries linked to this chapter yet.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ] else ...[
              // ---- Otherwise, show a vertical list of each entry ----
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: entriesForChapter.length,
                separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) {
                  final entry = entriesForChapter[idx];

                  // For brevity, show just date + first few characters of the text.
                  final String formattedDate =
                      DateFormat.yMMMd().format(entry.date);
                  final String snippet = entry.entry.length > 80
                      ? '${entry.entry.substring(0, 80)}…'
                      : entry.entry;

                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        // When tapped, navigate to JournalEntryViewPage with a fade
                        Navigator.of(context).push(
                          fadeRoute(
                            JournalEntryViewPage(entryId: entry.id),
                            duration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date and maybe location?
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDate,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                if (entry.location.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        entry.location,
                                        style:
                                            Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Snippet of the entry text
                            Text(
                              snippet,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            // If there are photos, show a tiny thumbnail row (optional)
                            if (entry.imgUrls.isNotEmpty) ...[
                              SizedBox(
                                height: 60,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: entry.imgUrls.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (ctx2, idx2) {
                                    final imageUrl = entry.imgUrls[idx2];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.broken_image),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
