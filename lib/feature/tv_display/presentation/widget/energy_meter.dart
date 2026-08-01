import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable Venue Energy Meter for TV Signage screens.
class EnergyMeter extends StatelessWidget {
  final double scale;
  final double level;
  final double fontSize;

  const EnergyMeter({
    super.key,
    required this.scale,
    required this.level,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (level * 100).round();
    final w = 110.0 * scale;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: w,
          height: 6 * scale,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: w * level,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF007A), Color(0xFFFBBF24)],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 6 * scale),
        Text(
          '$pct%',
          style: GoogleFonts.spaceMono(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
