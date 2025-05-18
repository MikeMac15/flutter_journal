import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FullscreenImageView extends StatelessWidget {
  final XFile imageFile;

  const FullscreenImageView({Key? key, required this.imageFile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: kIsWeb
            ? FutureBuilder<Uint8List>(
                future: imageFile.readAsBytes(),
                builder: (ctx, snap) {
                  if (!snap.hasData) {
                    return const CircularProgressIndicator(color: Colors.white);
                  }
                  return Image.memory(
                    snap.data!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  );
                },
              )
            : Image.file(
                File(imageFile.path),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
      ),
    );
  }
}