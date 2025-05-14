import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class JournalRecentsList extends StatefulWidget {
  const JournalRecentsList({super.key});

  @override
  JournalRecentsListState createState() => JournalRecentsListState();
}

class JournalRecentsListState extends State<JournalRecentsList> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _journalEntries = [];

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  // Fetch journal entries from Firestore
  Future<void> _loadJournalEntries() async {
    try {
      final entries =
          Provider.of<DBProvider>(context, listen: false).journalEntries;
      // print('getting entries from dbprovider...');
      setState(() {
        _journalEntries = entries.values.toList();
      });
    } catch (e) {
      // print('Error fetching journal entries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Journal Entries'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _journalEntries.isEmpty
            ? const Center(child: Text('No recent entries found.'))
            : ListView.builder(
                itemCount: _journalEntries.length,
                itemBuilder: (context, index) {
                  final entry = _journalEntries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry['entry'] ?? 'No Entry',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Location: ${entry['location']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          // Display activities
                          entry['activities'].isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Activities:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ...entry['activities']
                                        .map<Widget>((activity) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: Text(
                                          '${activity['name']}: ${activity['description']}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(height: 8),
                          // Display images
                          entry['imgUrls'].isNotEmpty
                              ? SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: entry['imgUrls'].length,
                                    itemBuilder: (context, imgIndex) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            "${entry['imgUrls'][imgIndex]}?cache_bust=${DateTime.now().millisecondsSinceEpoch}",
                                            fit: BoxFit.cover,
                                            width: 150,
                                            height: 150,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
