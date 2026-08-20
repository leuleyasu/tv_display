import 'package:flutter/material.dart';
import '../floating_particles.dart';

/// Neon equalizer, reactive soundwave ripples, and laser sweeps for Nightclubs.
class NightclubBackground extends StatelessWidget {
  final BoxConstraints box;
  final Animation<double> orbAnim;

  const NightclubBackground({
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
            // Dark violet base
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF140826),
                    Color(0xFF07040D),
                  ],
                ),
              ),
            ),
            // Neon pink orb
            Positioned(
              left: box.maxWidth * 0.1,
              top: box.maxHeight * 0.15 + (pulse * 30),
              child: Container(
                width: box.maxWidth * 0.45,
                height: box.maxWidth * 0.45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFF007A).withValues(alpha: 0.35 + pulse * 0.15),
                      const Color(0xFFB8005C).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Cyan accent orb
            Positioned(
              right: box.maxWidth * 0.08,
              bottom: box.maxHeight * 0.1 - (pulse * 25),
              child: Container(
                width: box.maxWidth * 0.4,
                height: box.maxWidth * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF22D3EE).withValues(alpha: 0.3),
                      const Color(0xFFA78BFA).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Floating Nightclub Emojis Background
            Positioned.fill(
              child: IgnorePointer(
                child: FloatingParticles(
                  seed: 505,
                  accent: const Color(0xFFFF007A),
                  businessType: 'nightclub',
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
