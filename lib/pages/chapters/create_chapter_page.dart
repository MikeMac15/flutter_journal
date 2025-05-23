import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';              // for kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/features/pictures/_my_image_picker.dart';

class CreateChapterPage extends StatefulWidget {
  const CreateChapterPage({super.key});

  @override
  CreateChapterPageState createState() => CreateChapterPageState();
}

class CreateChapterPageState extends State<CreateChapterPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _coverImageFile;
  Uint8List? _coverImageBytes;  // for web
  bool _isUploading = false;

  Future<void> _pickCoverImage() async {
    final picker = MyImagePicker();
    final pickedPath = await picker.pickImageFromGallery();
    if (pickedPath == null) return;

    if (kIsWeb) {
      // On web, read bytes and store in memory
      final bytes = await XFile(pickedPath).readAsBytes();
      setState(() {
        _coverImageBytes = bytes;
        _coverImageFile = null;
      });
    } else {
      // On mobile/desktop, store as File
      setState(() {
        _coverImageFile = File(pickedPath);
        _coverImageBytes = null;
      });
    }
  }

  Future<void> _saveChapter() async {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all the fields")),
      );
      return;
    }

    setState(() => _isUploading = true);

    final userId = FirebaseAuth.instance.currentUser?.uid;
    String? coverImageUrl;

    if (_coverImageFile != null || _coverImageBytes != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageRef = storageRef.child('users/$userId/chapter_covers/$fileName');

      try {
        UploadTask uploadTask;
        if (kIsWeb && _coverImageBytes != null) {
          uploadTask = imageRef.putData(_coverImageBytes!, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          uploadTask = imageRef.putFile(_coverImageFile!);
        }
        final snapshot = await uploadTask;
        coverImageUrl = await snapshot.ref.getDownloadURL();
      } catch (e) {
        // Handle upload error if desired
      }
    }

    try {
      final chapterData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'entryIDs': [],
        'image': coverImageUrl ?? '',
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('chapters')
          .add(chapterData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Chapter created successfully")),
      );

      _nameController.clear();
      _descriptionController.clear();
      setState(() {
        _coverImageFile = null;
        _coverImageBytes = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error creating chapter")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Chapter')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name & description
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Chapter Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Chapter Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Pick + preview
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickCoverImage,
                  child: const Text('Pick a Cover Image'),
                ),
                const SizedBox(width: 12),
                if (_coverImageFile != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _coverImageFile!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (_coverImageBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      _coverImageBytes!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
              ],
            ),

            const SizedBox(height: 24),
            Center(
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveChapter,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        child: Text('Save Chapter'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
