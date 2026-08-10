import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marquee_ticker_text.dart';

/// Decoupled Bottom Announcement Marquee Bar Component
class DiningUpdatesMarqueeBar extends StatelessWidget {
  final String tickerContent;
  final double scale;

  const DiningUpdatesMarqueeBar({
    super.key,
    required this.tickerContent,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D0906),
      child: Column(
        children: [
          Container(
            height: 1.5 * scale,
            color: const Color(0xFFFBBF24).withValues(alpha: 0.4),
          ),
          Expanded(
            child: Row(
              children: [
                // Tab Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18 * scale,
                    vertical: 8 * scale,
                  ),
                  margin: EdgeInsets.only(left: 12 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24),
                    borderRadius: BorderRadius.circular(6 * scale),
                  ),
                  child: Text(
                    'DINING HALL UPDATES & SHOUTOUTS',
                    style: GoogleFonts.outfit(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                      color: const Color(0xFF140F0A),
                    ),
                  ),
                ),

                // Continuous Scrolling Marquee Ticker
                Expanded(
                  child: MarqueeTickerText(
                    text: tickerContent,
                    scale: scale,
                    style: GoogleFonts.inter(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: const Color(0xFFFEF3C7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
