import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Message frame with animated corner brackets and scan line effect.
class MessageFrame extends StatelessWidget {
  final Widget child;
  final Color accent;
  final Color accentDeep;
  final double drawProgress;
  final double scanProgress;
  final bool isVip;
  final double borderRadius;

  const MessageFrame({
    super.key,
    required this.child,
    required this.accent,
    required this.accentDeep,
    required this.drawProgress,
    required this.scanProgress,
    required this.isVip,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E1A).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isVip ? 0.35 : 0.25),
                blurRadius: isVip ? 60 : 40,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.6),
                        radius: 1.1,
                        colors: [
                          accent.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ScanLinePainter(
                      progress: scanProgress,
                      color: accent,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: CornerBracketsPainter(
                      progress: drawProgress,
                      color: accent,
                      colorDeep: accentDeep,
                      radius: borderRadius,
                      isVip: isVip,
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class CornerBracketsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color colorDeep;
  final double radius;
  final bool isVip;

  CornerBracketsPainter({
    required this.progress,
    required this.color,
    required this.colorDeep,
    required this.radius,
    required this.isVip,
  });

  static const double _armLong = 90;
  static const double _armShort = 36;
  static const double _thickness = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    const cornerCount = 4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = _thickness
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = _thickness + 4
      ..strokeCap = StrokeCap.square
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke;

    void drawArm(Offset from, Offset to, double p) {
      if (p <= 0) return;
      final end = Offset.lerp(from, to, p.clamp(0.0, 1.0))!;
      canvas.drawLine(from, end, glowPaint);
      canvas.drawLine(from, end, paint);
    }

    final r = radius;
    final corners = <CornerOrigin>[
      CornerOrigin(Offset(r, 0), const Offset(1, 0), const Offset(0, 1)),
      CornerOrigin(
          Offset(size.width - r, 0), const Offset(-1, 0), const Offset(0, 1)),
      CornerOrigin(
          Offset(r, size.height), const Offset(1, 0), const Offset(0, -1)),
      CornerOrigin(Offset(size.width - r, size.height), const Offset(-1, 0),
          const Offset(0, -1)),
    ];

    for (int i = 0; i < cornerCount; i++) {
      final c = corners[i];
      final local = ((progress - i * 0.08) / 0.68).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final longP = (local / 0.65).clamp(0.0, 1.0);
      final shortP = ((local - 0.65) / 0.35).clamp(0.0, 1.0);
      final longEnd = c.origin + c.longDir * _armLong;
      final shortEnd = c.origin + c.shortDir * _armShort;
      drawArm(c.origin, longEnd, longP);
      drawArm(c.origin, shortEnd, shortP);
      if (local >= 1.0) {
        final dotPaint = Paint()
          ..color = isVip ? Colors.white : color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(c.origin, 4, dotPaint);
        canvas.drawCircle(c.origin, 2.5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CornerBracketsPainter old) =>
      old.progress != progress || old.color != color || old.isVip != isVip;
}

class CornerOrigin {
  final Offset origin;
  final Offset longDir;
  final Offset shortDir;
  const CornerOrigin(this.origin, this.longDir, this.shortDir);
}

class ScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.35),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 2));
    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), paint);
  }

  @override
  bool shouldRepaint(covariant ScanLinePainter old) =>
      old.progress != progress || old.color != color;
}

class GoldSweepPainter extends CustomPainter {
  final double progress;
  final Color goldAccent;

  GoldSweepPainter({
    required this.progress,
    this.goldAccent = const Color(0xFFFFD24A),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(-1.0 + progress * 2, 0),
        end: Alignment(0.0 + progress * 2, 0),
        colors: [
          Colors.transparent,
          goldAccent.withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant GoldSweepPainter old) =>
      old.progress != progress;
}
