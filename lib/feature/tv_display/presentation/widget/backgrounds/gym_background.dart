import 'package:flutter/material.dart';

/// Dark carbon fiber mesh grid with animated cyan/electric pulse lines for Gyms & Fitness Centers.
class GymBackground extends StatelessWidget {
  final BoxConstraints box;
  final Animation<double> orbAnim;

  const GymBackground({
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
            // Dark electric carbon base
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Color(0xFF09141D),
                    Color(0xFF040A0F),
                  ],
                ),
              ),
            ),
            // Cyan electric pulse aura top right
            Positioned(
              right: box.maxWidth * 0.1,
              top: box.maxHeight * 0.1,
              child: Container(
                width: box.maxWidth * 0.45,
                height: box.maxWidth * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00F0FF).withValues(alpha: 0.25 + pulse * 0.12),
                      const Color(0xFF0284C7).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Neon lime/cyan energy glow bottom left
            Positioned(
              left: box.maxWidth * 0.05,
              bottom: box.maxHeight * 0.1 + (pulse * 20),
              child: Container(
                width: box.maxWidth * 0.38,
                height: box.maxWidth * 0.38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
