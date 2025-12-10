import 'package:flutter/material.dart';
import 'package:journal/features/menu_buttons/image_button.dart';
import 'package:journal/pages/questionWalls/ranked_list_memories/ranked_list_class.dart';

/// A reusable widget that displays a list of [RankedListClass]s.
///
/// All of the ranked lists are passed in via [rankedLists]. When the user
/// taps on an item, [onTap] is called with the tapped list.
class RankedListsList extends StatelessWidget {
  final List<RankedListClass> rankedLists;
  final void Function(RankedListClass rankedList)? onTap;

  const RankedListsList({
    super.key,
    required this.rankedLists,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (rankedLists.isEmpty) {
      return const Center(
        child: Text(
          'No ranked lists yet.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,                           // let the list size itself to its children
      physics: const AlwaysScrollableScrollPhysics(), // allow scrolling but avoid unbounded errors
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rankedLists.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final rl = rankedLists[index];
        if (rl.title == 'Concerts'){
          return LargeImageButton(
            title: rl.title,
            onPressed: onTap != null ? () => onTap!(rl) : () {},
            backgroundImage: const AssetImage('assets/images/questions/concert1.png'),
          );
        }
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          elevation: 2,
          child: ListTile(
            title: Text(rl.title),
            
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap != null ? () => onTap!(rl) : null,
          ),
        );
      },
    );
  }
}
