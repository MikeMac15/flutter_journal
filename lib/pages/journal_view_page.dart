import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/features/pictures/view_chosen_images.dart';
import 'package:journal/pages/journal_entry/activity_list.dart';
import 'package:journal/pages/journal_view/entry_editor.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class JournalEntryViewPage extends StatefulWidget {
  final String entryId;

  const JournalEntryViewPage({super.key, required this.entryId});

  @override
  JournalEntryViewPageState createState() => JournalEntryViewPageState();
}

class JournalEntryViewPageState extends State<JournalEntryViewPage> {
    Future<void> _refreshEntryData() async {
      // Trigger a re-fetch of the entry data
      final dbProvider = Provider.of<DBProvider>(context, listen: false);
      await dbProvider.fetchUpdatedEntry(widget.entryId);
    }
  @override
  Widget build(BuildContext context) {

    final entryData = Provider.of<DBProvider>(context, listen: true)
        .getJournalEntryById(widget.entryId);

    final theme = Theme.of(context);
    final maxWidth = MediaQuery.of(context).size.width > 600
        ? 600.0
        : MediaQuery.of(context).size.width;
    final imageHeight = MediaQuery.of(context).size.height * 0.25;

    if (entryData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Journal Entry')),
        body: const Center(child: Text('Entry not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Date
                Text(
                  DateFormat.yMMMMd().format(entryData.date),
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Location Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entryData.location.isNotEmpty
                                ? entryData.location
                                : 'No location set',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Entry Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Journal Entry',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entryData.entry,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Activities Card
                entryData.activities.isEmpty
                    ?  const SizedBox.shrink()
                    : Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activities',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        entryData.activities.isNotEmpty
                            ? ActivityList(
                                savedActivities: entryData.activities)
                            : Text(
                                'No activities for this entry',
                                style: theme.textTheme.bodyMedium,
                              ),
                      ],
                    ),
                  ),
                ),
                // const SizedBox(height: 16),

                // Images Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photos',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        entryData.imgUrls.isNotEmpty
                            ? SizedBox(
                                height: imageHeight,
                                child: ViewChosenImages(
                                    chosenPhotos: entryData.imgUrls),
                              )
                            : Text(
                                'No images for this entry',
                                style: theme.textTheme.bodyMedium,
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Editor for editing the entry
                EntryEditor(
                  entryId: widget.entryId,
                  onEntryUpdated: _refreshEntryData, // Triggers re-fetch after edit
                  entry: entryData.entry,
                  location: entryData.location,
                  entryDate: entryData.date,
                  imgUrls: entryData.imgUrls,
                  activities: entryData.activities,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
