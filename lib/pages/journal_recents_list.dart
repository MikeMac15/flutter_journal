// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:journal/features/cards/_recent_post_card.dart';
// import 'package:journal/providers/db_provider.dart';
// import 'package:provider/provider.dart';

// class JournalRecentsList extends StatefulWidget {
//   const JournalRecentsList({Key? key}) : super(key: key);

//   @override
//   JournalRecentsListState createState() => JournalRecentsListState();
// }

// class JournalRecentsListState extends State<JournalRecentsList> {
//   final String? userId = FirebaseAuth.instance.currentUser?.uid;
//   List<Map<String, dynamic>> _journalEntries = [];

//   @override
//   void initState() {
//     super.initState();
//     _loadJournalEntries();
//   }

//   Future<void> _loadJournalEntries() async {
//     try {
//       final entries =
//           Provider.of<DBProvider>(context, listen: false).journalEntries;
//       setState(() => _journalEntries = entries.values.toList());
//     } catch (e) {
//       // handle error...
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     const baseWidth = 375.0;
//     final scale = (screenWidth / baseWidth).clamp(0.8, 1.4);
//     final horizontalPadding = 16.0 * scale;
//     final verticalPadding = 12.0 * scale;
//     final crossAxisCount = screenWidth > 600 ? 2 : 1;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Recent Journal Entries',
//           style: TextStyle(fontSize: 20.0 * scale),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: horizontalPadding,
//           vertical: verticalPadding,
//         ),
//         child: _journalEntries.isEmpty
//             ? Center(
//                 child: Text(
//                   'No recent entries found.',
//                   style: TextStyle(fontSize: 16.0 * scale),
//                 ),
//               )
//             : GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: crossAxisCount,
//                   crossAxisSpacing: 16 * scale,
//                   mainAxisSpacing: 16 * scale,
//                   childAspectRatio: 0.85,
//                 ),
//                 itemCount: _journalEntries.length,
//                 itemBuilder: (context, index) {
//                   final entry = _journalEntries[index];
//                   return JournalPostCard(
//                     entry: entry,
//                     scale: scale,
//                     onViewFull: () {
//                       // TODO: navigate to detail page, passing `entry`
//                     },
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }




// lib/pages/journal_recents_list.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journal/features/cards/_journal_vertical_card_pager.dart';
import 'package:vertical_card_pager/vertical_card_pager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:journal/features/cards/_recent_post_card.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class JournalRecentsList extends StatefulWidget {
  const JournalRecentsList({Key? key}) : super(key: key);

  @override
  JournalRecentsListState createState() => JournalRecentsListState();
}

class JournalRecentsListState extends State<JournalRecentsList> {
  final String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> _journalEntries = [];

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    try {
      final entries =
          Provider.of<DBProvider>(context, listen: false).journalEntries;
      setState(() => _journalEntries = entries.values.toList());
    } catch (e) {
      // handle error...
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const baseWidth = 375.0;
    final scale = (screenWidth / baseWidth).clamp(0.8, 1.4);
    final horizontalPadding = 16.0 * scale;
    final verticalPadding = 12.0 * scale;

    // Prepare titles (dates) and cards
    final titles = _journalEntries.map((entry) {
      final DateTime date = (entry['date'] is DateTime)
          ? entry['date']
          : (entry['date'] as Timestamp).toDate();
      return DateFormat.yMMMd().format(date);
    }).toList();

    final cards = _journalEntries.map((entry) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 12 * scale,
          horizontal: horizontalPadding,
        ),
        child: JournalPostCard(
          entry: entry,
          scale: scale,
          onViewFull: () {
            // TODO: navigate to detail page, passing `entry`
          },
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Recent Journal Entries',
          style: TextStyle(fontSize: 20.0 * scale),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: _journalEntries.isEmpty
            ? Center(
                child: Text(
                  'No recent entries found.',
                  style: TextStyle(fontSize: 16.0 * scale),
                ),
              )
            : JournalVerticalPager()
      ),
    );
  }
}
