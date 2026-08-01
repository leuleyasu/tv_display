import 'package:flutter/material.dart';

/// Warm candle-lit golden ambient glow, dark slate/wood texture, floating warm ember feel for Restaurants.
class RestaurantBackground extends StatelessWidget {
  final BoxConstraints box;
  final Animation<double> orbAnim;

  const RestaurantBackground({
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
            // Dark warm slate background
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.3,
                  colors: [
                    Color(0xFF1C130D),
                    Color(0xFF0D0906),
                  ],
                ),
              ),
            ),
            // Golden warm glow center
            Positioned(
              left: box.maxWidth * 0.25,
              top: box.maxHeight * 0.1,
              child: Container(
                width: box.maxWidth * 0.5,
                height: box.maxWidth * 0.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFFBBF24).withValues(alpha: 0.25 + pulse * 0.1),
                      const Color(0xFFB8860B).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Warm ember accent bottom right
            Positioned(
              right: box.maxWidth * 0.05,
              bottom: box.maxHeight * 0.05 + (pulse * 20),
              child: Container(
                width: box.maxWidth * 0.35,
                height: box.maxWidth * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFD97706).withValues(alpha: 0.2),
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
