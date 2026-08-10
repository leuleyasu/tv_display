import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../ambient_orbs.dart';

/// Warm amber ambient candle glow & top header bar for Restaurant Signage.
class RestaurantBackground extends StatelessWidget {
  final BoxConstraints box;
  final Animation<double> orbAnim;
  final String orgName;
  final DateTime now;

  const RestaurantBackground({
    super.key,
    required this.box,
    required this.orbAnim,
    required this.orgName,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
    const primaryAccent = Color(0xFFF59E0B);

    return Stack(
      children: [
        // Warm Amber Ambient Orbs & Background
        Positioned.fill(
          child: AmbientOrbs(
            isVip: false,
            box: box,
            businessType: 'restaurant',
            orbAnim: orbAnim,
          ),
        ),

        // Top Bar Header (Restaurant Name on Left, Live Clock on Right)
        Positioned(
          top: 30 * scale,
          left: 40 * scale,
          right: 40 * scale,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10 * scale,
                    height: 10 * scale,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryAccent,
                      boxShadow: [
                        BoxShadow(
                          color: primaryAccent.withValues(alpha: 0.6),
                          blurRadius: 10 * scale,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14 * scale),
                  Text(
                    orgName.isNotEmpty ? orgName.toUpperCase() : 'RESTAURANT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28 * scale,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: primaryAccent.withValues(alpha: 0.6),
                          blurRadius: 20 * scale,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('HH:mm').format(now),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMM d').format(now).toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
