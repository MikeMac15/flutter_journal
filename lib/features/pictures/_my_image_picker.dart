import 'dart:async';

import 'package:image_picker/image_picker.dart';

class MyImagePicker {
  final ImagePicker _picker = ImagePicker();

  /// Pick a single image from gallery.
  /// Returns the local file path, or null if the user canceled or an error occurred.
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 60,
      );
      return image?.path;
    } catch (e) {
      return null;
    }
  }

  /// Take a picture with the camera.
  /// Returns the local file path, or null if canceled or error.
  Future<String?> takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 60,
      );
      return image?.path;
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple images from gallery.
  /// Returns a (possibly empty) list of file paths.
  Future<List<String>> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage();
      return picked.map((xfile) => xfile.path).toList();
    } catch (e) {
      return [];
    }
  }
}
