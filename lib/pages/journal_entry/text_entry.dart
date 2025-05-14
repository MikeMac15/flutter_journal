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
  @override
  void initState() {
    super.initState();
    if (widget.onChanged != null) widget.controller.addListener(_onChange);
  }

  void _onChange() {
    widget.onChanged?.call(widget.controller.text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 245, 230), // aged paper
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.brown.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // horizontal ruled lines
          Positioned.fill(
            child: CustomPaint(
              painter: _PageLinesPainter(),
            ),
          ),
          TextField(
            controller: widget.controller,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            maxLines: widget.isMultiLine ? null : 1,
            expands: widget.isMultiLine,
            keyboardType: widget.isMultiLine ? TextInputType.multiline : TextInputType.text,
            textInputAction: widget.isMultiLine ? TextInputAction.newline : TextInputAction.done,
            cursorColor: Colors.brown,
            style: const TextStyle(
              fontFamily: 'Caveat', // cursive handwriting font
              fontSize: 18,
              color: Colors.brown,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 18,
                color: Colors.brown.shade200,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: widget.onChanged,
          ),
        ],
      ),
    );
  }
}

class _PageLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade200
      ..strokeWidth = 1;
    const double gap = 30;
    for (double y = gap; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
