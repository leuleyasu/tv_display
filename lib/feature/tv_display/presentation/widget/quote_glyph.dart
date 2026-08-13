import 'dart:math';
import 'package:flutter/material.dart';

/// Quote Glyph with CustomPainter for message callouts.
class QuoteGlyph extends StatelessWidget {
  final Color color;
  final double size;
  final Alignment align;

  const QuoteGlyph({
    super.key,
    required this.color,
    required this.size,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: QuotePainter(
            color: color,
            flip: align == Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class QuotePainter extends CustomPainter {
  final Color color;
  final bool flip;

  QuotePainter({required this.color, required this.flip});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    if (flip) {
      canvas.translate(size.width, size.height);
      canvas.rotate(pi);
    }
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..strokeWidth = size.width * 0.14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final p1 = Path()
      ..moveTo(size.width * 0.62, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.20,
        size.width * 0.30,
        size.height * 0.55,
      )
      ..lineTo(size.width * 0.55, size.height * 0.85);
    final p2 = Path()
      ..moveTo(size.width * 0.95, size.height * 0.20)
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.20,
        size.width * 0.62,
        size.height * 0.55,
      )
      ..lineTo(size.width * 0.88, size.height * 0.85);
    canvas.drawPath(p1, paint);
    canvas.drawPath(p2, paint);
    final glow = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(p1, glow);
    canvas.drawPath(p2, glow);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant QuotePainter old) =>
      old.color != color || old.flip != flip;
}
