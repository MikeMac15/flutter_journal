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
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 250,
            minHeight: 200,
          ),
          child: CarouselView.weighted(
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
            children: widget.journalEntries
                .map((entry) =>
                    HeroLayoutCard(key: ValueKey(entry.id), entry: entry))
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _EntryImage extends StatelessWidget {
  const _EntryImage({this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Image.asset(
        'assets/images/noPhotoPlaceholder.png',
        fit: BoxFit.cover,
        color: Colors.black54,
        colorBlendMode: BlendMode.darken,
      );
    }

    return Image.network(
      url!,
      fit: BoxFit.cover,
      gaplessPlayback: true, // keep old frame when rebuilt
      // Downscale for memory/caching efficiency (approx target size)
      // On mobile/desktop only; on web this is ignored.
      // cacheWidth: (MediaQuery.sizeOf(context).width * 0.875).toInt(),
      // cacheHeight: 250,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child; // first frame ready
        return Image.asset(
          'assets/images/noPhotoPlaceholder.png',
          fit: BoxFit.cover,
        );
      },
    );
  }
}

class HeroLayoutCard extends StatefulWidget {
  const HeroLayoutCard({super.key, required this.entry});
  final JournalEntry entry;

  @override
  State<HeroLayoutCard> createState() => _HeroLayoutCardState();
}

class _HeroLayoutCardState extends State<HeroLayoutCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // <- IMPORTANT
    final entry = widget.entry;
    final double width = MediaQuery.sizeOf(context).width;

    return Stack(
      alignment: AlignmentDirectional.bottomStart,
      children: [
        ClipRect(
          child: SizedBox(
            width: width * 7 / 8,
            height: 250, // give it a real height to avoid relayout churn
            child: _EntryImage(
                url: entry.imgUrls.isNotEmpty ? entry.imgUrls.first : null),
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
                entry.location ?? '',
                overflow: TextOverflow.clip,
                softWrap: false,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const Gap(10),
              Text(
                entry.entry ?? '',
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
