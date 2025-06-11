import 'package:flutter/material.dart';
import 'package:journal/providers/theme_provider.dart';
import 'package:provider/provider.dart';

/// Model representing a category of favorites with a ranked list of items.
class FavoriteCategory {
  String title;
  List<String> items;

  FavoriteCategory({required this.title, required this.items});
}

/// A page displaying multiple categories of favorites where each list can be reordered.
class YearInReviewQuestionsPage extends StatefulWidget {
  const YearInReviewQuestionsPage({super.key});

  @override
  _FavoritesWallPageState createState() => _FavoritesWallPageState();
}

class _FavoritesWallPageState extends State<YearInReviewQuestionsPage> {
  // Example data; replace with dynamic/user-stored data
  final List<FavoriteCategory> categories = [
    FavoriteCategory(
      title: 'Favorite TV Shows',
      items: ['The Mandalorian', 'Stranger Things', 'Ted Lasso', 'The Crown'],
    ),
    FavoriteCategory(
      title: 'Concerts Attended',
      items: ['Coldplay', 'Billie Eilish', 'Foo Fighters'],
    ),
    FavoriteCategory(
      title: 'Books Read',
      items: ['1984', 'Dune', 'The Hobbit'],
    ),
    FavoriteCategory(
      title: 'Vacations Taken',
      items: ['Hawaii', 'Japan', 'Italy'],
    ),
    FavoriteCategory(
      title: 'Movies Seen in Theaters',
      items: ['Avatar 2', 'Top Gun: Maverick', 'Elvis'],
      
    ),
    FavoriteCategory(
      title: 'Favorite Songs',
      items: ['Blinding Lights', 'Levitating', 'Peaches'],
    ),
  ];

  // Track edit mode per category
  late List<bool> _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = List<bool>.filled(categories.length, false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Year In Review Questions')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProv.backgroundGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: categories.length,
        itemBuilder: (context, catIndex) {
          final category = categories[catIndex];
          final isEditing = _isEditing[catIndex];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              title: Text(
                category.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              children: [
                // Add & Edit buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // TODO: handle adding new item
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add New Item'),
                      ),
                    ],
                  ),
                ),
                // List: reorderable when editing, static otherwise
                isEditing
                    ? ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = category.items.removeAt(oldIndex);
                            category.items.insert(newIndex, item);
                          });
                        },
                        children: [
                          for (int i = 0; i < category.items.length; i++)
                            ListTile(
                              key: ValueKey('$catIndex-$i'),
                              leading: CircleAvatar(
                                radius: 14,
                                child: Text('${i + 1}'),
                              ),
                              title: Text(category.items[i]),
                              trailing: const Icon(Icons.drag_handle),
                            ),
                        ],
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < category.items.length; i++)
                            ListTile(
                              leading: CircleAvatar(
                                radius: 14,
                                child: Text('${i + 1}'),
                              ),
                              title: Text(category.items[i]),
                            ),
                        ],
                      ),
                // Drag hint
                if (isEditing)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Drag to reorder items in this category.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                const SizedBox(height: 6),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing[catIndex] = !_isEditing[catIndex];
                    });
                  },
                  icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.blue,),
                  label: Text(
                    isEditing ? 'Done' : 'Edit',
                    style: const TextStyle(color: Colors.blue),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          );
        },
      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new category
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
