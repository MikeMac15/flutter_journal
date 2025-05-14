import 'dart:async';

import 'package:image_picker/image_picker.dart';

class MyImagePicker {
  final ImagePicker _picker = ImagePicker();

  // pick the image
  Future<String?> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) return image.path;
    return null;
  }

  Future<List<String>?> pickMultipleImagesFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage();
    final List<String> imagePaths = [];
    for (var image in images){
      imagePaths.add(image.path);
    }
    // print(imagePaths);
    return imagePaths;
  }

  Future<String?> takePictureWithCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) return image.path;
    return null;
  }
}