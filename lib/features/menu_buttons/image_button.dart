import 'dart:ui';

import 'package:flutter/material.dart';

/// A larger button intended to occupy its own row, with a background image.
class LargeImageButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final ImageProvider backgroundImage;
  final double height;
  final double borderRadius;

  const LargeImageButton({
    Key? key,
    required this.title,
    required this.onPressed,
    required this.backgroundImage,
    this.height = 120,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(
              image: backgroundImage,
              fit: BoxFit.cover,
            ),
            Material(
              color: Colors.black.withOpacity(0.3),
              child: InkWell(
                onTap: onPressed,
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black54,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A smaller button intended to be placed side-by-side with others, with a background image.

/// A smaller button intended to be placed side-by-side with others,
/// with a blurred background image.
class SmallImageButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final ImageProvider backgroundImage;
  final double width;
  final double height;
  final double borderRadius;

  const SmallImageButton({
    super.key,
    required this.title,
    required this.onPressed,
    required this.backgroundImage,
    this.width = 80,
    this.height = 40,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,                            // ← this will always be 40
      clipBehavior: Clip.hardEdge,               
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Stack(fit: StackFit.expand, children: [
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Image(image: backgroundImage, fit: BoxFit.cover),
        ),
        Material(
          color: Colors.black.withOpacity(0.2),
          child: InkWell(
            onTap: onPressed,
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,      // smaller text to fit 40px height
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}