import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/idle_content.dart';

/// Ultra-Modern Visual Gourmet Dish Card Widget for Restaurant Signage Grids.
/// Crafted for crisp high-contrast daytime visibility on 4K TV screens.
class GourmetDishCard extends StatelessWidget {
  final IdleSlide item;
  final double scale;
  final String fallbackCurrency;
  final bool isActive;

  const GourmetDishCard({
    super.key,
    required this.item,
    required this.scale,
    this.fallbackCurrency = 'ETB',
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final String curr = (item.currency != null && item.currency!.isNotEmpty)
        ? item.currency!.toUpperCase()
        : fallbackCurrency.toUpperCase();
    final String priceText =
        item.price != null ? '${item.price!.toStringAsFixed(0)} $curr' : '';

    final String catText = (item.category != null && item.category!.isNotEmpty)
        ? item.category!.toUpperCase()
        : 'CHEF\'S SPECIAL';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1A15),
        borderRadius: BorderRadius.circular(22 * scale),
        border: Border.all(
          width: isActive ? 2.2 * scale : 1.2 * scale,
          color: isActive
              ? const Color(0xFFFBBF24)
              : const Color(0xFFFBBF24).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 20 * scale,
            offset: Offset(0, 8 * scale),
          ),
          BoxShadow(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.10),
            blurRadius: 14 * scale,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Food Photography Showcase Box
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                        ? Image.network(
                            item.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildImageFallback(scale, item),
                          )
                        : _buildImageFallback(scale, item),
                  ),

                  // Soft bottom vignette gradient for text contrast
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.75),
                          ],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Category Badge Top-Left
                  Positioned(
                    top: 10 * scale,
                    left: 10 * scale,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 4 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF140F0A).withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(10 * scale),
                        border: Border.all(
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.6),
                          width: 1 * scale,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6 * scale,
                          ),
                        ],
                      ),
                      child: Text(
                        catText,
                        style: GoogleFonts.outfit(
                          fontSize: 9.5 * scale,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: const Color(0xFFFDE68A),
                        ),
                      ),
                    ),
                  ),

                  // High-Contrast Champagne Gold Price Badge Bottom-Right
                  if (priceText.isNotEmpty)
                    Positioned(
                      bottom: 8 * scale,
                      right: 10 * scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale,
                          vertical: 5 * scale,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFBBF24)
                                  .withValues(alpha: 0.4),
                              blurRadius: 10 * scale,
                            ),
                          ],
                        ),
                        child: Text(
                          priceText,
                          style: GoogleFonts.outfit(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: const Color(0xFF170E04),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. Dish Details & Copy
            Container(
              padding: EdgeInsets.fromLTRB(
                12 * scale,
                10 * scale,
                12 * scale,
                10 * scale,
              ),
              color: const Color(0xFF181410),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.headline.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 15 * scale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: const Color(0xFFFFFBEB),
                    ),
                  ),
                  if (item.subtitle.isNotEmpty) ...[
                    SizedBox(height: 3 * scale),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 10.5 * scale,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFD1D5DB),
                        height: 1.25,
                      ),
                    ),
                  ],
                  if (item.pairingNote != null &&
                      item.pairingNote!.isNotEmpty) ...[
                    SizedBox(height: 4 * scale),
                    Row(
                      children: [
                        Icon(
                          Icons.wine_bar_rounded,
                          size: 12 * scale,
                          color: const Color(0xFFFBBF24),
                        ),
                        SizedBox(width: 4 * scale),
                        Expanded(
                          child: Text(
                            item.pairingNote!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFDE68A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageFallback(double scale, IdleSlide item) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E241A),
            Color(0xFF1A140E),
          ],
        ),
      ),
      child: Center(
        child: Text(
          item.emoji,
          style: TextStyle(fontSize: 42 * scale),
        ),
      ),
    );
  }
}
