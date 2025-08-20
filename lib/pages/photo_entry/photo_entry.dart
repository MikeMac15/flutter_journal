import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:journal/pages/journal_view_page.dart';
import 'package:provider/provider.dart';
import 'package:exif/exif.dart';

// --- Import your project's files ---
import 'package:journal/providers/db_provider.dart';
import 'package:journal/pages/journal_entry/chapter_selector.dart';


class PhotoEntryPage extends StatefulWidget {
  const PhotoEntryPage({super.key});

  @override
  State<PhotoEntryPage> createState() => _PhotoEntryPageState();
}

class _PhotoEntryPageState extends State<PhotoEntryPage> {
  // ... your existing state variables ...
  final List<ImageWithMetadata> _chosenPhotos = [];
  DateTime _entryDate = DateTime.now();
  String? _selectedChapterId;
  bool _isLoading = false;

  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();


  // ... your existing functions (_pickImages, _extractMetadata, etc.) ...

  @override
  Widget build(BuildContext context) {
    // ... your existing build method structure ...
    // The only change is inside the GridView builder, so the rest of your
    // build method remains the same.
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Photo Entry'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _savePhotoEntry,
            child: _isLoading ? const CircularProgressIndicator(strokeWidth: 2) : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_chosenPhotos.isEmpty)
              _buildImagePickerPrompt()
            else
              _buildImageGrid(), // This now uses the corrected logic
            
            const SizedBox(height: 16),
            
            if (_chosenPhotos.isNotEmpty)
              OutlinedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Add More Photos'),
                onPressed: _pickImages,
              ),

            const SizedBox(height: 24),

            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Brief Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMMd().format(_entryDate)),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text("Chapter"),
                subtitle: Text(_selectedChapterId != null
                    ? (Provider.of<DBProvider>(context, listen: false).getChapterById(_selectedChapterId!)?.name ?? "Unknown")
                    : "Select a chapter"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => ChapterSelector(onChapterSelected: _handleChapterSelected),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... your other widgets (_buildImagePickerPrompt) ...

  // ############ CORRECTED WIDGET ############
  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _chosenPhotos.length,
      itemBuilder: (context, index) {
        final imageFile = _chosenPhotos[index].file;

        // Platform-specific image loading
        if (kIsWeb) {
          // For Web, use Image.network on the file's path,
          // as image_picker provides a blob URL.
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              imageFile.path,
              fit: BoxFit.cover,
              // Add loading and error builders for a better UX
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red);
              },
            ),
          );
        } else {
          // For Mobile (iOS/Android), Image.file is correct and efficient.
          return ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              File(imageFile.path),
              fit: BoxFit.cover,
            ),
          );
        }
      },
    );
  }

  // --- Functions from your original code for context ---

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      for (final file in pickedFiles) {
        final metadata = await _extractMetadata(file);
        setState(() {
          _chosenPhotos.add(ImageWithMetadata(file: file, metadata: metadata));
        });
      }

      final firstPhotoDate = _chosenPhotos.first.metadata['dateTaken'];
      if (firstPhotoDate != null) {
        setState(() {
          _entryDate = DateTime.tryParse(firstPhotoDate) ?? DateTime.now();
        });
      }
    }
  }

  Future<Map<String, dynamic>> _extractMetadata(XFile file) async {
    final Map<String, dynamic> extractedMetadata = {};
    try {
      final fileBytes = await file.readAsBytes();
      final exifData = await readExifFromBytes(fileBytes);
      if (exifData.isEmpty) return {};

      final model = exifData['Image Model'];
      if (model != null) extractedMetadata['device'] = model.toString();

      final dateTimeOriginal = exifData['EXIF DateTimeOriginal'];
      if (dateTimeOriginal != null) {
        final parsedDate = DateFormat("yyyy:MM:dd HH:mm:ss").parse(dateTimeOriginal.toString());
        extractedMetadata['dateTaken'] = parsedDate.toIso8601String();
      }
      final gpsLatitude = exifData['GPS Latitude'];
      final gpsLongitude = exifData['GPS Longitude'];
      if (gpsLatitude != null && gpsLongitude != null) {
        extractedMetadata['gps'] = {
          'latitude': gpsLatitude.toString(),
          'longitude': gpsLongitude.toString(),
        };
      }
      

      return extractedMetadata;
    } catch (e) {
      print("Error reading metadata: $e");
      return {};
    }
  }

  void _handleChapterSelected(String? chapterId, String? chapterName) {
    setState(() => _selectedChapterId = chapterId);
  }

  Future<void> _savePhotoEntry() async {
    if (_chosenPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one photo.')));
      return;
    }
    if (_selectedChapterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a chapter.')));
      return;
    }

    setState(() => _isLoading = true);
    final dbProvider = Provider.of<DBProvider>(context, listen: false);

    try {
      final newEntryId = await dbProvider.savePhotoEntry(
        imageFilesWithMetadata: _chosenPhotos,
        entry: _captionController.text,
        date: _entryDate,
        chapterId: _selectedChapterId!,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => JournalEntryViewPage(entryId: newEntryId)),
          (Route<dynamic> route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving photo entry: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildImagePickerPrompt() {
    return GestureDetector(
      onTap: _pickImages,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400, width: 2),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_rounded, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Tap to select photos'),
            ],
          ),
        ),
      ),
    );
  }
}
