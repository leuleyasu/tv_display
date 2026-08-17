import 'package:flutter/material.dart';
import '../floating_particles.dart';

/// Ultra-luxurious glassmorphism, champagne gold floating bokeh particles for Lounges & Bars.
class LoungeBackground extends StatelessWidget {
  final BoxConstraints box;
  final Animation<double> orbAnim;

  const LoungeBackground({
    super.key,
    required this.box,
    required this.orbAnim,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: orbAnim,
      builder: (context, child) {
        final double pulse = orbAnim.value;
        return Stack(
          children: [
            // Dark luxury velvet base
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Color(0xFF161208),
                    Color(0xFF0A0804),
                  ],
                ),
              ),
            ),
            // Champagne gold floating bokeh center
            Positioned(
              left: box.maxWidth * 0.2,
              top: box.maxHeight * 0.15,
              child: Container(
                width: box.maxWidth * 0.55,
                height: box.maxWidth * 0.55,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD4AF37).withValues(alpha: 0.28 + pulse * 0.1),
                      const Color(0xFF996515).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Deep bronze accent top right
            Positioned(
              right: box.maxWidth * 0.08,
              top: box.maxHeight * 0.05 + (pulse * 15),
              child: Container(
                width: box.maxWidth * 0.35,
                height: box.maxWidth * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFB8860B).withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Floating Lounge Emojis Background
            Positioned.fill(
              child: IgnorePointer(
                child: FloatingParticles(
                  seed: 404,
                  accent: const Color(0xFFD4AF37),
                  businessType: 'lounge',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
