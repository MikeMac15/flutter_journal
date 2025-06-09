import 'package:flutter/material.dart';
import 'package:journal/features/calendar/_calendar_journal_list_view.dart';
import 'package:journal/pages/journal_entry_page.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarCard extends StatefulWidget {
  const CalendarCard({super.key});

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (_focusedDay == focusedDay){
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JournalEntryPage(selectedDate: focusedDay),
            ),
          );
    }
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    // existing navigation logic
    // final String? entryId = _hasJournalEntry(selectedDay);
    // if (entryId != null) {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (_) => JournalEntryViewPage(entryId: entryId),
    //     ),
    //   );
    // } else {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //       builder: (_) => JournalEntryPage(selectedDate: selectedDay),
    //     ),
    //   );
    // }
  }

  // Pseudo stubs for coloring logic
  bool _isToday(DateTime day) => false; // TODO
  bool _isFavorite(DateTime day) => false; // TODO

  bool _hasPastEntry(DateTime day){
    return _hasJournalEntry(day) != null;
  } 
  bool _hasMultipleEntries(DateTime day) => false; // TODO

  String? _hasJournalEntry(DateTime day) {
    final dp = Provider.of<DBProvider>(context, listen: false);
    final sel = DateTime(day.year, day.month, day.day);
    for (var e in dp.journalEntryDates) {
      final d = e['date'] as DateTime;
      if (d.year == sel.year && d.month == sel.month && d.day == sel.day) {
        return e['id'] as String?;
      }
    }
    return null;
  }

  // TODO: implement this to return actual entries
  List<JournalEntry> _getEntriesForDay(DateTime day) {
    
    final dbProvider = Provider.of<DBProvider>(context, listen: false);
    return dbProvider.getJournalEntriesForDay(day);
  }

  Widget _buildEntryList(ThemeData theme) {
    if (_selectedDay == null) return const SizedBox.shrink();
    final entries = _getEntriesForDay(_selectedDay!);
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('No entries for selected date', style: theme.textTheme.bodyMedium),
      );
    }
    final sortedEntries = List<JournalEntry>.from(entries)
      ..sort((a, b) => b.date.compareTo(a.date));
    return CalendarJournalListView(entries: sortedEntries);
  }

  Widget _buildKey(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          _keyItem(theme.colorScheme.secondary, 'Today'),
          _keyItem(Colors.amber, 'Favorited'),
          _keyItem(Colors.green, 'Past Entry'),
          _keyItem(Colors.purple, 'Multiple Entries'),
        ],
      ),
    );
  }

  Widget _keyItem(Color color, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 4),
        Text(label),
      ]);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
              onDaySelected: _onDaySelected,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: theme.textTheme.titleMedium ?? const TextStyle(),
                leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.secondary),
                rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.secondary),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondary,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (ctx, day, focused) {
                  Color? bg;
                  if (_isToday(day)) { bg = theme.colorScheme.primaryContainer; }
                  else if (_isFavorite(day)) { bg = Colors.amber.withAlpha((0.3 * 255).toInt()); }
                  else if (_hasMultipleEntries(day)) { bg = Colors.purple.withAlpha((0.3 * 255).toInt()); }
                  else if (_hasPastEntry(day)) { bg = Colors.grey.shade400; }
                  return Container(
                    margin: const EdgeInsets.all(6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(day.day.toString(), style: theme.textTheme.bodyMedium),
                  );
                },
              ),
            ),
            // widget listing entries under calendar
            _buildEntryList(theme),
            // legend key
            _buildKey(theme),
          ],
        ),
      ),
    );
  }
}
