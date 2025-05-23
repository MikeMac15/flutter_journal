// lib/routes/fade_route.dart
import 'package:flutter/material.dart';

/// Returns a [PageRoute] that fades [page] in/out.
/// 
/// You can optionally pass a custom [duration].
Route<T> fadeRoute<T>(
  Widget page, {
  Duration duration = const Duration(milliseconds: 250),
}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: duration,
    reverseTransitionDuration: duration,
  );
}