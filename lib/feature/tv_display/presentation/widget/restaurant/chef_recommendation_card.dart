import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/idle_content.dart';

/// Ultra-Premium Hero Chef Recommendation Spotlight Card Component
class ChefRecommendationCard extends StatelessWidget {
  final IdleSlide slide;
  final double scale;
  final double baseFont;
  final String fallbackCurrency;
  final String? qrCodeUrl;

  const ChefRecommendationCard({
    super.key,
    required this.slide,
    required this.scale,
    required this.baseFont,
    this.fallbackCurrency = 'ETB',
    this.qrCodeUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Food Photography Frame with proper AspectRatio (avoids vertical stretching)
          AspectRatio(
            aspectRatio: 1.25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10 * scale),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: slide.imageUrl != null && slide.imageUrl!.isNotEmpty
                        ? Image.network(
                            slide.imageUrl!,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            errorBuilder: (_, __, ___) =>
                                _buildHeroImageFallback(scale, slide),
                          )
                        : _buildHeroImageFallback(scale, slide),
                  ),
                  // Cinematic vignette dark gradient overlay at bottom of image
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF140F0A).withValues(alpha: 0.1),
                            const Color(0xFF140F0A).withValues(alpha: 0.85),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  // Category Tag Pill Top-Right
                  if (slide.category != null && slide.category!.isNotEmpty)
                    Positioned(
                      top: 10 * scale,
                      right: 10 * scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale,
                          vertical: 5 * scale,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF140F0A).withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(
                            color:
                                const Color(0xFFFBBF24).withValues(alpha: 0.6),
                            width: 1.2 * scale,
                          ),
                        ),
                        child: Text(
                          slide.category!.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 14 * scale),

          // Headline & Price Badge Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                slide.headline.toUpperCase(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: (baseFont * 0.28).clamp(16.0, 22.0) * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: const Color(0xFFFEF3C7),
                  height: 1.1,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.9),
                      blurRadius: 10 * scale,
                    ),
                  ],
                ),
              ),
              if (slide.price != null) ...[
                SizedBox(height: 8 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * scale,
                    vertical: 6 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C130D),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: const Color(0xFFFBBF24),
                      width: 1.5 * scale,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                        blurRadius: 12 * scale,
                      ),
                    ],
                  ),
                  child: Text(
                    '${slide.price!.toStringAsFixed(0)} ${slide.currency ?? fallbackCurrency}',
                    style: GoogleFonts.outfit(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFFBBF24),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Description Copy
          if (slide.subtitle.isNotEmpty) ...[
            SizedBox(height: 8 * scale),
            Text(
              slide.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11 * scale,
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.82),
                height: 1.25,
              ),
            ),
          ],

          // Drink / Wine Pairing Recommendation Pill
          if (slide.pairingNote != null && slide.pairingNote!.isNotEmpty) ...[
            SizedBox(height: 8 * scale),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 5 * scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF26190E),
                borderRadius: BorderRadius.circular(10 * scale),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                  width: 1 * scale,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wine_bar_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 14 * scale,
                  ),
                  SizedBox(width: 6 * scale),
                  Flexible(
                    child: Text(
                      slide.pairingNote!.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// High-end fallback photography placeholder when no network image is set
  Widget _buildHeroImageFallback(double scale, IdleSlide slide) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [
            Color(0xFF382312),
            Color(0xFF140F0A),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient ember glow circle
          Container(
            width: 220 * scale,
            height: 220 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFBBF24).withValues(alpha: 0.08),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(22 * scale),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                  border: Border.all(
                    color: const Color(0xFFFBBF24),
                    width: 2 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
                      blurRadius: 20 * scale,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  size: 58 * scale,
                  color: const Color(0xFFFBBF24),
                ),
              ),
              SizedBox(height: 16 * scale),
              Text(
                slide.headline.toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: const Color(0xFFFEF3C7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
