import 'package:flutter/material.dart';
import 'package:journal/theme/_colors.dart';

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
    final maxHeight = MediaQuery.of(context).size.height * 0.3;
    return SizedBox(
      height: maxHeight,
      child: ListView.builder(
        itemCount: savedActivities.length,
        itemBuilder: (context, index) {
          final entry = savedActivities[index];
          final name = _extractText(entry['name']) ;
          final description = _extractText(entry['description']);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              child: ListTile(
                tileColor: tileColors['primary'],
                title: Text(
                  name.isNotEmpty ? name : 'No Name',
                  style: const TextStyle(fontSize: 18),
                ),
                subtitle: description.isNotEmpty
                    ? Text(description, style: const TextStyle(fontSize: 12))
                    : null,
                trailing: onDelete != null
                    ? IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDelete!(index),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
