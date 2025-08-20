// lib/features/cards/_recent_post_card.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:journal/features/cards/_journal_card_text_overlay.dart';
import 'package:journal/providers/db_provider.dart';
// import 'package:intl/intl.dart';

class JournalPostCard extends StatefulWidget {
  final JournalEntry entry;
  final double scale;
  final VoidCallback onViewFull;

  const JournalPostCard({
    super.key,
    required this.entry,
    required this.scale,
    required this.onViewFull,
  });

  @override
  _JournalPostCardState createState() => _JournalPostCardState();
}

class _JournalPostCardState extends State<JournalPostCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

    // start the fade-in right after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final scale = widget.scale;

    // pull out your date and image URL
    // final DateTime date = (entry['date'] is DateTime)
    //     ? entry['date']
    //     : (entry['date'] as Timestamp).toDate();
    // final formattedDate = DateFormat.yMMMMd().format(date);
    final imgUrls = entry.imgUrls;
    final imgUrl = (imgUrls.isNotEmpty) ? imgUrls[0] : null;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      elevation: 4 * scale,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12 * scale),
        child: LayoutBuilder(builder: (ctx, constraints) {
          // full-card height & width
          // final w = constraints.maxWidth;
          // final h = constraints.maxHeight;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1) background image layer
              if (imgUrl != null)
                // Use FadeInImage for a better UX
                FadeInImage.assetNetwork(
                  placeholder:
                      'assets/images/noPhotoPlaceholder.png', // Or another placeholder
                  image: imgUrl,
                  fit: BoxFit.cover,
                  // Optional: Add an error builder for failed loads
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[300]); // Fallback UI
                  },
                )
              else
                // This is your existing fallback, which is perfect
                Container(color: Colors.grey[300]),

              // 2) fade-in text overlay
              FadeTransition(
                opacity: _fade,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: JournalCardTextOverlay(
                    location: entry.location ?? '',
                    snippet: entry.entry ?? '',
                    date: entry.date,
                    scale: widget.scale,
                    onViewFull: widget.onViewFull,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
