import 'package:flutter/material.dart';
import 'package:journal/pages/chapters/chapters_page.dart';
import 'package:journal/pages/journal_view/journal_recents_list.dart';
import 'package:journal/pages/journal_view/journal_view_page.dart';
import 'package:journal/pages/menu_buttons/menu_button.dart';
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
    return Scaffold(
      appBar: AppBar(
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
      body: 
      Padding(padding: EdgeInsets.all(20), child: 
      
      Column(
        children:[
        Center(
          child: Column(
            children: [
          
      TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: _onDaySelected,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final hasEntry = _hasJournalEntry(day);
            return Container(
              margin: const EdgeInsets.all(4.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: hasEntry != null ? Colors.blue[100] : null,
                shape: BoxShape.circle,
              ),
              child: Text(day.day.toString()),
            );
          },
        ),
      ),
// Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: 
      SizedBox(
        height: 120, // Adjust the height as needed
        child: 
     ListView(
          scrollDirection: Axis.horizontal, // Horizontal scrolling
          children: [
            MenuButton(
              targetPage: JournalEntryPage(selectedDate: DateTime.now()),
              boxSizeMultipliers: [.25, .1],
              title: "New Entry",
              icon: Icons.edit,
              sizeOfFont: 12,
              textColor: Colors.white,
              color1: menuButtonColors['primary']!,
              color2: menuButtonColors['secondary']!,
            ),
            const SizedBox(width: 20), // Space between buttons
            MenuButton(
              targetPage: ChaptersPage(),
              boxSizeMultipliers: [.25, .1],
              title: "Chapters",
              icon: Icons.menu_book,
              sizeOfFont: 12,
              textColor: Colors.white,
              color1: menuButtonColors['primary']!,
              color2: menuButtonColors['secondary']!,
            ),
            const SizedBox(width: 20), // Space between buttons
            MenuButton(
              targetPage: JournalRecentsList(),
              boxSizeMultipliers: [.25, .1],
              title: "Recents",
              icon: Icons.library_books,
              sizeOfFont: 12,
              textColor: Colors.white,
              color1: menuButtonColors['primary']!,
              color2: menuButtonColors['secondary']!,
            ),
            const SizedBox(width: 20), // Space between buttons
            // MenuButton(
            //   targetPage: JournalRecentsList(),
            //   boxSizeMultipliers: [.25, .1],
            //   title: "Photos",
            //   icon: Icons.photo_library,
            //   sizeOfFont: 12,
            //   textColor: Colors.white,
            //   color1: menuButtonColors['primary']!,
            //   color2: menuButtonColors['secondary']!,
            // ),
          ],
        ),
      )
      // )
        ],
      ),
        
      )
    ],
  ),
    ),
  );
  }
}
