import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:journal/features/menu_buttons/raised_button.dart';

// import 'package:journal/pages/errors/auth_error_page.dart';
import 'package:journal/pages/journal_entry/activity_log.dart';
import 'package:journal/pages/journal_entry/activity_list.dart';
import 'package:journal/pages/journal_entry/chapter_selector.dart';
import 'package:journal/pages/journal_entry/entry_date_picker.dart';
import 'package:journal/features/text/text_entry.dart';
import 'package:journal/features/pictures/view_chosen_images.dart';
import 'package:journal/pages/journal_view_page.dart';
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
  final List<XFile> _chosenPhotos = [];


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
    final List<XFile> files =
        await _myImagePicker.pickMultipleImagesFromGallery();
    for (final file in files) {
      setState(() {
        _chosenPhotos.add(file);
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

      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(DateFormat('E  MMM dd, yyyy').format(_selectedDate)),
        elevation: 2,
        backgroundColor: Colors.transparent,
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
                      "Entry Date:",
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
                              .getChapterById(_selectedChapterId!)?.name ??
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
                  minHeight: _chosenPhotos.isEmpty ? 0 : 100,
                  maxHeight: _chosenPhotos.isEmpty
                      ? 0
                      : MediaQuery.of(context).size.height * 0.25,
                ),
                child: _chosenPhotos.isEmpty
                    // show nothing when empty
                    ? const SizedBox.shrink()
                    // otherwise your carousel
                    : ViewChosenImages(chosenPhotos: _chosenPhotos),
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

  void _saveEntry() async { // Make this function async
  final dbProvider = Provider.of<DBProvider>(context, listen: false);
  final imagePathsSnapshot = List.from(_chosenPhotos);
  
  // If there's nothing to save, don't do anything.
  if (_textController.text.isEmpty && imagePathsSnapshot.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cannot save an empty entry.')),
    );
    return;
  }

  // Use a ValueNotifier to update the dialog text cleanly.
  final progressNotifier = ValueNotifier<String>('Starting upload...');

  // Show the dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => ValueListenableBuilder<String>(
      valueListenable: progressNotifier,
      builder: (context, progressText, child) {
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
    ),
  );

  // --- Main Logic with try/catch ---
  try {
    final newEntryId = await dbProvider.saveEntryToFirestore(
      currentUser: _currentUser!,
      chapterId: _selectedChapterId,
      activityControllers: _activityControllers,
      textController: _textController,
      locationTextController: _locationTextController,
      selectedDate: _selectedDate,
      imagePaths: imagePathsSnapshot.cast<XFile>(),
      onProgress: (uploadedCount, totalCount) {
        if (uploadedCount < totalCount) {
          progressNotifier.value = '$uploadedCount/$totalCount photos uploaded';
        } else {
          progressNotifier.value = 'All photos uploaded. Saving entry...';
        }
      },
    );

    // SUCCESS CASE
    if (!mounted) return;
    Navigator.of(context).pop(); // Close the loading dialog
    
    // Navigate to the new entry page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => JournalEntryViewPage(entryId: newEntryId),
      ),
    );

  } catch (e) {
    // FAILURE CASE
    if (!mounted) return;
    Navigator.of(context).pop(); // IMPORTANT: Close the dialog on error!

    // Show an error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to save entry: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
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
