import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/pages/chapters/chapter_view_page.dart';
import 'package:journal/pages/chapters/create_chapter_page.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class ChaptersPage extends StatefulWidget {
  const ChaptersPage({super.key});

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {

  @override
  void initState() {
    super.initState();
  }

  // Fetch chapters from Firestore asynchronously
  Future<List<Map<String, dynamic>>> _loadChapters() async {
    try {
      final chapters = Provider.of<DBProvider>(context, listen: false).chapters;
      return chapters.values.toList();
    } catch (e) {
      // print('Error fetching chapters: $e');
      return [];
    }
  }

  void navToCreateChapterPage() {
    // Navigate to the page where the user can create a new chapter
    Navigator.of(context).push(fadeRoute(CreateChapterPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chapters'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadChapters(), // Fetch the chapters asynchronously
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator()); // Show loading indicator while waiting for data
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final chapters = snapshot.data!;

            return Column(
              children: [
                GestureDetector(
                  onTap: navToCreateChapterPage, // Corrected this
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: Colors.blue,
                    child: const Text(
                      "Create new chapter",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = chapters[index];
                      return GestureDetector(
  onTap: () {
    Navigator.of(context).push(
      fadeRoute(
        ChapterDetailPage(chapterId: chapter['id']),
        duration: const Duration(milliseconds: 500),
      ),
    );
  },
  child: Card(
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chapter['name'] ?? 'No Name',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            chapter['description'] ?? 'No Description',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (chapter['image'] != null && (chapter['image'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  chapter['image'] as String,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
