import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journal/features/menu_buttons/raised_button.dart';

// import 'package:journal/pages/errors/auth_error_page.dart';
import 'package:journal/pages/journal_entry/activity_log.dart';
import 'package:journal/pages/journal_entry/activity_list.dart';
import 'package:journal/pages/journal_entry/chapter_selector.dart';
import 'package:journal/pages/journal_entry/entry_date_picker.dart';
import 'package:journal/features/text/text_entry.dart';
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
      if (!mounted) {
        return; // Ensure widget is still in the tree before calling setState
      }

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
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.redAccent),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveEntry,
            child: Text(
              "Save",
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date picker card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // A calendar icon on the left
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Text(
                      "Selected Date:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),

                // Your actual EntryDatePicker on the right
                EntryDatePicker(
                  selectedDate: _selectedDate,
                  onDateChanged: _updateSelectedDate,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Location input

            TextEntry(
              isMultiLine: false,
              controller: _locationTextController,
              labelText: 'Location: (optional)',
            ),
            const SizedBox(height: 24),

            // Chapter selector
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text("Chapter"),
                subtitle: Text(
                  _selectedChapterId != null
                      ? (Provider.of<DBProvider>(context, listen: false)
                              .getChapterById(_selectedChapterId!)?['name'] ??
                          "Unknown")
                      : "Select a chapter",
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => ChapterSelector(
                    onChapterSelected: _handleChapterSelected,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Journal entry

            SizedBox(
              height: screenHeight * 0.3,
              child: TextEntry(
                isMultiLine: true,
                controller: _textController,
                labelText: 'Journal Entry:',
              ),
            ),
            const SizedBox(height: 24),

            // Activities
            if (_activities) ...[
              Text(
                "Activities",
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ActivityList(
                savedActivities: _activityControllers
                    .map((c) => {
                          'name': c['name']!.text,
                          'description': c['description']!.text,
                        })
                    .toList(),
                onDelete: _deleteActivity,
              ),
              const SizedBox(height: 16),
            ],
            ActivityLog(
              controllers: _activityControllers,
              onSaveActivity: _saveActivity,
              onActivitiesChanged: (_) {},
            ),
            const SizedBox(height: 24),

            // Images preview
            Text(
              "Images",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

// Animate between zero and a max height
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // when there are no images, collapse to 0
                  minHeight: _chosenPhotoPaths.isEmpty ? 0 : 100,
                  maxHeight: _chosenPhotoPaths.isEmpty
                      ? 0
                      : MediaQuery.of(context).size.height * 0.25,
                ),
                child: _chosenPhotoPaths.isEmpty
                    // show nothing when empty
                    ? const SizedBox.shrink()
                    // otherwise your carousel
                    : ViewChosenImages(chosenPhotoPaths: _chosenPhotoPaths),
              ),
            ),
            const SizedBox(height: 16),

            // Add image button
            RaiseButton(
                onPressed: _getImageFromGallery,
                label: 'Add Image',
                icon: Icons.add_a_photo),

            // ElevatedButton.icon(
            //   onPressed: _getImageFromGallery,
            //   icon: const Icon(Icons.add_a_photo),
            //   label: const Text("Add Image"),
            //   style: ElevatedButton.styleFrom(
            //     padding: const EdgeInsets.symmetric(vertical: 14),
            //     textStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 16),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _saveEntry() {
    // 1) Show a non-dismissible dialog with initial text "0/total photos uploaded"
    showDialog(
      context: context,
      barrierDismissible: false, // user cannot tap outside to close
      builder: (dialogContext) {
        // This local variable holds the text shown in the dialog
        String progressText = '0/${_chosenPhotoPaths.length} photos uploaded';

        // StatefulBuilder lets us call setState(...) inside the dialog
        return StatefulBuilder(
          builder: (context, setState) {
            // Use addPostFrameCallback to run once when the dialog is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Only run saveEntryToFirestore ONCE. We check that progressText still starts with "0/"
              if (progressText.startsWith('0/')) {
                Provider.of<DBProvider>(context, listen: false)
                    .saveEntryToFirestore(
                  context: context,
                  currentUser: _currentUser!,
                  chapterId: _selectedChapterId,
                  activityControllers: _activityControllers,
                  textController: _textController,
                  locationTextController: _locationTextController,
                  selectedDate: _selectedDate,
                  imagePaths: _chosenPhotoPaths,

                  // Each time one photo finishes, this is called:
                  onProgress: (uploadedCount, totalCount) {
                    setState(() {
                      if (uploadedCount < totalCount) {
                        progressText =
                            '$uploadedCount/$totalCount photos uploaded';
                      } else {
                        // uploadedCount == totalCount
                        progressText =
                            'All photos uploaded. Saving Journal entry.';
                      }
                    });
                  },

                  // After the Firestore write itself finishes, this is called:
                  onComplete: () {
                    setState(() {
                      progressText = 'Journal Entry Saved.';
                    });
                    // Wait a short moment so the user sees "Journal Entry Saved."
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        Navigator.of(dialogContext).pop(); // close the dialog
                      }
                      Navigator.of(context).pop();
                    });
                  },
                );
              }
            });

            // The actual dialog UI: a spinner + the changing progressText
            return AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  Flexible(child: Text(progressText)),
                ],
              ),
            );
          },
        );
      },
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
