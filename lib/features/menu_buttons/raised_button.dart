import 'package:flutter/material.dart';

/// A custom, unique, and eloquent button for the Journal App.
/// This widget provides a gradient background, elevation, and ripple effect,
/// making it perfect for buttons throughout the app.
class RaiseButton extends StatelessWidget {
  /// Callback executed when the button is tapped
  final VoidCallback onPressed;

  /// The label text of the button
  final String label;

  /// Optional icon displayed before the label
  final IconData? icon;

  /// Padding inside the button
  final EdgeInsetsGeometry padding;

  /// Corner radius of the button
  final double borderRadius;

  /// Elevation for the shadow effect
  final double elevation;


  const RaiseButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 24.0),
    this.borderRadius = 16.0,
    this.elevation = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Example usage:
// RaiseButton(
//   onPressed: () { /* Navigate to add entry screen */ },
//   icon: Icons.edit,
//   label: 'New Entry',
// ),
