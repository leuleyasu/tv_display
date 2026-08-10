import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/idle_content.dart';
import 'chef_recommendation_badge.dart';

/// Decoupled Left Hero Chef Recommendation Spotlight Card Component
class ChefRecommendationCard extends StatelessWidget {
  final IdleSlide slide;
  final double scale;
  final double baseFont;
  final String fallbackCurrency;

  const ChefRecommendationCard({
    super.key,
    required this.slide,
    required this.scale,
    required this.baseFont,
    this.fallbackCurrency = 'ETB',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF120D08).withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.35),
          width: 2 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 30 * scale,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.12),
            blurRadius: 35 * scale,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Food Image Box
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18 * scale),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: slide.imageUrl != null && slide.imageUrl!.isNotEmpty
                            ? Image.network(
                                slide.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildHeroImageFallback(scale, slide),
                              )
                            : _buildHeroImageFallback(scale, slide),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 18 * scale),

              // Dish Headline & Price Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      slide.headline.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.bebasNeue(
                        fontSize: (baseFont * 0.70) * scale,
                        letterSpacing: 2.0,
                        color: const Color(0xFFFEF3C7),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.9),
                            blurRadius: 10 * scale,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (slide.price != null) ...[
                    SizedBox(width: 16 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22 * scale,
                        vertical: 10 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF140F0A),
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(
                          color: const Color(0xFFFBBF24),
                          width: 2 * scale,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFBBF24).withValues(alpha: 0.35),
                            blurRadius: 15 * scale,
                          ),
                        ],
                      ),
                      child: Text(
                        '${slide.price!.toStringAsFixed(0)} ${slide.currency ?? fallbackCurrency}',
                        style: GoogleFonts.outfit(
                          fontSize: 32 * scale,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFBBF24),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (slide.subtitle.isNotEmpty) ...[
                SizedBox(height: 8 * scale),
                Text(
                  slide.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: (baseFont * 0.23) * scale,
                    fontWeight: FontWeight.w400,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],

              if (slide.pairingNote != null && slide.pairingNote!.isNotEmpty) ...[
                SizedBox(height: 8 * scale),
                Text(
                  'Recommended pairing: ${slide.pairingNote}',
                  style: GoogleFonts.inter(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF59E0B),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ],
          ),

          // Top-Left Luxury Scalloped Gold Ribbon Seal Badge
          Positioned(
            top: 12 * scale,
            left: 12 * scale,
            child: ChefRecommendationBadge(scale: scale),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImageFallback(double scale, IdleSlide slide) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFF2E1C0C),
            Color(0xFF140F0A),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFBBF24).withValues(alpha: 0.15),
                border: Border.all(
                  color: const Color(0xFFFBBF24),
                  width: 2 * scale,
                ),
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 64 * scale,
                color: const Color(0xFFFBBF24),
              ),
            ),
            SizedBox(height: 16 * scale),
            Text(
              slide.headline.toUpperCase(),
              style: GoogleFonts.bebasNeue(
                fontSize: 28 * scale,
                letterSpacing: 3,
                color: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
