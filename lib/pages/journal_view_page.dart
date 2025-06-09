import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Future<void> _saveEdits(
      String newEntry, String newLocation, DateTime newDate) async {
    // Update Firestore
    final uid = Provider.of<DBProvider>(context, listen: false).userId;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('entries')
        .doc(widget.entryId);

    try {
      await docRef.update({
        'entry': newEntry,
        'location': newLocation,
        'date': newDate.toIso8601String(),
      });

      // Update local state
      setState(() {
        _entry = newEntry;
        _location = newLocation;
        _entryDate = newDate;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxWidth = MediaQuery.of(context).size.width > 600
        ? 600.0
        : MediaQuery.of(context).size.width;
    final imageHeight = MediaQuery.of(context).size.height * 0.25;

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
                  DateFormat.yMMMMd().format(_entryDate),
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
                            _location.isNotEmpty
                                ? _location
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
                        _imgUrls.isNotEmpty
                            ? SizedBox(
                                height: imageHeight,
                                child:
                                    ViewChosenImages(chosenPhotoPaths: _imgUrls),
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

                // ← New “Edit Entry” button ↓
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Entry'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // 1) Pre-fill controllers and date
                    final entryController =
                        TextEditingController(text: _entry);
                    final locationController =
                        TextEditingController(text: _location);
                    DateTime newDate = _entryDate;

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (dialogCtx) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: const Text('Edit Journal Entry'),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ----- Date Picker Row -----
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(
                                          Icons.calendar_today),
                                      title: Text(
                                        DateFormat.yMMMd().format(newDate),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: newDate,
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2100),
                                        );
                                        if (picked != null &&
                                            picked != newDate) {
                                          setState(() {
                                            newDate = picked;
                                          });
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // ----- Entry Text Field -----
                                    TextField(
                                      controller: entryController,
                                      maxLines: null,
                                      decoration: const InputDecoration(
                                        labelText: 'Entry Text',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // ----- Location Text Field -----
                                    TextField(
                                      controller: locationController,
                                      decoration: const InputDecoration(
                                        labelText: 'Location',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogCtx)
                                        .pop(); // Cancel editing
                                  },
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final newEntry =
                                        entryController.text.trim();
                                    final newLocation =
                                        locationController.text.trim();

                                    // Save edits including the date
                                    await _saveEdits(
                                        newEntry, newLocation, newDate);

                                    Navigator.of(dialogCtx)
                                        .pop(); // Close dialog
                                  },
                                  child: const Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
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