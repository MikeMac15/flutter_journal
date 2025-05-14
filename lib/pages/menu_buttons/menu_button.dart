import 'package:flutter/material.dart';

class MenuButton extends StatelessWidget {
  final List<double> boxSizeMultipliers; // [width, height]
  final String title;
  final IconData icon;
  final double sizeOfFont;
  final Color textColor;
  final Color color1;
  final Color color2;
  final Color? color3;
  final Widget targetPage; // New parameter for the page to navigate to

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
    required this.targetPage, // Required parameter for navigation
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the target page when tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * boxSizeMultipliers[0],
        height: MediaQuery.of(context).size.height * boxSizeMultipliers[1],
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: color3 != null ? [color1, color2, color3!] : [color1, color2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.2 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // You had this as start
            children: [
              Icon(
                icon,
                color: textColor,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: sizeOfFont,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}