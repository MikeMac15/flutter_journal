// import 'package:flutter/material.dart';
// import 'package:journal/providers/theme_provider.dart';
// import 'package:provider/provider.dart';

// /// Model representing a category of favorites with a ranked list of items.
// class FavoriteCategory {
//   String title;
//   List<String> items;

//   FavoriteCategory({required this.title, required this.items});
// }

// /// A page displaying multiple categories of favorites where each list can be reordered.
// class YearInReviewQuestionsPage extends StatefulWidget {
//   const YearInReviewQuestionsPage({super.key});

//   @override
//   _FavoritesWallPageState createState() => _FavoritesWallPageState();
// }

// class _FavoritesWallPageState extends State<YearInReviewQuestionsPage> {
//   // Example data; replace with dynamic/user-stored data
//   final List<FavoriteCategory> categories = [
//     FavoriteCategory(
//       title: 'Favorite TV Shows',
//       items: ['The Mandalorian', 'Stranger Things', 'Ted Lasso', 'The Crown'],
//     ),
//     FavoriteCategory(
//       title: 'Concerts Attended',
//       items: ['Coldplay', 'Billie Eilish', 'Foo Fighters'],
//     ),
//     FavoriteCategory(
//       title: 'Books Read',
//       items: ['1984', 'Dune', 'The Hobbit'],
//     ),
//     FavoriteCategory(
//       title: 'Vacations Taken',
//       items: ['Hawaii', 'Japan', 'Italy'],
//     ),
//     FavoriteCategory(
//       title: 'Movies Seen in Theaters',
//       items: ['Avatar 2', 'Top Gun: Maverick', 'Elvis'],
      
//     ),
//     FavoriteCategory(
//       title: 'Favorite Songs',
//       items: ['Blinding Lights', 'Levitating', 'Peaches'],
//     ),
//   ];

//   // Track edit mode per category
//   late List<bool> _isEditing;

//   @override
//   void initState() {
//     super.initState();
//     _isEditing = List<bool>.filled(categories.length, false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeProv = context.watch<ThemeProvider>();
//     return Scaffold(
//       appBar: AppBar(title: const Text('Year In Review Questions')),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: themeProv.backgroundGradientColors,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: ListView.builder(
//         padding: const EdgeInsets.all(8.0),
//         itemCount: categories.length,
//         itemBuilder: (context, catIndex) {
//           final category = categories[catIndex];
//           final isEditing = _isEditing[catIndex];
//           return Card(
//             margin: const EdgeInsets.symmetric(vertical: 6.0),
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//             child: ExpansionTile(
//               title: Text(
//                 category.title,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//               ),
//               children: [
//                 // Add & Edit buttons
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: () {
//                           // TODO: handle adding new item
//                         },
//                         icon: const Icon(Icons.add),
//                         label: const Text('Add New Item'),
//                       ),
//                     ],
//                   ),
//                 ),
//                 // List: reorderable when editing, static otherwise
//                 isEditing
//                     ? ReorderableListView(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         onReorder: (oldIndex, newIndex) {
//                           setState(() {
//                             if (newIndex > oldIndex) newIndex--;
//                             final item = category.items.removeAt(oldIndex);
//                             category.items.insert(newIndex, item);
//                           });
//                         },
//                         children: [
//                           for (int i = 0; i < category.items.length; i++)
//                             ListTile(
//                               key: ValueKey('$catIndex-$i'),
//                               leading: CircleAvatar(
//                                 radius: 14,
//                                 child: Text('${i + 1}'),
//                               ),
//                               title: Text(category.items[i]),
//                               trailing: const Icon(Icons.drag_handle),
//                             ),
//                         ],
//                       )
//                     : Column(
//                         children: [
//                           for (int i = 0; i < category.items.length; i++)
//                             ListTile(
//                               leading: CircleAvatar(
//                                 radius: 14,
//                                 child: Text('${i + 1}'),
//                               ),
//                               title: Text(category.items[i]),
//                             ),
//                         ],
//                       ),
//                 // Drag hint
//                 if (isEditing)
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Text(
//                       'Drag to reorder items in this category.',
//                       style: TextStyle(color: Colors.grey.shade600),
//                     ),
//                   ),
//                 const SizedBox(height: 6),
//                 ElevatedButton.icon(
//                   onPressed: () {
//                     setState(() {
//                       _isEditing[catIndex] = !_isEditing[catIndex];
//                     });
//                   },
//                   icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.blue,),
//                   label: Text(
//                     isEditing ? 'Done' : 'Edit',
//                     style: const TextStyle(color: Colors.blue),),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     elevation: 0,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//               ],
//             ),
//           );
//         },
//       ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // TODO: Add new category
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/questionWalls/YIR_Classes.dart';
import 'package:journal/features/questionWalls/yir/yir_detail_page.dart';

import 'package:journal/providers/db_provider.dart';
import 'package:journal/providers/theme_provider.dart';
import 'package:provider/provider.dart';

class YearInReviewQuestionsPage extends StatefulWidget {
  const YearInReviewQuestionsPage({super.key});

  @override
  _YearInReviewQuestionsPageState createState() => _YearInReviewQuestionsPageState();
}

class _YearInReviewQuestionsPageState extends State<YearInReviewQuestionsPage> {
  List<FavoriteCategory> defaultCategories = [
    FavoriteCategory(title: 'Favorite TV Shows', items: ['The Mandalorian', 'Stranger Things', 'Ted Lasso']),
    FavoriteCategory(title: 'Concerts', items: ['Coldplay', 'Billie Eilish']),
    FavoriteCategory(title: 'Books Read', items: ['1984', 'Dune']),
    FavoriteCategory(title: 'Vacations', items: ['Hawaii', 'Japan']),
    FavoriteCategory(title: 'Movies Seen in Theaters', items: ['Avatar 2', 'Top Gun: Maverick']),
    FavoriteCategory(title: 'Favorite Songs', items: ['Blinding Lights', 'Peaches']),
  ];

  late bool createNew = false;


  Set<String> selectedCategoryTitles = {};
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  bool loading = true;
  List<Yir> existingYirs = [];

  @override
  void initState() {
    super.initState();
    checkYir();
  }

  Future<void> checkYir() async {
    final provider = Provider.of<DBProvider>(context, listen: false);
    await provider.fetchAllYIR();
    setState(() {
      existingYirs = provider.allYir;
      loading = false;
    });
  }
  
  
  Widget CreateYirPage(){
    final themeProv = context.watch<ThemeProvider>();
    final dbProvider = context.read<DBProvider>();

      return Scaffold(
      appBar: AppBar(title: const Text('Create Your Year In Review')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProv.backgroundGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Year (e.g., 2025)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            
            const SizedBox(height: 12),
            ...defaultCategories.map((category) {
              final isSelected = selectedCategoryTitles.contains(category.title);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(category.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: Icon(
                      isSelected ? Icons.check_circle : Icons.add_circle_outline,
                      color: isSelected ? Colors.green : Colors.blue,
                    ),
                    onPressed: () {
                      setState(() {
                        if (isSelected) {
                          selectedCategoryTitles.remove(category.title);
                        } else {
                          selectedCategoryTitles.add(category.title);
                        }
                      });
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customCategoryController,
                    decoration: const InputDecoration(
                      labelText: 'Add Custom Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    final title = _customCategoryController.text.trim();
                    if (title.isNotEmpty && !defaultCategories.any((c) => c.title == title)) {
                      setState(() {
                        defaultCategories.add(FavoriteCategory(title: title, items: []));
                        selectedCategoryTitles.add(title);
                        _customCategoryController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('* You can always add more later', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Create YIR'),
              onPressed: _yearController.text.trim().isEmpty
                  ? null
                  : () async {
                      final userId = dbProvider.userId;
                      if (userId == null) return;

                      final selectedCats = defaultCategories
                          .where((c) => selectedCategoryTitles.contains(c.title))
                          .map((c) => YirCategory(
                                title: c.title,
                                items: c.items.map((item) => YirItem(text: item)).toList(),
                              ))
                          .toList();

                      final newYir = Yir(year: _yearController.text.trim(), categories: selectedCats);
                      await dbProvider.saveYir(newYir);
                      setState(() {
                        existingYirs.add(newYir);
                        createNew = false;
                      });
                    },
            ),
          ],
        ),
      ),
    );
    }

  @override
  Widget build(BuildContext context) {
    

    

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (createNew) {
      return CreateYirPage();
    }

    if (existingYirs.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Your Year In Review'), ),
        body: ListView.builder(
          itemCount: existingYirs.length,
          itemBuilder: (context, index) {
            final yir = existingYirs[index];
            return ListTile(
              title: Text('Year ${yir.year}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to the YIR detail page (placeholder)
                Navigator.of(context).push(
                  fadeRoute(YirDetailPage(year: yir.year)),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              createNew = true;
            });
          },
          child: const Icon(Icons.add),
        ),
      );
    }

    return CreateYirPage();
  }
}

class FavoriteCategory {
  final String title;
  final List<String> items;

  FavoriteCategory({required this.title, required this.items});
}
