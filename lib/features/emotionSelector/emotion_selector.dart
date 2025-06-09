import 'package:flutter/material.dart';

/// A widget to let users attach one or more emotions to a journal entry.
/// Displays a professional list of selectable chips representing major emotions.
class EmotionSelector extends StatefulWidget {
  /// List of initially selected emotions
  final List<String> initialSelectedEmotions;

  /// Callback when the selection changes
  final ValueChanged<List<String>> onSelectionChanged;

  /// List of available emotions
  final List<String> emotions;

  const EmotionSelector({
    super.key,
    this.initialSelectedEmotions = const [],
    required this.onSelectionChanged,
    this.emotions = const [
      'Happy',
      'Sad',
      'Angry',
      'Surprised',
      'Anxious',
      'Calm',
      'Excited',
      'Bored',
      'Frustrated',
      'Grateful',
    ],
  });

  @override
  _EmotionSelectorState createState() => _EmotionSelectorState();
}

class _EmotionSelectorState extends State<EmotionSelector> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelectedEmotions.toSet();
  }

  void _onChipTapped(String emotion, bool selected) {
    setState(() {
      if (selected) {
        _selected.add(emotion);
      } else {
        _selected.remove(emotion);
      }
    });
    widget.onSelectionChanged(_selected.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: widget.emotions.map((emotion) {
        final isSelected = _selected.contains(emotion);
        return FilterChip(
          label: Text(
            emotion,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) => _onChipTapped(emotion, selected),
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey.shade200,
          checkmarkColor: Colors.white,
          elevation: 2.0,
          pressElevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        );
      }).toList(),
    );
  }
}

// Example usage:
// EmotionSelector(
//   initialSelectedEmotions: ['Happy'],
//   onSelectionChanged: (selected) {
//     print('Selected emotions: \$selected');
//   },
// ),
