

import 'package:flutter/material.dart';

class TextEntry extends StatefulWidget {
  final bool isMultiLine;
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;

  const TextEntry({
    super.key,
    required this.isMultiLine,
    required this.controller,
    this.hintText = 'Write here…',
    this.onChanged,
  });

  @override
  State<TextEntry> createState() => _TextEntryState();
}

class _TextEntryState extends State<TextEntry> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    if (widget.onChanged != null) widget.controller.addListener(_onChange);
  }

  void _onChange() => widget.onChanged?.call(widget.controller.text);

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        maxLines: widget.isMultiLine ? null : 1,
        expands: widget.isMultiLine,
        keyboardType: widget.isMultiLine
            ? TextInputType.multiline
            : TextInputType.text,
        textInputAction:
            widget.isMultiLine ? TextInputAction.newline : TextInputAction.done,
        cursorColor: accent,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.hintColor),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
