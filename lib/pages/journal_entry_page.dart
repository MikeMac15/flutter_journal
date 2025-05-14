import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// import 'package:journal/pages/errors/auth_error_page.dart';
import 'package:journal/pages/journal_entry/activity_log.dart';
import 'package:journal/pages/journal_entry/activity_list.dart';
import 'package:journal/pages/journal_entry/chapter_selector.dart';
import 'package:journal/pages/journal_entry/entry_date_picker.dart';
import 'package:journal/pages/journal_entry/text_entry.dart';
import 'package:journal/features/pictures/view_chosen_images.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:provider/provider.dart';

import '../features/pictures/_my_image_picker.dart';

class JournalEntryPage extends StatefulWidget {
  final DateTime selectedDate;

  JournalEntryPage({super.key, DateTime? selectedDate})
      : selectedDate = selectedDate ?? DateTime.now();

  @override
  State<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends State<JournalEntryPage> {
  final List<Map<String, TextEditingController>> _activityControllers = [];
  late TextEditingController _textController;
  late TextEditingController _locationTextController;
  User? _currentUser;
  late DateTime _selectedDate;
  late bool _activities;
  late MyImagePicker _myImagePicker;
  final List<String> _chosenPhotoPaths = [];

  String? _selectedChapterId;
  // String? _selectedChapterName;
  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _locationTextController = TextEditingController();
    _setupAuthListener();
    // _loadExistingEntry();
    // _loadExistingActivities();
    _selectedDate = widget.selectedDate;
    _activities = false;
    _myImagePicker = MyImagePicker();
  }

  @override
  void dispose() {
    _textController.dispose();
    for (var controllerMap in _activityControllers) {
      controllerMap['name']?.dispose();
      controllerMap['description']?.dispose();
    }
    super.dispose();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted)
        return; // Ensure widget is still in the tree before calling setState

      setState(() {
        _currentUser = user;
      });

      if (user == null) {
        // Guard against using context if the widget is no longer mounted
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AuthErrorPage()),
          );
        }
      } else {
        // print('User is signed in: ${user.uid}');
      }
    });
  }

  void _handleChapterSelected(String? chapterId, String? chapterName) {
    setState(() {
      _selectedChapterId = chapterId;
      // _selectedChapterName = chapterName;
    });
  }

  void _deleteActivity(int index) {
    setState(() {
      _activityControllers[index]['name']?.dispose();
      _activityControllers[index]['description']?.dispose();
      _activityControllers.removeAt(index);
    });
  }

  void _saveActivity(String name, String description) {
    setState(() {
      _activities = true;
      if (name.isNotEmpty || description.isNotEmpty) {
        _activityControllers.add({
          'name': TextEditingController(text: name),
          'description': TextEditingController(text: description),
        });
      }
    });
  }

  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  Future<void> _getImageFromGallery() async {
    String? imagePath = await _myImagePicker.pickImageFromGallery();
    if (imagePath != null) {
      setState(() {
        _chosenPhotoPaths.add(imagePath);
      });
    }
  }

  // void _removeImageFromChosen(int idx) {
  //   setState(() {
  //     _chosenPhotoPaths.removeAt(idx);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // title: Text('stuff'),
        leading: IconButton(
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              final dbProvider =
                  Provider.of<DBProvider>(context, listen: false);

              dbProvider.saveEntryToFirestore(
                  context: context,
                  currentUser: _currentUser,
                  chapterId: _selectedChapterId,
                  activityControllers: _activityControllers,
                  textController: _textController,
                  locationTextController: _locationTextController,
                  selectedDate: _selectedDate,
                  imagePaths: _chosenPhotoPaths);
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.blue, fontSize: 20),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EntryDatePicker(
                selectedDate: _selectedDate,
                onDateChanged: _updateSelectedDate,
              ),
              const SizedBox(height: 20),
              TextEntry(
                isMultiLine: false,
                controller: _locationTextController,
                hintText: 'Location (optional)',
              ),
              const SizedBox(height: 20),
              ChapterSelector(
                onChapterSelected: _handleChapterSelected,
              ),
              const SizedBox(height: 20),
              const Text('Journal Entry',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: screenHeight * 0.35,
                child: TextEntry(
                  isMultiLine: true,
                  controller: _textController,
                  hintText: 'Write your journal entry here...',
                  onChanged: (text) {
                    // print('Text changed: $text');
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: Column(
                  children: [
                    _activities
                        ? ActivityList(
                            savedActivities: _activityControllers
                                .map((ctrlMap) => {
                                      'name': ctrlMap['name']!.text,
                                      'description':
                                          ctrlMap['description']!.text,
                                    })
                                .toList(),
                            onDelete: _deleteActivity,
                          )
                        : Text(''),
                    SizedBox(
                      child: ActivityLog(
                        controllers: _activityControllers,
                        onSaveActivity: _saveActivity,
                        onActivitiesChanged: (activities) {
                          // print('Activities updated: $activities');
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 300,
                child: ViewChosenImages(chosenPhotoPaths: _chosenPhotoPaths),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: _getImageFromGallery,
                      child: const Text('Add an image')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder AuthErrorPage
class AuthErrorPage extends StatelessWidget {
  const AuthErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Error')),
      body: const Center(child: Text('Please sign in')),
    );
  }
}
