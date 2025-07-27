import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/calendar/_calendar_card.dart';
import 'package:journal/features/menu_buttons/raised_button.dart';
import 'package:journal/features/menu_buttons/top_menu_btn.dart';
import 'package:journal/features/questionWalls/questions_home.dart';
import 'package:journal/pages/chapters/chapters_page.dart';
import 'package:journal/pages/journal_entry_page.dart';
import 'package:journal/pages/journal_recents_list.dart';
import 'package:journal/providers/theme_provider.dart';
import 'package:journal/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProv = context.watch<ThemeProvider>();
    final userProv = context.watch<UserProvider>();
    final headerUrl = userProv.headerImageUrl;

    final firstName = userProv.userDisplayName != null
        ? '${userProv.userDisplayName!.split(' ').first}\'s'
        : 'My';

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          const basePad = 24.0;
          final extra =
              (constraints.maxWidth - 900).clamp(0.0, double.infinity);
          final horizontalPad = basePad + (extra / 2);

          return CustomScrollView(
            slivers: [
              // ─── SliverAppBar ───────────────────────────────────
              SliverAppBar(
                pinned: false,
                elevation: 2,
                expandedHeight: 250,
                backgroundColor: themeProv.backgroundGradientColors[0],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    '$firstName Journal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          offset: const Offset(1, 2),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      headerUrl != null
                          ? Image.network(headerUrl, fit: BoxFit.cover)
                          : Image.asset('assets/images/default_header.png',
                              fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(30, 0, 0, 0),
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
                    child: HomeMenu(avatarSize: 40),
                  ),
                ],
              ),

              // ─── Main Content ───────────────────────────────────
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPad,
                  vertical: 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    CalendarCard(),
                    const SizedBox(height: 24),

                    // ─── Menu Buttons ────────────────────────
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,  
                        children: [
                              RaiseButton(
                                icon: Icons.edit,
                                label: 'New Entry',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    fadeRoute(
                                      JournalEntryPage(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              RaiseButton(
                                icon: Icons.filter_drama,
                                label: 'Memory Wall',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    fadeRoute(
                                      QuestionsHome(),
                                    ),
                                  );
                                },
                              ),
                          const SizedBox(height: 16),    
                              RaiseButton(
                                icon: Icons.photo_library_outlined,
                                label: 'Recent Entries',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    fadeRoute(
                                      JournalRecentsList(),
                                    ),
                                  );
                                },
                              ),
                          
                          const SizedBox(height: 16),
                          RaiseButton(
                            icon: Icons.book_outlined,
                            label: 'Chapters',
                            onPressed: () {
                              Navigator.of(context).push(
                                fadeRoute(
                                  ChaptersPage(),
                                ),
                              );
                            },
                          ),
                  
                            ],
                            

                            
                              
                          
                            
                          
                        ),
                      ),
                    
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
