import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/pages/questions_home.dart';
import 'package:journal/pages/home.dart';
import 'package:journal/pages/journal_entry_page.dart';
import 'package:journal/pages/journal_recents_list.dart';
import 'package:journal/pages/settings.dart';
import 'package:journal/providers/user_provider.dart';
import 'package:provider/provider.dart';

class MyPage {
  const MyPage({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.component,
  });
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget component;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Placeholder data for the SliverAppBar
  final String firstName = 'User';
  final String? headerUrl =
      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?q=80&w=2070&auto=format&fit=crop';
  final String defaultHeaderUrl =
      'https://images.unsplash.com/photo-1470252649378-9c29740c9fa8?q=80&w=2070&auto=format&fit=crop';

  // Placeholder pages for each tab
  final List<MyPage> _pages = [
    MyPage(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      component: Home(),
    ),
    MyPage(
      icon: Icons.cloud_outlined,
      selectedIcon: Icons.cloud,
      label: 'Memories',
      component: QuestionsHome(),
    ),
    MyPage(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'Journal',
      component: JournalRecentsList()
    ),
    MyPage(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      component: SettingsPage(),
    ),
  ];

  // Helper method for the bottom navigation bar items
  dynamic _buildTabItem(
      {required bool top, required MyPage page, required int index}) {
    if (top) {
      return NavigationRailDestination(
          icon: Icon(page.icon),
          selectedIcon: Icon(page.selectedIcon),
          label: Text(page.label));
    } else {
      return Expanded(
        child: SizedBox(
          height: 60.0,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => setState(() => _selectedIndex = index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _selectedIndex == index
                      ? Icon(page.selectedIcon,
                          color: Colors.indigo, size: 28.0)
                      : Icon(page.icon,
                          color: _selectedIndex == index
                              ? Colors.indigo
                              : Colors.grey.shade700,
                          size: 28.0),
                  const SizedBox(height: 2.0),
                  Text(page.label,
                      style: TextStyle(
                          color: _selectedIndex == index
                              ? Colors.indigo
                              : Colors.grey.shade700,
                          fontSize: 12.0)),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final userProv = context.watch<UserProvider>();
    // We don't strictly need the headerUrl anymore if we aren't doing the image background
    // final headerUrl = userProv.headerImageUrl; 

    final firstName = userProv.userDisplayName != null
        ? '${userProv.userDisplayName!.split(' ').first}\'s'
        : 'My';

    return LayoutBuilder(
      builder: (context, constraints) {
        // ----------------------------------------------------------
        // WIDE SCREEN / TABLET VIEW (Unchanged)
        // ----------------------------------------------------------
        if (constraints.maxWidth > 600) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Responsive Navigation'),
            ),
            floatingActionButton: FloatingActionButton.large(
              onPressed: () {
                Navigator.of(context).push(
                  fadeRoute(
                    JournalEntryPage(),
                  ),
                );
              },
              backgroundColor: Colors.indigo,
              shape: const CircleBorder(),
              elevation: 10.0,
              child: const Icon(Icons.add, color: Colors.white, size: 32.0),
            ),
            body: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: <NavigationRailDestination>[
                    _buildTabItem(top: true, page: _pages[0], index: 0),
                    _buildTabItem(top: true, page: _pages[1], index: 1),
                    _buildTabItem(top: true, page: _pages[2], index: 2),
                    _buildTabItem(top: true, page: _pages[3], index: 3),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: _pages[_selectedIndex].component,
                ),
              ],
            ),
          );
        }
        // ----------------------------------------------------------
        // MOBILE / NARROW VIEW (Updated)
        // ----------------------------------------------------------
        else {
          return Scaffold(
            // NEW: Regular AppBar added here
            appBar: AppBar(
              backgroundColor: theme.primaryColor,
              // Ensures the back arrow/menu icons are white
              iconTheme: const IconThemeData(color: Colors.white), 
              centerTitle: true,
              title: Text(
                '$firstName Journal',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            
            // NEW: Simplified Body (No more CustomScrollView/Slivers)
            body: _pages[_selectedIndex].component,

            // Floating Action Bar logic
            floatingActionButton: _selectedIndex == 0
                ? FloatingActionButton.large(
                    onPressed: () {
                      Navigator.of(context).push(
                        fadeRoute(
                          JournalEntryPage(),
                        ),
                      );
                    },
                    backgroundColor: Colors.indigo,
                    shape: const CircleBorder(),
                    elevation: 10.0,
                    child:
                        const Icon(Icons.add, color: Colors.white, size: 28.0),
                  )
                : FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        fadeRoute(
                          JournalEntryPage(),
                        ),
                      );
                    },
                    backgroundColor: Colors.indigo,
                    shape: const CircleBorder(),
                    elevation: 10.0,
                    child:
                        const Icon(Icons.add, color: Colors.white, size: 28.0),
                  ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            
            // Bottom Navigation Bar
            bottomNavigationBar: BottomAppBar(
              shape: const CircularNotchedRectangle(),
              child: SizedBox(
                width: double.infinity,
                height: 60.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _buildTabItem(top: false, page: _pages[0], index: 0),
                          _buildTabItem(top: false, page: _pages[1], index: 1),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const SizedBox(width: 10),
                          _buildTabItem(top: false, page: _pages[2], index: 2),
                          _buildTabItem(top: false, page: _pages[3], index: 3),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }}