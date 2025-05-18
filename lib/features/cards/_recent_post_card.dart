// lib/features/cards/_recent_post_card.dart

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:journal/features/cards/_journal_card_text_overlay.dart';
// import 'package:intl/intl.dart';

class JournalPostCard extends StatefulWidget {
  final Map<String, dynamic> entry;
  final double scale;
  final VoidCallback onViewFull;

  const JournalPostCard({
    Key? key,
    required this.entry,
    required this.scale,
    required this.onViewFull,
  }) : super(key: key);

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
    final imgUrls = entry['imgUrls'] as List<dynamic>?;
    final imgUrl =
        (imgUrls != null && imgUrls.isNotEmpty) ? imgUrls[0] as String : null;

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
                Image.network(imgUrl, fit: BoxFit.cover)
              else
                Container(color: Colors.grey[300]),

              // 2) fade-in text overlay
              FadeTransition(
                opacity: _fade,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: JournalCardTextOverlay(
                    location: entry['location'] as String,
                    snippet: entry['entry'] as String,
                    date: entry['date'],
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
  

