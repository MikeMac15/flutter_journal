import 'package:flutter/material.dart';
import 'package:journal/features/calendar/_calendar_card.dart';
import 'package:journal/pages/chapters/chapters_page.dart';
import 'package:journal/pages/journal_entry_page.dart';
import 'package:journal/pages/journal_recents_list.dart';
import 'package:journal/pages/settings.dart';
import 'package:journal/providers/user_provider.dart';
import 'package:journal/theme/_colors.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  /// Pass in whatever header image URL you like:
  // final String headerImageUrl;

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProv = context.watch<UserProvider>();
    final headerUrl = userProv.headerImageUrl;
     final screenWidth = MediaQuery.of(context).size.width;
  final avatarSize = (screenWidth * 0.08).clamp(50.0, 64.0);

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          const basePad = 24.0;
          final extra = (constraints.maxWidth - 900).clamp(0.0, double.infinity);
          final horizontalPad = basePad + (extra / 2);

          return CustomScrollView(
            slivers: [
              // ─── SliverAppBar ───────────────────────────────────
              SliverAppBar(
                pinned: false,
                elevation: 2,
                expandedHeight: 250,
                backgroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Jamie\'s Journal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 4,
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
  : Image.asset('assets/images/default_header.png', fit: BoxFit.cover),

                      // subtle overlay so toolbar text pops
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.4),
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
    // Avatar icon
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        radius: avatarSize / 2.25,
        backgroundColor: const Color.fromARGB(183, 239, 239, 239),
        child: IconButton(
          alignment: Alignment.center,
      icon: Icon(Icons.settings,  color: theme.colorScheme.onSurface, size: 30),
      tooltip: 'Settings',
      onPressed: () {
       
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SettingsPage()),
        );
      },
    ),
      ),
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
                    // Calendar card
                    const CalendarCard(),

                    const SizedBox(height: 24),

                    // Responsive action buttons
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: LayoutBuilder(builder: (context, inner) {
                          const gap = 16.0;
                          const count = 3;
                          final available =
                              inner.maxWidth - gap * (count - 1);
                          final side = available / count;
                          final buttons = [
                            [
                              'New Entry',
                              Icons.edit,
                              JournalEntryPage(selectedDate: DateTime.now())
                            ],
                            ['Chapters', Icons.menu_book, ChaptersPage()],
                            [
                              'Recents',
                              Icons.library_books,
                              JournalRecentsList()
                            ],
                          ];

                          if (inner.maxWidth < 380) {
                            return Column(
                              children: buttons.map((btn) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(bottom: gap),
                                  child: SizedBox(
                                    width: inner.maxWidth,
                                    height: side,
                                    child:
                                        _buildButton(btn, side, theme),
                                  ),
                                );
                              }).toList(),
                            );
                          }

                          return Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
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
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper unchanged from your original:
  Widget _buildButton(List btn, double side, ThemeData theme) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => btn[2] as Widget)),
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
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
