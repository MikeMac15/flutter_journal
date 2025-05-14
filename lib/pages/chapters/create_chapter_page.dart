import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CreateChapterPage extends StatefulWidget {
  const CreateChapterPage({super.key});

  @override
  CreateChapterPageState createState() => CreateChapterPageState();
}

class CreateChapterPageState extends State<CreateChapterPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _coverImage;
  bool _isUploading = false;

  Future<void> _pickCoverImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _coverImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChapter() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      // Show an error if required fields are missing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all the fields")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    String? coverImageUrl;
    if (_coverImage != null) {
      // Upload the cover image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageRef = storageRef.child('chapter_covers/$fileName');

      try {
        final uploadTask = await imageRef.putFile(_coverImage!);
        coverImageUrl = await uploadTask.ref.getDownloadURL(); // Get the URL of the uploaded image
      } catch (e) {
        // print("Error uploading image: $e");
      }
    }

    // Save the chapter data to Firestore
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
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

      setState(() {
        _isUploading = false;
      });

      // Show success message and clear fields
   if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Chapter created successfully")),
  );
}
      _nameController.clear();
      _descriptionController.clear();
      setState(() {
        _coverImage = null;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (mounted) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Error creating chapter")),
  );
}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Chapter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter name input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Chapter Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Chapter description input
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Chapter Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Image picker button
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickCoverImage,
                  child: const Text('Pick a Cover Image'),
                ),
                const SizedBox(width: 10),
                if (_coverImage != null)
                  Image.file(
                    _coverImage!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // Save button
            _isUploading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveChapter,
                    child: const Text('Save Chapter'),
                  ),
          ],
        ),
      ),
    );
  }
}
