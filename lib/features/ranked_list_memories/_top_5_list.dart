import 'package:flutter/material.dart';

class TopFiveListView extends StatefulWidget {
  final List<String> topFive;
  const TopFiveListView({super.key, required this.topFive});
  @override
  State<TopFiveListView> createState() => _TopFiveListViewState();
}

class _TopFiveListViewState extends State<TopFiveListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.topFive.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(widget.topFive[index]),
          leading: const Icon(Icons.star),
        );
      },
    );
  }
}