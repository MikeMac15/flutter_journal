import 'package:flutter/material.dart';

class MenuButton extends StatefulWidget {
  final List<double> boxSizeMultipliers; // [width, height]
  final String title;
  final IconData icon;
  final double sizeOfFont;
  final Color textColor;
  final Color color1;
  final Color color2;
  final Color? color3;
  final Widget targetPage; // Page to navigate to

  const MenuButton({
    super.key,
    required this.boxSizeMultipliers,
    required this.title,
    required this.icon,
    required this.sizeOfFont,
    required this.textColor,
    required this.color1,
    required this.color2,
    this.color3,
    required this.targetPage,
  });

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  bool _isPressed = false;

  void _navigate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => widget.targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scale down slightly when pressed
    final scaleValue = _isPressed ? 0.97 : 1.0;

    return Material(
      color: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(scaleValue, scaleValue),
        curve: Curves.easeOut,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _navigate,
          onHighlightChanged: (value) {
            setState(() => _isPressed = value);
          },
          child: Container(
            width: MediaQuery.of(context).size.width * widget.boxSizeMultipliers[0],
            height: MediaQuery.of(context).size.height * widget.boxSizeMultipliers[1],
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.color3 != null
                    ? [widget.color1, widget.color2, widget.color3!]
                    : [widget.color1, widget.color2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: _isPressed ? 4 : 8,
                  offset: Offset(0, _isPressed ? 2 : 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  color: widget.textColor,
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.sizeOfFont,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
