import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:journal/providers/user_provider.dart';
import 'package:provider/provider.dart';

/// Provides dynamic theming including primary, secondary,
/// background colors and light/dark mode toggle.
class ThemeProvider extends ChangeNotifier {
  Color _primary     = Colors.blue;
  Color _secondary   = Colors.pink;
  Color _background  = Colors.white;
  Color _background2 = Colors.grey.shade200;
  bool  _isDarkMode  = false;

  Color get primary     => _primary;
  Color get secondary   => _secondary;
  Color get background  => _background;
  Color get background2 => _background2;
  bool  get isDarkMode  => _isDarkMode;

  /// Two-color gradient for your backgrounds
  List<Color> get backgroundGradientColors => [ _background, _background2 ];

  ThemeData get themeData {
    final scheme = _isDarkMode
      ? ColorScheme.dark(
          primary:   _primary,
          secondary: _secondary,
          surface:    _background,
        )
      : ColorScheme.light(
          primary:   _primary,
          secondary: _secondary,
          surface:    _background,
        );

    return ThemeData(
      colorScheme:          scheme,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        iconTheme:       IconThemeData(color: scheme.onSurface),
        titleTextStyle:  TextStyle(
          color:     scheme.onSurface,
          fontSize:  20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: _isDarkMode
        ? Typography.whiteMountainView.apply(bodyColor: scheme.onSurface)
        : Typography.blackMountainView.apply(bodyColor: scheme.onSurface),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
    );
  }

  void updatePrimary(Color c)   { _primary   = c; notifyListeners(); }
  void updateSecondary(Color c) { _secondary = c; notifyListeners(); }
  void updateBackground(Color c){ _background = c; notifyListeners(); }
  void updateBackground2(Color c){ _background2 = c; notifyListeners(); }

  Color _colorFrom(dynamic source, Color fallback) {
    if (source is int) {
      return Color(source);
    }
    if (source is String) {
      // strip any leading ‘#’
      String hex = source.replaceAll('#', '');
      // if they only gave RRGGBB, assume FF for alpha:
      if (hex.length == 6) hex = 'FF$hex';
      try {
        return Color(int.parse(hex, radix: 16));
      } catch (_) {
        return fallback;
      }
    }
    return fallback;
  }

  /// Load preferences from Firestore map (can contain ints or hex strings)
  Future<void> loadPreferences(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final prefs = doc.data()?['preferences'] as Map<String, dynamic>?;

    if (prefs != null) {
      _isDarkMode  = prefs['isDarkMode']  ?? _isDarkMode;
      _primary     = _colorFrom(prefs['primary'],     _primary);
      _secondary   = _colorFrom(prefs['secondary'],   _secondary);
      _background  = _colorFrom(prefs['background'],  _background);
      _background2 = _colorFrom(prefs['background2'], _background2);
      notifyListeners();
    }
  }

  /// Load preferences from a Map (e.g., from Firestore)
  void loadFromMap(Map<String, dynamic> prefs) {
    _isDarkMode  = prefs['isDarkMode'] ?? false;
    _primary     = prefs['primary']    != null ? Color(prefs['primary'])     : Colors.blue;
    _secondary   = prefs['secondary']  != null ? Color(prefs['secondary'])   : Colors.pink;
    _background  = prefs['background'] != null ? Color(prefs['background'])  : Colors.white;
    _background2 = prefs['background2']!= null ? Color(prefs['background2']) : Colors.grey.shade200;
    notifyListeners();
  }

  /// Toggle light/dark mode *and* reset the background colors
  void toggleDarkMode(bool val) {
    _isDarkMode = val;

    if (_isDarkMode) {
      // Dark‐mode defaults
      _background  = Colors.grey.shade900;
      _background2 = Colors.grey.shade800;
    } else {
      // Light‐mode defaults
      _background  = Colors.white;
      _background2 = Colors.grey.shade200;
    }

    notifyListeners();
  }
}


/// A page allowing users to pick colors, toggle dark mode,
/// and save their preferences to Firestore.
class ThemeCustomizerSection extends StatelessWidget {
  const ThemeCustomizerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProv = context.watch<ThemeProvider>();
    final theme     = Theme.of(context);
    final userProv  = context.watch<UserProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          // Dark Mode Toggle
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: themeProv.isDarkMode,
            onChanged: themeProv.toggleDarkMode,
            secondary: Icon(
              themeProv.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
          ),
          const Divider(),

          // Primary Color Picker
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Primary Color'),
            trailing: CircleAvatar(backgroundColor: themeProv.primary),
            onTap: () => _showColorPicker(
              context,
              'Pick Primary Color',
              themeProv.primary,
              themeProv.updatePrimary,
            ),
          ),
          // Secondary Color Picker
          ListTile(
            leading: const Icon(Icons.color_lens_outlined),
            title: const Text('Secondary Color'),
            trailing: CircleAvatar(backgroundColor: themeProv.secondary),
            onTap: () => _showColorPicker(
              context,
              'Pick Secondary Color',
              themeProv.secondary,
              themeProv.updateSecondary,
            ),
          ),
          // Background Color Picker
          ListTile(
            leading: const Icon(Icons.format_color_fill),
            title: const Text('Background Color'),
            trailing: CircleAvatar(backgroundColor: themeProv.background),
            onTap: () => _showColorPicker(
              context,
              'Pick Background Color',
              themeProv.background,
              themeProv.updateBackground,
            ),
          ),
          // Gradient Second Color Picker
          ListTile(
            leading: const Icon(Icons.gradient),
            title: const Text('Gradient 2nd Color'),
            trailing: CircleAvatar(backgroundColor: themeProv.background2),
            onTap: () => _showColorPicker(
              context,
              'Pick Gradient Second Color',
              themeProv.background2,
              themeProv.updateBackground2,
            ),
          ),
          const Divider(),

          // Save Preferences Button
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Preferences'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final uid = userProv.userId;
                if (uid == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Not signed in')),
                  );
                  return;
                }

                try {
                  await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .set({
                      'preferences': {
                        'isDarkMode' : themeProv.isDarkMode,
                        'primary'    : themeProv.primary.toHexString(),
                        'secondary'  : themeProv.secondary.toHexString(),
                        'background' : themeProv.background.toHexString(),
                        'background2': themeProv.background2.toHexString(),
                      }
                    }, SetOptions(merge: true));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Preferences saved!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Save failed: $e')),
                  );
                }
              },
            ),
          ),
        ],
    );
  }

  void _showColorPicker(
    BuildContext context,
    String title,
    Color initial,
    ValueChanged<Color> onColorSelected,
  ) {
    Color pickerColor = initial;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            pickerAreaHeightPercent: 0.7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onColorSelected(pickerColor);
              Navigator.of(ctx).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }
}
