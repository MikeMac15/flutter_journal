import 'dart:io';
import 'package:flutter/material.dart';

class FullPictureModal extends StatelessWidget {
  final String imageFile;

  const FullPictureModal({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.file(
          File(imageFile),
          fit: BoxFit.contain, // Fit the image properly
        ),
      ),
    );
  }
}
