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

  final fontSize = 16.0;

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
    
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      color: Colors.transparent,
      child: Ink(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withOpacity(.5)
              : Colors.white.withOpacity(0.5), // semi-transparent base
          gradient: RadialGradient(
  center: Alignment.center,
  radius: 5, // Controls spread – tweak for visual effect
  colors: isDark
      ? [
          Colors.grey[800]!,
          Colors.grey[900]!,
          
        ]
      : [
          Colors.white,
          Colors.grey[100]!,
          
        ],
  
),
          border: Border.all(
            color: isDark
                ? Colors.black.withOpacity(0.4) // subtle border
                : Colors.white.withOpacity(0.4),
            width: 1.2,
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
                  Icon(icon, size: fontSize + 6, ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
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
