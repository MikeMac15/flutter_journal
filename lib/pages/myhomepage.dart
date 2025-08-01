import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/questionWalls/questions_home.dart';
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
      component: const Center(
          child: Text('Home Page', style: TextStyle(fontSize: 24))),
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
    final headerUrl = userProv.headerImageUrl;

    final firstName = userProv.userDisplayName != null
        ? '${userProv.userDisplayName!.split(' ').first}\'s'
        : 'My';
    // LayoutBuilder rebuilds when constraints change (e.g., window resize)
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use NavigationRail for wider screens
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
                    _buildTabItem(
                      top: true,
                      page: _pages[0],
                      index: 0,
                    ),
                    _buildTabItem(
                      top: true,
                      page: _pages[1],
                      index: 1,
                    ),
                    _buildTabItem(
                      top: true,
                      page: _pages[2],
                      index: 2,
                    ),
                    _buildTabItem(
                      top: true,
                      page: _pages[3],
                      index: 3,
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Main content
                Expanded(
                  child: _pages[_selectedIndex].component,
                ),
              ],
            ),
          );
        }
        // Use BottomNavigationBar and SliverAppBar for narrower screens
        else {
          return Scaffold(
            body: 
            _selectedIndex == 0
            ? CustomScrollView(
              slivers: [
                // The SliverAppBar from your request
                SliverAppBar(
                  pinned: false,
                  elevation: 2,
                  expandedHeight: 250,
                  backgroundColor: theme.primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      '$firstName Journal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          const Shadow(
                            color: Color.fromARGB(255, 0, 0, 0),
                            offset: Offset(1, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          headerUrl ?? defaultHeaderUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.network(defaultHeaderUrl,
                                  fit: BoxFit.cover),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(180, 0, 0, 0),
                                Colors.transparent
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                // The main content of the selected page
                SliverToBoxAdapter(
                  child: Container(
                    // Added a container to better position the content
                    padding: const EdgeInsets.only(top: 20.0),
                    height: MediaQuery.of(context).size.height,
                    child: _pages[_selectedIndex].component,
                  ),
                ),
              ],
            ) : Container(
                    // Added a container to better position the content
                    padding: const EdgeInsets.only(top: 20.0),
                    height: MediaQuery.of(context).size.height,
                    child: _pages[_selectedIndex].component,
                  ),

            // Bottom Navigation Bar
            floatingActionButton: _selectedIndex == 0
            ?
             FloatingActionButton.large(
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
              child: const Icon(Icons.add, color: Colors.white, size: 28.0),
            )
            :
            FloatingActionButton(
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
              child: const Icon(Icons.add, color: Colors.white, size: 28.0),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              
              shape: const CircularNotchedRectangle(),

              // notchMargin: 1.0,
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
  }
}
