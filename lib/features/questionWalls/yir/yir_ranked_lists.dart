import 'package:flutter/material.dart';
import 'package:journal/features/questionWalls/YIR_Classes.dart';

import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

class YirRankedLists extends StatefulWidget {
  const YirRankedLists({super.key, required this.yir});

  final Yir yir;

  @override
  State<YirRankedLists> createState() => _YirRankedListsState();
}

class _YirRankedListsState extends State<YirRankedLists> {
  late List<bool> _isEditing;
  final Map<int, List<YirItem>> _updatedItems = {};
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _isEditing = List.generate(widget.yir.categories.length, (_) => false);
    for (int i = 0; i < widget.yir.categories.length; i++) {
      _controllers[i] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleAddItem(
    DBProvider dbProvider,
    int catIndex,
    YirCategory category,
  ) async {
    final controller = _controllers[catIndex];
    if (controller == null) return;

    final text = controller.text.trim();
    if (text.isEmpty) return;

    await dbProvider.addItemToCategory(
      widget.yir.year,
      category.title,
      YirItem(text: text),
    );

    controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DBProvider>(context, listen: false);

    return ListView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
      itemCount: widget.yir.categories.length,
      itemBuilder: (context, catIndex) {
        final category = widget.yir.categories[catIndex];
        final isEditing = _isEditing[catIndex];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            title: Text(
              category.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (isEditing &&
                          (_updatedItems[catIndex]?.isNotEmpty ?? false)) {
                        await dbProvider.updateCategoryItems(
                          widget.yir.year,
                          YirCategory(
                            title: category.title,
                            items: _updatedItems[catIndex]!,
                          ),
                        );
                      }

                      setState(() {
                        _isEditing[catIndex] = !_isEditing[catIndex];
                        _updatedItems[catIndex] = [];
                      });
                    },
                    icon: Icon(
                      isEditing ? Icons.check : Icons.edit,
                      color: Colors.blue,
                    ),
                    label: Text(
                      isEditing ? 'Done' : 'Edit',
                      style: const TextStyle(color: Colors.blue),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      elevation: 0,
                    ),
                  ),
                ),
              ),
              isEditing
                  ? ReorderableListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: (oldIndex, newIndex) {
                        if (newIndex > oldIndex) newIndex--;
                        final item = category.items.removeAt(oldIndex);
                        category.items.insert(newIndex, item);

                        _updatedItems[catIndex] = [...category.items];
                        setState(() {});
                      },
                      children: List.generate(category.items.length, (i) {
                        final item = category.items[i];
                        return ListTile(
                          key: ValueKey('$catIndex-$i'),
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text('${i + 1}'),
                          ),
                          title: Text(item.text),
                          trailing: 
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  await dbProvider.deleteItemFromCategory(
                                    widget.yir.year,
                                    category.title,
                                    i,
                                  );
                                  setState(() {});
                                },
                              ),
                              const Icon(Icons.drag_handle),
                          ],
                          ),
                        );
                      }),
                    )
                  : Column(
                      children: List.generate(category.items.length, (i) {
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 14,
                            child: Text('${i + 1}'),
                          ),
                          title: Text(category.items[i].text),
                          
                        );
                      }),
                    ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: isEditing || category.items.isEmpty
                    ? TextField(
                        controller: _controllers[catIndex],
                        onSubmitted: (_) => _handleAddItem(
                          dbProvider,
                          catIndex,
                          category,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Add new item',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _handleAddItem(
                              dbProvider,
                              catIndex,
                              category,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(height: 8),
              )
            ],
          ),
        );
      },
    );
  }
}
