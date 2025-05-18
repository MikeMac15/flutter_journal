import 'package:flutter/material.dart';
import 'package:journal/pages/chapters/chapters_page.dart';
import 'package:journal/pages/journal_recents_list.dart';
import 'package:journal/pages/journal_view_page.dart';
// import 'package:journal/pages/menu_buttons/menu_button.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:journal/providers/user_provider.dart';
import 'package:journal/theme/_colors.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'journal_entry_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  @override
  void initState() {
    super.initState();
    
  }



  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    String? entryId = _hasJournalEntry(selectedDay);
    if ( entryId != null){
      // If the selected day has a journal entry, navigate to the journal entry page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => JournalEntryViewPage(entryId: entryId),
        ),
      );
      return;
    } 

    // Navigate to the journal entry page for the selected date
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JournalEntryPage(selectedDate: selectedDay),
      ),
    );
  }


String? _hasJournalEntry(DateTime day) {
  // Check if the day has a journal entry
  for (var entry in Provider.of<DBProvider>(context, listen: false).journalEntryDates) {
    // Ensure both entry['date'] and 'day' are DateTime objects
    DateTime entryDate = entry['date']; // Now it should be a DateTime
    DateTime selectedDay = DateTime(day.year, day.month, day.day); // Only compare the date part

    if (entryDate.year == selectedDay.year && entryDate.month == selectedDay.month && entryDate.day == selectedDay.day) {
      return entry['id'];
    }
  }
  return null;
}



@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Scaffold(
    backgroundColor: theme.colorScheme.background,
    appBar: AppBar(
      elevation: 2,
      backgroundColor: theme.colorScheme.surface,
      title: const Text('Jamies Journal'),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await Provider.of<UserProvider>(context, listen: false).signOut();
          },
        ),
      ],
    ),

    // Use LayoutBuilder so we can see how wide the window is
    body: LayoutBuilder(
      builder: (context, constraints) {
        // Base padding when narrow, and add extra on each side once >900
        const basePad = 24.0;
        final extra = (constraints.maxWidth - 900).clamp(0.0, double.infinity);
        final horizontalPad = basePad + (extra / 2);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPad,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ─── Calendar Card ──────────────────────────────────
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay:  DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                    onDaySelected: _onDaySelected,
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: theme.textTheme.titleMedium ?? const TextStyle(),
                      leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.primary),
                      rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.primary),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primaryContainer,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (ctx, day, focused) {
                        final hasEntry = _hasJournalEntry(day);
                        return Container(
                          margin: const EdgeInsets.all(6),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: hasEntry != null
                              ? theme.colorScheme.primary.withOpacity(0.2)
                              : null,
                            shape: BoxShape.circle,
                          ),
                          child: Text(day.day.toString(),
                              style: theme.textTheme.bodyMedium),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // ─── Responsive, square action buttons ────────────
              
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 900),
    child: LayoutBuilder(builder: (context, inner) {
      const gap = 16.0;
      const count = 3;
      final available = inner.maxWidth - gap * (count - 1);
      final side = available / count;
      final buttons = [
        ['New Entry', Icons.edit, JournalEntryPage(selectedDate: DateTime.now())],
        ['Chapters', Icons.menu_book, ChaptersPage()],
        ['Recents', Icons.library_books, JournalRecentsList()],
      ];

      // If the whole area is narrower than 380px, switch to a column:
      if (inner.maxWidth < 380) {
        return Column(
          children: buttons.map((btn) {
            return Padding(
              padding: const EdgeInsets.only(bottom: gap),
              child: SizedBox(
                width: inner.maxWidth, // full width
                height: side,          // keep square aspect
                child: _buildButton(btn, side, theme),
              ),
            );
          }).toList(),
        );
      }

      // Otherwise, normal row layout:
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: buttons.map((btn) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 100,
              minHeight: 100,
              maxWidth: side,
              maxHeight: side,
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: _buildButton(btn, side, theme),
            ),
          );
        }).toList(),
      );
    }),
  ),
),

            ],
          ),
        );
      },
    ),
  );
}

// Helper to avoid repetition:
Widget _buildButton(List btn, double side, ThemeData theme) {
  return Material(
    elevation: 4,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => btn[2] as Widget),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              menuButtonColors['primary']!,
              menuButtonColors['secondary']!
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(btn[1] as IconData, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              btn[0] as String,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  );
}

}