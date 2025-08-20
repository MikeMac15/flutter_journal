import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JournalCardTextOverlay extends StatelessWidget {
  final DateTime date;
  final String location;
  final String snippet;
  final double scale;
  final VoidCallback onViewFull;

  const JournalCardTextOverlay({
    super.key,
    required this.date,
    required this.location,
    required this.snippet,
    required this.scale,
    required this.onViewFull,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTiny = constraints.maxHeight < 250;

        // Always show date
        final dateWidget = Text(
          DateFormat.yMMMMd().format(date),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black87,
              )
            ],
          ),
        );

        if (isTiny) {
          // If it's too small, just render the date (centered)
          return Container(
            width: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.all(8 * scale),
            color: Colors.black54,
            child: dateWidget,
          );
        }

        // Otherwise render full overlay
        return Container(
          width: double.infinity,
          // color: Colors.black87,
          padding: EdgeInsets.all(12 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dateWidget,
              SizedBox(height: 4 * scale),
              if (location.isNotEmpty) ...[
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
                SizedBox(height: 4 * scale),
              ],
              if (snippet.isNotEmpty)
                Text(
                  snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14 * scale,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black,
                      )
                    ],
                  ),
                ),
              SizedBox(height: 8 * scale),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onViewFull,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white70,
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View Full Entry',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12 * scale,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
