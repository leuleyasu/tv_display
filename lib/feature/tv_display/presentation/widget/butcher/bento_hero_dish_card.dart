import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';

/// Hero Spotlight Bento Card for Butcher House TV Displays.
/// Features high-impact dish showcases, steam/ember accents, and live pairing notes.
class BentoHeroDishCard extends StatelessWidget {
  final IdleSlide slide;
  final double scale;
  final Animation<double> fadeAnim;

  const BentoHeroDishCard({
    super.key,
    required this.slide,
    required this.scale,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    const primaryEmber = Color(0xFFEF4444);
    const warmAmber = Color(0xFFF59E0B);

    final priceStr = slide.price != null
        ? '${currencyFormatter.format(slide.price!.round())} ${slide.currency ?? "ETB"}'
        : '2,200 ETB / KG';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16100E).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: primaryEmber.withValues(alpha: 0.3),
          width: 1.5 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryEmber.withValues(alpha: 0.1),
            blurRadius: 30 * scale,
            offset: Offset(0, 10 * scale),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 20 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24 * scale),
        child: Stack(
          children: [
            // Background Image / Gradient Surface
            if (slide.imageUrl != null && slide.imageUrl!.trim().isNotEmpty)
              Positioned.fill(
                child: slide.imageUrl!.trim().startsWith('assets/')
                    ? Image.asset(
                        slide.imageUrl!.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackGraphic(scale),
                      )
                    : Image.network(
                        slide.imageUrl!.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackGraphic(scale),
                      ),
              )
            else
              _buildFallbackGraphic(scale),

            // Vignette Gradient Overlays for High Contrast
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      const Color(0xFF0C0908).withValues(alpha: 0.65),
                      const Color(0xFF0C0908).withValues(alpha: 0.98),
                    ],
                    stops: const [0.0, 0.45, 0.9],
                  ),
                ),
              ),
            ),

            // Content Body
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Badges Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                            vertical: 6 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: primaryEmber.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20 * scale),
                            border: Border.all(
                              color: primaryEmber.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                color: primaryEmber,
                                size: 16 * scale,
                              ),
                              SizedBox(width: 6 * scale),
                              Text(
                                (slide.category ?? 'CHEF SPECIAL').toUpperCase(),
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 11 * scale,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14 * scale,
                            vertical: 6 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: warmAmber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: warmAmber.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            priceStr,
                            style: GoogleFonts.outfit(
                              color: const Color(0xFFFDE68A),
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Center / Bottom Details
                    FadeTransition(
                      opacity: fadeAnim,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                slide.emoji,
                                style: TextStyle(fontSize: 32 * scale),
                              ),
                              SizedBox(width: 10 * scale),
                              Expanded(
                                child: Text(
                                  slide.headline,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26 * scale,
                                    fontWeight: FontWeight.w900,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12 * scale),
                          Text(
                            slide.subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 13.5 * scale,
                              height: 1.45,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (slide.pairingNote != null &&
                              slide.pairingNote!.isNotEmpty) ...[
                            SizedBox(height: 14 * scale),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale,
                                vertical: 8 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10 * scale),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    color: warmAmber,
                                    size: 16 * scale,
                                  ),
                                  SizedBox(width: 8 * scale),
                                  Expanded(
                                    child: Text(
                                      slide.pairingNote!,
                                      style: TextStyle(
                                        color: const Color(0xFFFDE68A),
                                        fontSize: 11.5 * scale,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackGraphic(double scale) {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.3),
            radius: 1.2,
            colors: [
              Color(0xFF331411),
              Color(0xFF1E0E0C),
              Color(0xFF0F0706),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                slide.emoji,
                style: TextStyle(fontSize: 80 * scale),
              ),
              SizedBox(height: 16 * scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: Text(
                  'YONAS CHERCHER SPECIALTY',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFFFCA5A5),
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
