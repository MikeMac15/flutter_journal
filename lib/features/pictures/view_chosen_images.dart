import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/pictures/full_picture_modal.dart';

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
    final double height = MediaQuery.of(context).size.height;

    // If you want equal “flex weight” for every image, do this:
    final List<int> equalWeights =
        List<int>.filled(widget.chosenPhotoPaths.length, 1);

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height / 2),
      child: CarouselView.weighted(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemSnapping: true,

        // Either omit flexWeights entirely, OR use equalWeights:
        // flexWeights: equalWeights,

        // (If you comment out flexWeights, the default is “1 per child.”)
        flexWeights: equalWeights,

        onTap: (int index) {
          Navigator.of(context).push(
            fadeRoute(
              FullscreenImageView(
                imageFile: XFile(widget.chosenPhotoPaths[index]),
              ),
              duration: const Duration(milliseconds: 600),
            ),
          );
        },
        children: List<Widget>.generate(
          widget.chosenPhotoPaths.length,
          (int index) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha((0.2 * 255).toInt()),
                      spreadRadius: 2,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: _buildImage(
                  XFile(widget.chosenPhotoPaths[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
