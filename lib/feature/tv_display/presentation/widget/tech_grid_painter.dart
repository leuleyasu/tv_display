import 'package:flutter/material.dart';

class TechGridPainter extends CustomPainter {
  final Color color;
  final double step;
  final double strokeWidth;

  TechGridPainter({
    required this.color,
    this.step = 40.0,
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    for (double i = 0; i <= size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant TechGridPainter oldDelegate) =>
      color != oldDelegate.color ||
      step != oldDelegate.step ||
      strokeWidth != oldDelegate.strokeWidth;
}
