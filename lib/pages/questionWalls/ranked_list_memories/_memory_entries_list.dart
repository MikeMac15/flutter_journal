import 'package:flutter/material.dart';
import 'package:journal/providers/db_provider.dart';


/// A list widget that groups journal entries by year,
/// based on a list of Firestore document IDs and a lookup map.
class MemoryEntriesList extends StatelessWidget {
  /// List of journal entry Firestore IDs, sorted by date descending.
  final List<String> entryIds;

  /// Map of Firestore ID to actual [JournalEntry] object.
  final Map<String, JournalEntry> entryMap;

  /// Callback when a user taps on an entry.
  final void Function(JournalEntry entry)? onTap;

  const MemoryEntriesList({
    super.key,
    required this.entryIds,
    required this.entryMap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (entryIds.isEmpty) {
      return const Center(child: Text('No journal entries.'));
    }

    final List<Widget> children = [];
    int? currentYear;

    for (final id in entryIds) {
      final JournalEntry? entry = entryMap[id];
      if (entry == null) continue; // skip missing entries

      final year = entry.date.year;
      if (currentYear != year) {
        // Year header
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              year.toString(),
              
            ),
          ),
        );
        currentYear = year;
      }

      // Entry tile
      children.add(
        ListTile(
          title: Text(
            entry.entry ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${entry.date.month}/${entry.date.day}/${entry.date.year}',
          ),
          onTap: onTap != null ? () => onTap!(entry) : null,
        ),
      );
      children.add(const Divider(height: 1));
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: children,
    );
  }
}
