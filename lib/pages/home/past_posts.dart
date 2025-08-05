import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:gap/gap.dart';
import 'package:journal/pages/journal_view_page.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:journal/theme/other.dart';

class PastPosts extends StatefulWidget {
  const PastPosts(
      {super.key, this.journalEntries = const [], this.recent = false});

  final List<JournalEntry> journalEntries;
  final bool? recent;

  @override
  State<PastPosts> createState() => _PastPostsState();
}

class _PastPostsState extends State<PastPosts> {
  final CarouselController controller = CarouselController(initialItem: 1);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Past Posts from ${monthNames[DateTime.now().month]}',
            style: theme.textTheme.titleLarge?.copyWith(
                // fontWeight: FontWeight.bold,
                ),
          ),
        ),
        
        ConstrainedBox(constraints: BoxConstraints(
          maxHeight: 250,
          minHeight: 200, 

        ),
        child: 
        CarouselView.weighted(
            controller: controller,
            itemSnapping: true,
            flexWeights: const <int>[1, 7, 1],
            onTap: (value) => Navigator.push(
              context,
              fadeRoute(
                JournalEntryViewPage(
                  entryId: widget.journalEntries[value].id,
                ),
              ),
            ),
            children: widget.journalEntries.map((JournalEntry entry) {
              return HeroLayoutCard(entry: entry);
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class HeroLayoutCard extends StatelessWidget {
  const HeroLayoutCard({super.key, required this.entry});

  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: <Widget>[
        ClipRect(
          child: OverflowBox(
            maxWidth: width * 7 / 8,
            minWidth: width * 7 / 8,
            // maxHeight: double.infinity,
            // minHeight: 500,
            child:  Image(
                height: double.infinity,
                width: double.infinity,
                fit: BoxFit.cover,
                image: NetworkImage(entry.imgUrls.first),
              ),
            
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                DateFormat.yMMMMd().format(entry.date),
                overflow: TextOverflow.clip,
                softWrap: false,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: Colors.white),
              ),
              const Gap(10),
              Text(
                entry.location,
                overflow: TextOverflow.clip,
                softWrap: false,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const Gap(10),
              Text(
                entry.entry,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
