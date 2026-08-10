import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CanvasKit Web Safe Gold Ribbon Seal Badge Widget ("CHEF RECOMMENDATION")
class ChefRecommendationBadge extends StatelessWidget {
  final double scale;

  const ChefRecommendationBadge({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final double size = 88 * scale;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(4 * scale),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFBBF24),
            Color(0xFFFEF08A),
            Color(0xFFB45309),
            Color(0xFFFBBF24),
          ],
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF140F0A),
          border: Border.all(
            color: const Color(0xFFFBBF24),
            width: 1.5 * scale,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'CHEF',
                style: GoogleFonts.cinzel(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFEF3C7),
                  letterSpacing: 1.5,
                  height: 1.0,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                'RECOMMENDATION',
                style: GoogleFonts.inter(
                  fontSize: 6.5 * scale,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFBBF24),
                  letterSpacing: 0.8,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
