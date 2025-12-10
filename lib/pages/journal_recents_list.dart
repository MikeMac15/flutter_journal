import 'package:flutter/material.dart';
import 'package:journal/features/calendar/_calendar_card.dart';
import 'package:journal/features/cards/_journal_vertical_card_pager.dart';
import 'package:journal/features/grid/_recents_grid_view.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

// Enum to manage the different view types
enum JournalView { classic, verticalPager, grid, calendar }

class JournalRecentsList extends StatefulWidget {
  const JournalRecentsList({super.key});

  @override
  JournalRecentsListState createState() => JournalRecentsListState();
}

class JournalRecentsListState extends State<JournalRecentsList> {
  // State is now managed by the enum, defaulting to classic view
  JournalView _selectedView = JournalView.verticalPager;

  Widget _buildViewSwitcher() {
    return DropdownButton<JournalView>(
      value: _selectedView,
      menuWidth: 140,
      icon: const Icon(Icons.more_vert), // Changed icon for a more common look
      underline: Container(), // Hides the default underline
      onChanged: (JournalView? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedView = newValue;
          });
        }
      },
      // This builder is used for the selected item display (when dropdown is closed)
      selectedItemBuilder: (BuildContext context) {
        return JournalView.values.map<Widget>((JournalView item) {
          // Return just the icon for the selected item
          return _selectedView == JournalView.classic
              ? const Icon(Icons.view_list)
              : _selectedView == JournalView.verticalPager
                  ? const Icon(Icons.view_carousel)
                  : _selectedView == JournalView.calendar
                      ? const Icon(Icons.calendar_today)
                      : _selectedView == JournalView.grid
                          ? const Icon(Icons.grid_view)
                          : const Icon(Icons.view_list);
        }).toList();
      },
      // This builder is used for the dropdown items (when dropdown is open)
      items: const [
        DropdownMenuItem(
          value: JournalView.classic,
          child: Row(children: [
            Icon(Icons.view_list),
            SizedBox(width: 8),
            // FIX: Wrap Text with Flexible to prevent overflow
            Flexible(child: Text('Classic'))
          ]),
        ),
        DropdownMenuItem(
          value: JournalView.verticalPager,
          child: Row(children: [
            Icon(Icons.view_carousel),
            SizedBox(width: 8),
            // FIX: Wrap Text with Flexible to prevent overflow
            Flexible(child: Text('Pager'))
          ]),
        ),
        DropdownMenuItem(
          value: JournalView.grid,
          child: Row(children: [
            Icon(Icons.grid_view),
            SizedBox(width: 8),
            // FIX: Wrap Text with Flexible to prevent overflow
            Flexible(child: Text('Grid')),
          ]),
        ),
        DropdownMenuItem(
          value: JournalView.calendar,
          child: Row(children: [
            Icon(Icons.calendar_today),
            SizedBox(width: 8),
            // FIX: Wrap Text with Flexible to prevent overflow
            Flexible(child: Text('Calendar'))
          ]),
        ),
      ],
    );
  }

  // Helper method to build the currently selected view
  Widget _buildSelectedView(List<JournalEntry> entries, double scale) {
    switch (_selectedView) {
      case JournalView.grid:
        return RecentsGridView(entries: entries, scale: scale);
      case JournalView.verticalPager:
        return JournalVerticalPager(entries: entries);
      case JournalView.calendar:
        return Expanded(child: CalendarCard(),);
      case JournalView.classic:
        // Placeholder for the "Classic" view. You can replace this with your desired widget.
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            // Assuming JournalEntry has a 'title' and 'content' property for this example
            final entry = entries[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(entry.date.toString()),
                subtitle: Text(
                  entry.entry ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // This widget will listen for changes in DBProvider and rebuild automatically.
    final dbProvider = Provider.of<DBProvider>(context);
    final journalEntries = dbProvider.journalEntriesSorted;

    // Styling based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    const baseWidth = 375.0;
    final scale = (screenWidth / baseWidth).clamp(0.8, 1.4);
    final horizontalPadding = 16.0 * scale;

    return Scaffold(
      floatingActionButton: _buildViewSwitcher(),
      body:  Column(
          children: [
            // Now Expanded is a direct child of Column, which is correct
            Expanded(
              child: journalEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No recent entries found.',
                        style: TextStyle(fontSize: 16.0 * scale),
                      ),
                    )
                  // Use the helper method to build the view
                  : _buildSelectedView(journalEntries, scale),
            ),
          ],
        ),
     
    );
  }
}
