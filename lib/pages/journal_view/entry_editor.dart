import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:journal/features/pictures/_my_image_picker.dart';
import 'package:journal/providers/db_provider.dart';
import 'package:journal/services/image_compressor.dart';
import 'package:provider/provider.dart';

class EntryEditor extends StatefulWidget {
  final String entryId;
  final VoidCallback? onEntryUpdated;
  final String _entry;
  final String _location;
  final List<String> _imgUrls;
  final List<dynamic> _activities;
  final DateTime _entryDate;

  const EntryEditor({
    super.key,
    required this.entryId,
    this.onEntryUpdated,
    required String entry,
    required String location,
    required List<String> imgUrls,
    required List<dynamic> activities,
    required DateTime entryDate,
  })  : _entry = entry,
        _location = location,
        _imgUrls = imgUrls,
        _activities = activities,
        _entryDate = entryDate;

  @override
  State<EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<EntryEditor> {
  final List<XFile> _newImages = [];
  final MyImagePicker _myImagePicker = MyImagePicker();

  late final DBProvider dbProvider;

  @override
  void initState() {
    super.initState();
    dbProvider = Provider.of<DBProvider>(context, listen: false);
  }

  Future<void> _getImageFromGallery() async {
    try {
      final files = await _myImagePicker.pickMultipleImagesFromGallery();
      if (files.isEmpty) return;

      final chosen = await Future.wait(files.map((file) async {
        final metadata = await extractCorePhotoMetadata(file);
        return ImageWithMetadata(file: file, metadata: metadata);
      }));

      // Optional de-dupe by path
      final existingPaths = _newImages.map((x) => x.path).toSet();
      final unique =
          chosen.where((im) => !existingPaths.contains(im.file.path));

      if (mounted) {
        setState(() {
          _newImages.addAll(unique.map((im) => im.file));
        });
      }
    } catch (e, st) {
      debugPrint('pickMultipleImagesFromGallery failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not pick images')),
        );
      }
    }
  }

  /// NEW: Deletes the entire entry from Firestore
  Future<void> _deleteEntry(BuildContext dialogContext) async {
    // 1. Show Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text(
            'Are you sure you want to delete this journal entry? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final uid = dbProvider.userId;
    if (uid == null) return;

    try {
      // 2. Delete from Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('entries')
          .doc(widget.entryId)
          .delete();

      // 3. Refresh local provider data to remove the item from lists
      await dbProvider.fetchJournalEntrySnapshot();

      if (mounted) {
        Navigator.of(dialogContext).pop(); // Close the Edit Dialog
        Navigator.of(context).pop(); // Close the Entry View Page (Back to list)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry deleted successfully')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting entry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete entry: $e')),
        );
      }
    }
  }

  Future<void> _saveEdits(
    String newEntry,
    String newLocation,
    DateTime newDate,
    List<XFile>? newImages,
  ) async {
    final uid = dbProvider.userId;
    if (uid == null) throw StateError('userId is null');

    final fs = FirebaseFirestore.instance;
    final docRef = fs
        .collection('users')
        .doc(uid)
        .collection('entries')
        .doc(widget.entryId);

    // 1) Upload first
    List<String> newImgUrls = [];
    if (newImages != null && newImages.isNotEmpty) {
      try {
        newImgUrls = await dbProvider.uploadMultiPics(newImages);
      } catch (e, st) {
        debugPrint('uploadMultiPics failed: $e\n$st');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image upload failed: $e')),
          );
        }
        return;
      }
    }

    // 2) Transactional update
    try {
      await fs.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) {
          tx.set(
              docRef,
              {
                'entry': newEntry,
                'location': newLocation,
                'date': newDate.toIso8601String(),
                'imgUrls': newImgUrls,
                'updatedAt': FieldValue.serverTimestamp(),
              },
              SetOptions(merge: true));
          return;
        }

        final update = <String, dynamic>{
          'entry': newEntry,
          'location': newLocation,
          'date': newDate.toIso8601String(),
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (newImgUrls.isNotEmpty) {
          update['imgUrls'] = FieldValue.arrayUnion(newImgUrls);
        }
        tx.update(docRef, update);
      });

      if (mounted) {
        setState(() => _newImages.clear()); // prevent re-uploads next time
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry updated')),
        );
      }
      widget.onEntryUpdated?.call();
    } on FirebaseException catch (e, st) {
      debugPrint('Firestore update failed (${e.code}): ${e.message}\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${e.code}')),
        );
      }
    } catch (e, st) {
      debugPrint('Unknown error updating entry: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return // ← New “Edit Entry” button ↓
        ElevatedButton.icon(
      icon: const Icon(Icons.edit),
      label: const Text('Edit Entry'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        // 1) Pre-fill controllers and date
        final entryController = TextEditingController(text: widget._entry);
        final locationController =
            TextEditingController(text: widget._location);
        DateTime newDate = widget._entryDate;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) {
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Edit Journal Entry'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ----- Date Picker Row -----
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today),
                          title: Text(
                            DateFormat.yMMMd().format(newDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: newDate,
                              firstDate: DateTime(1950),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null && picked != newDate) {
                              setState(() {
                                newDate = picked;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        // ----- Entry Text Field -----
                        TextField(
                          controller: entryController,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: 'Entry Text',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ----- Location Text Field -----
                        TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            labelText: 'Location',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Image Picker Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            await _getImageFromGallery();
                            print(_newImages);
                          },
                          icon: const Icon(Icons.photo),
                          label: const Text('Add Photos'),
                        ),
                        const SizedBox(height: 12),
                        
                        // Delete First Photo Button
                        ElevatedButton.icon(
                          onPressed: () async {
                            final snap = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(dbProvider.userId)
                                .collection('entries')
                                .doc(widget.entryId)
                                .get();
                            final urls = List<String>.from(
                                (snap.data()?['imgUrls'] ?? []) as List);
                            if (urls.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('No photos to delete')),
                              );
                              return;
                            }
                            await dbProvider.deletePicture(
                                urls.first, widget.entryId);
                          },
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Delete First Photo'),
                        ),
                        
                        // NEW: Divider to separate delete action
                        const Divider(height: 30, thickness: 1),

                        // NEW: Delete Entire Post Button
                        TextButton.icon(
                          onPressed: () => _deleteEntry(dialogCtx),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text(
                            'Delete Entire Entry',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogCtx).pop(); // Cancel editing
                      },
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final newEntry = entryController.text.trim();
                        final newLocation = locationController.text.trim();
                        print(
                            'saving changes for entry: $newEntry, $_newImages');
                        // Save edits including the date
                        await _saveEdits(
                            newEntry, newLocation, newDate, _newImages);
                        widget.onEntryUpdated?.call();
                        Navigator.of(dialogCtx).pop(); // Close dialog
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}