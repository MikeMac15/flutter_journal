import 'package:flutter/material.dart';
import 'package:journal/pages/home/chapters_card.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class FavChapters extends StatefulWidget {
  const FavChapters({super.key});

  @override
  State<FavChapters> createState() => _FavChaptersState();
}

class _FavChaptersState extends State<FavChapters> {
  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DBProvider>(context, listen: true);
    final chap = dbProvider.chapters;
    final List<Chapter> chapters = chap.entries.map((entry) => entry.value).toList();
     
    if (chapters.isEmpty) {
      return const Center(
        child: Text('No favorite chapters yet.'),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return ChaptersCard(
      title: chapter.name,
      description: chapter.description,
      imageUrl: chapter.image,
    );
  },
    );
  }
}
