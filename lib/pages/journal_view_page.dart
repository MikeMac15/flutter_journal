import 'package:flutter/material.dart';
import 'package:journal/features/pictures/view_chosen_images.dart';
import 'package:journal/pages/journal_entry/activity_list.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class JournalEntryViewPage extends StatefulWidget {
  final String entryId;

  const JournalEntryViewPage({super.key, required this.entryId});

  @override
  JournalEntryViewPageState createState() => JournalEntryViewPageState();
}

class JournalEntryViewPageState extends State<JournalEntryViewPage> {
  late String _entry;
  late String _location;
  late List<String> _imgUrls;
  late List<Map<String, dynamic>> _activities;
  late DateTime _entryDate;

  @override
  void initState() {
    super.initState();
    _loadEntryData();
  }

  void _loadEntryData() {
    final entryData = Provider.of<DBProvider>(context, listen: false)
        .getJournalEntryById(widget.entryId);

    if (entryData != null) {
      setState(() {
        _entry = entryData.entry;
        _location = entryData.location;
        _imgUrls = entryData.imgUrls;
        // Safely cast activities to List<Map<String, dynamic>>
        _activities = (entryData.activities as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _entryDate = entryData.date;
      });
    } else {
      setState(() {
        _entry = 'Entry not found';
        _location = '';
        _imgUrls = [];
        _activities = [];
        _entryDate = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final dateString = '${_entryDate.month}/${_entryDate.day}/${_entryDate.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Center content with a max width on wide screens
          final maxWidth = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
          final imageHeight = constraints.maxHeight * 0.25;

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date
                    Text(
                      _entryDate.toString(),
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                                _location.isNotEmpty ? _location : 'No location set',
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
                              'My Thoughts',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _entry,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Activities Card
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
                              'Activities',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _activities.isNotEmpty
                                ? ActivityList(savedActivities: _activities)
                                : Text(
                                    'No activities for this entry',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            _imgUrls.isNotEmpty
                                ? SizedBox(
                                    height: imageHeight,
                                    child: ViewChosenImages(chosenPhotoPaths: _imgUrls),
                                  )
                                : Text(
                                    'No images for this entry',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
