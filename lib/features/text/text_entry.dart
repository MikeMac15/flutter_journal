// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
// import 'package:journal/features/text/web_textfield.dart';


class TextEntry extends StatelessWidget {
  final bool isMultiLine;
  final TextEditingController controller;
  final String labelText;
  final ValueChanged<String>? onChanged;

  const TextEntry({
    super.key,
    required this.isMultiLine,
    required this.controller,
    this.labelText = 'Write here…',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final textStyle = theme.textTheme.bodyMedium!;
    final fillColor = theme.colorScheme.surface;
    final borderColor = theme.colorScheme.onSurface.withOpacity(0.5);

    // if (kIsWeb && isMultiLine) {
    //   return Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(labelText, style: theme.textTheme.bodyMedium),
    //       const SizedBox(height: 8),
    //       WebSpellTextarea(
    //         initialText: controller.text,
    //         height: 150,
    //         textStyle: textStyle,
    //         fillColor: fillColor,
    //         borderColor: borderColor,
    //         onChanged: (val) {
    //           controller.text = val;
    //           onChanged?.call(val);
    //         },
    //       ),
    //     ],
    //   );
    // }

    return TextField(
      controller: controller,
      maxLines: isMultiLine ? null : 1,
      autocorrect: true,
      enableSuggestions: true,
      textCapitalization: TextCapitalization.sentences,
      style: theme.textTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: fillColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
            vertical: 12, horizontal: 16),
      ),
      onChanged: onChanged,
    );
  }
}
