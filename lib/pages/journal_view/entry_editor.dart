import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:journal/features/pictures/_my_image_picker.dart';
import 'package:journal/features/pictures/view_chosen_images.dart';
import 'package:journal/features/pictures/view_thumbnails.dart';
import 'package:journal/providers/db_provider.dart';
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
  final MyImagePicker _picker = MyImagePicker();
  final List<XFile> _newImages = [];
  
  late final DBProvider dbProvider;

  @override
  void initState() {
    super.initState();
    dbProvider = Provider.of<DBProvider>(context, listen: false);
  }

  Future<void> _saveEdits(String newEntry, String newLocation, DateTime newDate,
      List<XFile>? newImages) async {
    // Update Firestore

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(dbProvider.userId)
        .collection('entries')
        .doc(widget.entryId);

    try {
      if (newImages != null && newImages.isNotEmpty) {
        // Upload new images and get their URLs
        final newImgUrls = await dbProvider.uploadMultiPics(newImages);
        await docRef.update({
          'entry': newEntry,
          'location': newLocation,
          'date': newDate.toIso8601String(),
          'imgUrls': [...widget._imgUrls, ...newImgUrls],
        });
      } else {
        await docRef.update({
          'entry': newEntry,
          'location': newLocation,
          'date': newDate.toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry updated')),
        );
      }
      widget.onEntryUpdated?.call();
    } catch (e) {
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
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
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
                            final List<XFile> picked =
                                await _picker.pickMultipleImagesFromGallery();
                            if (picked.isNotEmpty) {
                              setState(() => _newImages.addAll(picked));
                            }
                          },
                          icon: const Icon(Icons.photo),
                          label: const Text('Add Photos'),
                        ),
                        const SizedBox(height: 12),

                        // ----- New Images Preview -----
                        // Expanded(
                        //   child: ViewThumbnailImages(photoSources: _newImages),
                        // ),
                        // Thumbnails

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
