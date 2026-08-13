import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'marquee_ticker_text.dart';

/// Decoupled Bottom Announcement Marquee Bar Component with Integrated QR Dock
class DiningUpdatesMarqueeBar extends StatelessWidget {
  final String tickerContent;
  final double scale;
  final String? qrCodeUrl;

  const DiningUpdatesMarqueeBar({
    super.key,
    required this.tickerContent,
    required this.scale,
    this.qrCodeUrl,
  });

  @override
  Widget build(BuildContext context) {
    final String finalQrUrl = (qrCodeUrl != null && qrCodeUrl!.isNotEmpty)
        ? qrCodeUrl!
        : 'https://ayustream.app/menu';

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
                    'CHEF SPECIALS & DINING UPDATES',
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

                // Right Zone: Mini Scan Menu QR Dock
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
                  margin: EdgeInsets.only(right: 8 * scale, top: 4 * scale, bottom: 4 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                        blurRadius: 8 * scale,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36 * scale,
                        height: 36 * scale,
                        child: QrImageView(
                          data: finalQrUrl,
                          version: QrVersions.auto,
                          size: 36 * scale,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DIGITAL MENU',
                            style: GoogleFonts.outfit(
                              color: Colors.black,
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'SCAN ON PHONE',
                            style: GoogleFonts.inter(
                              color: const Color(0xFFB45309),
                              fontSize: 8 * scale,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
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
