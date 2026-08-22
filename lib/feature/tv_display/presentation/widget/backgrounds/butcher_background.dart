import 'dart:math';
import 'package:flutter/material.dart';

/// Ultra-Modern Dark Cast-Iron, Sizzling Ember & Warm Amber Background for Butcher House TV Signage.
/// Designed specifically for Ethiopian Butcher Houses (ሥጋ ቤት) like Yonas Chercher.
class ButcherBackground extends StatelessWidget {
  final BoxConstraints box;
  final Animation<double> orbAnim;
  final String orgName;
  final DateTime now;
  final bool showEmbers;

  const ButcherBackground({
    super.key,
    required this.box,
    required this.orbAnim,
    required this.orgName,
    required this.now,
    this.showEmbers = true,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
    const primaryEmber = Color(0xFFEF4444);
    const warmAmber = Color(0xFFF59E0B);
    const castIronDark = Color(0xFF0C0908);

    return Stack(
      children: [
        // 1. Deep Cast Iron Radial Gradient
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.3, -0.3),
                radius: 1.5,
                colors: [
                  Color(0xFF221715), // Warm cast-iron center
                  Color(0xFF140D0C), // Dark charcoal mid
                  castIronDark,      // Deep slate base
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // 2. Animated Ember Glow Orb 1 (Top Left / Behind Hero Spotlight)
        AnimatedBuilder(
          animation: orbAnim,
          builder: (context, child) {
            final offset = (orbAnim.value - 0.5) * 30 * scale;
            return Positioned(
              top: -80 * scale + offset,
              left: box.maxWidth * 0.08,
              width: 650 * scale,
              height: 500 * scale,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primaryEmber.withValues(alpha: 0.14),
                      const Color(0xFF991B1B).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            );
          },
        ),

        // 3. Animated Spiced Butter / Amber Glow Orb 2 (Center Right / Behind Rate HUD)
        AnimatedBuilder(
          animation: orbAnim,
          builder: (context, child) {
            final offset = (0.5 - orbAnim.value) * 25 * scale;
            return Positioned(
              bottom: 40 * scale + offset,
              right: box.maxWidth * 0.15,
              width: 700 * scale,
              height: 450 * scale,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      warmAmber.withValues(alpha: 0.12),
                      const Color(0xFFB45309).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            );
          },
        ),

        // 4. Subtle Texture Grid Lines
        Positioned.fill(
          child: CustomPaint(
            painter: _ButcherGridPainter(scale: scale),
          ),
        ),
      ],
    );
  }
}

class _ButcherGridPainter extends CustomPainter {
  final double scale;

  _ButcherGridPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.015)
      ..strokeWidth = 1.0 * scale
      ..style = PaintingStyle.stroke;

    const step = 80.0;
    for (double x = 0; x < size.width; x += step * scale) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step * scale) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ButcherGridPainter oldDelegate) => false;
}
