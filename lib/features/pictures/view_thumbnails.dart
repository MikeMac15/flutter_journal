import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:journal/features/_fade_route.dart';
import 'package:journal/features/pictures/full_picture_modal.dart';

class ViewThumbnailImages extends StatelessWidget {
  final List<Object> photoSources; // can be XFile or String

  const ViewThumbnailImages({super.key, required this.photoSources});

  @override
  Widget build(BuildContext context) {
    final List<XFile> xFiles = photoSources.map((item) {
      if (item is XFile) return item;
      if (item is String) return XFile(item);
      throw Exception('Invalid photo type: $item');
    }).toList();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: xFiles.length,
        itemBuilder: (context, index) {
          final xfile = xFiles[index];

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                fadeRoute(
                  FullscreenImageView(imageFile: xfile),
                  duration: const Duration(milliseconds: 500),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: kIsWeb
                    ? FutureBuilder<Uint8List>(
                        future: xfile.readAsBytes(),
                        builder: (ctx, snapshot) {
                          if (!snapshot.hasData) {
                            return const SizedBox(
                              height: 80,
                              width: 80,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          return Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            height: 80,
                            width: 80,
                          );
                        },
                      )
                    : Image.file(
                        File(xfile.path),
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
