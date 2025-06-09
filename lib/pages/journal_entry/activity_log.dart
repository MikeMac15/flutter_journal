import 'package:flutter/material.dart';
import 'package:journal/features/menu_buttons/raised_button.dart';
import 'package:journal/features/text/text_entry.dart';

class ActivityLog extends StatefulWidget {
  final List<Map<String, TextEditingController>> controllers;
  final Function(List<Map<String, String>>)? onActivitiesChanged;
  final Function(String, String) onSaveActivity; // Updated to pass name and description

  const ActivityLog({
    super.key,
    required this.controllers,
    this.onActivitiesChanged,
    required this.onSaveActivity,
  });

  @override
  State<ActivityLog> createState() => _ActivityLogState();
}

class _ActivityLogState extends State<ActivityLog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }


  void _saveActivity() {
    if (_nameController.text.isNotEmpty || _descriptionController.text.isNotEmpty) {
      widget.onSaveActivity(_nameController.text, _descriptionController.text);
      _nameController.clear();
      _descriptionController.clear();
    }
  }

  void _notifyParent() {
    if (widget.onActivitiesChanged != null) {
      final activities = widget.controllers.map((controllerMap) {
        return {
          'name': controllerMap['name']!.text,
          'description': controllerMap['description']!.text,
        };
      }).toList();
      widget.onActivitiesChanged!(activities);
    }
  }

  @override
  void dispose() {
    for (var controllerMap in widget.controllers) {
      controllerMap['name']?.dispose();
      controllerMap['description']?.dispose();
    }
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  @override
Widget build(BuildContext context) {
  return Center(
    child: RaiseButton(
      label: 'Activity',
      icon: Icons.add,
      onPressed: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true, // Allows the sheet to resize with the keyboard
          builder: (BuildContext context) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Pushes content above the keyboard
              ),
              child: 
              Padding(padding: const EdgeInsets.all(16.0),
              child:
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Shrinks to content size
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextEntry(
                                isMultiLine: false,
                                controller: _nameController,
                                labelText: "Activity:",
                                onChanged: (_) => _notifyParent(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100.0,
                          child: TextEntry(
                            isMultiLine: true,
                            controller: _descriptionController,
                            labelText: "Description: (optional)",
                            onChanged: (_) => _notifyParent(),
                          ),
                        ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      
                     RaiseButton(
                        onPressed: _saveActivity,
                        label: 'Save Activity',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20), // Extra padding at the bottom
                      ],
                    ),
                  ),
                ],
              ),
            ));
          },
        );
      },
    ),
  );
}
}