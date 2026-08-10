import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Decoupled Empty/Loading Stream State View Component
class RestaurantEmptyStateView extends StatelessWidget {
  final double scale;
  final String orgName;
  final Color bgColor;

  const RestaurantEmptyStateView({
    super.key,
    required this.scale,
    required this.orgName,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_rounded,
              size: 80 * scale,
              color: const Color(0xFFFBBF24),
            ),
            SizedBox(height: 20 * scale),
            Text(
              orgName.isNotEmpty ? orgName.toUpperCase() : 'RESTAURANT SIGNAGE',
              style: GoogleFonts.cinzel(
                fontSize: 32 * scale,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFFEF3C7),
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 10 * scale),
            Text(
              'LIVE MENU & SPECIALS UPDATING...',
              style: GoogleFonts.inter(
                fontSize: 16 * scale,
                color: const Color(0xFFFBBF24),
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
