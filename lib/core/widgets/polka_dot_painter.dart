import 'package:flutter/material.dart';

/// Custom Painter to draw delicate, subtle baby blue polka dots matching the reference image
class WelcomePolkaDotPainter extends CustomPainter {
  const WelcomePolkaDotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC7DCF0)
      ..style = PaintingStyle.fill;

    const double spacing = 26.0;
    const double radius = 1.3;

    for (double y = spacing / 2; y < size.height; y += spacing) {
      for (double x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
