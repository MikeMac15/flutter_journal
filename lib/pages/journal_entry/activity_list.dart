import 'package:flutter/material.dart';
class ActivityList extends StatelessWidget {
  final List<Map<String, dynamic>> savedActivities;
  final void Function(int)? onDelete;

  const ActivityList({
    super.key,
    required this.savedActivities,
    this.onDelete,
  });

  String _extractText(dynamic value) {
    if (value is TextEditingController) {
      return value.text;
    } else if (value is String) {
      return value;
    }
    return '';
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  // Max height so it never takes more than 30% of the screen,
  // but will shrink if there are only a couple of entries.
  final maxListHeight = MediaQuery.of(context).size.height * 0.3;

  return ConstrainedBox(
    constraints: BoxConstraints(maxHeight: maxListHeight),
    child: ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: savedActivities.length,
      itemBuilder: (context, index) {
        final entry = savedActivities[index];
        final name = _extractText(entry['name']).trim();
        final description = _extractText(entry['description']).trim();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity name
                Text(
                  name.isNotEmpty ? name : 'Unnamed Activity',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                // Description, if any
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium,
                  ),
                // Delete button aligned right
                if (onDelete != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => onDelete!(index),
                      tooltip: 'Remove this activity',
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}


}
