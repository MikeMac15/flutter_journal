import 'package:flutter/material.dart';
import 'package:journal/pages/home/fav_chapters.dart';
import 'package:journal/pages/home/past_posts.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
 @override
Widget build(BuildContext context) {
  final dbProvider = Provider.of<DBProvider>(context, listen: true);
  final journalEntries = dbProvider.getSortedJournalListForThisMonth();

  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (journalEntries.isEmpty)
          PastPosts(
            journalEntries: dbProvider.getMostRecent5Entries(),
            recent: true,
          )
        else
          PastPosts(journalEntries: journalEntries),
        const SizedBox(height: 16),

        // Chapters Section
        Text(
          'Chapters',
          style: Theme.of(context).textTheme.titleLarge,
        ),
       

        // Use ConstrainedBox only if you want to cap height
      FavChapters(),
        
      ],
    ),
  );
}
}
