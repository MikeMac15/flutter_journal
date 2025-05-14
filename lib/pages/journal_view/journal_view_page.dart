import 'package:flutter/material.dart';
import 'package:journal/features/pictures/view_chosen_images.dart';
import 'package:journal/pages/journal_entry/activity_list.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';
// import 'package:journal/pages/journal_entry/view_chosen_images.dart';

class JournalEntryViewPage extends StatefulWidget {
  final String entryId;  // Firestore document ID passed from the previous page

  const JournalEntryViewPage({super.key, required this.entryId});

  @override
  JournalEntryViewPageState createState() => JournalEntryViewPageState();
}

class JournalEntryViewPageState extends State<JournalEntryViewPage> {
  late String _entry;
  late String _location;
  late List<String> _imgUrls;
  late List<Map<String, dynamic>> _activities;
  late DateTime _entryDate; // Initialize _entryDate with DateTime

  @override
  void initState() {
    super.initState();
    _loadEntryData();
  }

  // Fetch the journal entry data from DBProvider using the entry ID
  void _loadEntryData() {
    final entryData = Provider.of<DBProvider>(context, listen: false)
        .getJournalEntryById(widget.entryId);

    if (entryData != null && entryData.isNotEmpty) {
      setState(() {
        _entry = entryData['entry'] ?? '';
        _location = entryData['location'] ?? '';
        _imgUrls = List<String>.from(entryData['imgUrls'] ?? []);
        _activities = List<Map<String, dynamic>>.from(entryData['activities'] ?? []);
        // Correct date parsing: Ensure it's a DateTime object
        _entryDate = (entryData['date'] is DateTime)
            ? entryData['date']
            : DateTime.parse(entryData['date'].toString());
      });

      // print(_imgUrls);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entry'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the entry date
              Text(
                'Date: ${_entryDate.toLocal().toString().split(' ')[0]}', // Formatting DateTime correctly
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Display the location
              const Text(
                'Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(_location, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),

              // Display the main journal entry
              const Text(
                'Journal Entry',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                _entry,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Display activities if they exist
              const Text(
                'Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _activities.isNotEmpty
                  ? ActivityList(savedActivities: _activities)
                  : const Text('No activities for this entry'),

              const SizedBox(height: 20),

              // Display images from Firestore
              const Text(
                'Images',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              _imgUrls.isNotEmpty
                  ? ViewChosenImages(chosenPhotoPaths: _imgUrls)
                  : const Text('No images for this entry'),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
