import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:journal/features/pictures/full_picture_modal.dart';
import 'package:image_picker/image_picker.dart';

class ViewChosenImages extends StatefulWidget {
  final List<String> chosenPhotoPaths;

  const ViewChosenImages({super.key, required this.chosenPhotoPaths});

  @override
  State<ViewChosenImages> createState() => _ViewChosenImagesState();
}

class _ViewChosenImagesState extends State<ViewChosenImages> {
  final CarouselController controller = CarouselController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  Widget _buildImage(XFile xfile) {
  if (kIsWeb) {
    // On Web: read the bytes and paint with Image.memory
    return FutureBuilder<Uint8List>(
      future: xfile.readAsBytes(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Image.memory(
          snap.data!,
          fit: BoxFit.cover,
          height: 400,
          width: double.infinity,
        );
      },
    );
  } else {
    // On mobile/desktop: you have a real file path
    return Image.file(
      File(xfile.path),
      fit: BoxFit.cover,
      height: 400,
      width: double.infinity,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height / 2),
      child: CarouselView.weighted(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemSnapping: true,
        flexWeights: const <int>[3, 7, 3],
        children: List<Widget>.generate(widget.chosenPhotoPaths.length, (int index) {
          final imagePath = widget.chosenPhotoPaths[index];

          return Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onTap: () {
                  // Open the image in full view when tapped
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return FullPictureModal(imageFile: imagePath);
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).toInt()),

                        spreadRadius: 2,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: _buildImage(XFile(widget.chosenPhotoPaths[index]))
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
