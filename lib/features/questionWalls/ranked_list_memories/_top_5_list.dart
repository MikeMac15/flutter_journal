import 'package:flutter/material.dart';

class TopFiveListView extends StatefulWidget {
  final List<String> topFive;
  const TopFiveListView({super.key, required this.topFive});

  @override
  State<TopFiveListView> createState() => _TopFiveListViewState();
}

class _TopFiveListViewState extends State<TopFiveListView> {
  late List<String> topFiveItems;

  @override
  void initState() {
    super.initState();
    topFiveItems = List.from(widget.topFive); // Create a modifiable copy
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = topFiveItems.removeAt(oldIndex);
          topFiveItems.insert(newIndex, item);
        });
      },
      children: [
        for (int i = 0; i < topFiveItems.length; i++)
          ListTile(
            key: ValueKey('top5-$i'),
            leading: CircleAvatar(
              radius: 14,
              child: Text('${i + 1}'),
            ),
            title: Text(topFiveItems[i]),
            trailing: const Icon(Icons.drag_handle),
          ),
      ],
    );
  }
}
