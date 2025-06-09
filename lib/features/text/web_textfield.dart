// lib/widgets/web_spell_textarea.dart

import 'dart:html' as html;         // ignore: avoid_web_libraries_in_flutter
import 'dart:ui' as ui;             

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// A themed HTML <textarea> that enables browser spellcheck + autocorrect
/// on Flutter Web, and otherwise is a no‐op on mobile/desktop.
class WebSpellTextarea extends StatefulWidget {
  final String initialText;
  final ValueChanged<String>? onChanged;
  final double height;
  final TextStyle textStyle;
  final Color fillColor;
  final Color borderColor;

  const WebSpellTextarea({
    super.key,
    this.initialText = '',
    this.onChanged,
    this.height = 150,
    required this.textStyle,
    required this.fillColor,
    required this.borderColor,
  });

  @override
  State<WebSpellTextarea> createState() => _WebSpellTextareaState();
}

class _WebSpellTextareaState extends State<WebSpellTextarea> {
  late html.TextAreaElement _textarea;
  late String _viewType;

  @override
  void initState() {
    super.initState();

    // Only register on Web; on other platforms, skip entirely.
    if (kIsWeb) {
      // 1) Generate a unique viewType ID
      _viewType = 'web-spell-textarea-${DateTime.now().millisecondsSinceEpoch}';

      // 2) Register the platform view factory for this viewType.
      //    ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
        _textarea = html.TextAreaElement()
          ..style
            ..style.width = '100%'
            ..style.height = '${widget.height}px'
            ..style.padding = '8px'
            ..style.boxSizing = 'border-box'
            ..style.background = _colorToCss(widget.fillColor)
            ..style.border = '1px solid ${_colorToCss(widget.borderColor)}'
            ..style.borderRadius = '4px'
            ..style.outline = 'none'
            ..style.fontSize = '${widget.textStyle.fontSize ?? 16}px'
            ..style.fontFamily = widget.textStyle.fontFamily ?? 'sans-serif'
            ..style.color = _colorToCss(widget.textStyle.color ?? Colors.black);

        // Enable browser spellcheck + mobile autocorrect/autocapitalize:
        _textarea
          ..spellcheck = true
          ..autocapitalize = 'sentences'
          ..setAttribute('autocorrect', 'on')
          ..value = widget.initialText
          ..onInput.listen((_) {
            widget.onChanged?.call(_textarea.value ?? '');
          });

        return _textarea;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show the HTML <textarea> on Web.
    if (!kIsWeb) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: HtmlElementView(viewType: _viewType),
    );
  }

  String _colorToCss(Color color) {
    // Convert a Flutter Color to a CSS hex string (#RRGGBB).
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
