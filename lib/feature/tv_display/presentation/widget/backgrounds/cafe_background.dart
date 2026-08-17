import 'package:flutter/material.dart';
import '../floating_particles.dart';

/// Espresso brown gradient backdrop, soft morning sunbeam glow, coffee steam aura for Cafes.
class CafeBackground extends StatelessWidget {
  final BoxConstraints box;
  final Animation<double> orbAnim;

  const CafeBackground({
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
            // Espresso rich dark brown base
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF1E140E),
                    Color(0xFF0F0A07),
                  ],
                ),
              ),
            ),
            // Soft morning sunbeam top left
            Positioned(
              left: -box.maxWidth * 0.1,
              top: -box.maxHeight * 0.2,
              child: Container(
                width: box.maxWidth * 0.6,
                height: box.maxWidth * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.22 + pulse * 0.08),
                      const Color(0xFF78350F).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Warm latte glow bottom center
            Positioned(
              left: box.maxWidth * 0.3,
              bottom: -box.maxHeight * 0.15,
              child: Container(
                width: box.maxWidth * 0.45,
                height: box.maxWidth * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD97706).withValues(alpha: 0.18 + pulse * 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Floating Cafe Emojis Background
            Positioned.fill(
              child: IgnorePointer(
                child: FloatingParticles(
                  seed: 202,
                  accent: const Color(0xFFD97706),
                  businessType: 'cafe',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
