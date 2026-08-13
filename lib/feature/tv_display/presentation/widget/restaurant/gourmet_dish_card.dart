import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/idle_content.dart';

/// Ultra-Modern Visual Gourmet Dish Card Widget for Restaurant Signage Grids
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
    final String priceText = item.price != null
        ? '${item.price!.toStringAsFixed(0)} ${item.currency ?? fallbackCurrency}'
        : '';

    final String catText = (item.category != null && item.category!.isNotEmpty)
        ? item.category!.toUpperCase()
        : 'SPECIAL';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        border: BoxBorder.fromLTRB(
          left: BorderSide(
            width: isActive ? 2 * scale : 1 * scale,
            color: isActive ? const Color(0xFFFBBF24) : Colors.transparent,
          ),
          right: BorderSide(
            width: isActive ? 2 * scale : 1 * scale,
            color: isActive ? const Color(0xFFFBBF24) : Colors.transparent,
          ),
          // width: isActive ? 2 * scale : 1 * scale,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withValues(alpha: 0.6),
        //     blurRadius: 18 * scale,
        //     offset: Offset(0, 8 * scale),
        //   ),
        //   if (isActive)
        //     BoxShadow(
        //       color: const Color(0xFFFBBF24).withValues(alpha: 0.25),
        //       blurRadius: 22 * scale,
        //       spreadRadius: 1 * scale,
        //     ),
        // ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Box takes all remaining vertical card space
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
                  // Dark vignette gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Category Tag Pill Top-Left
                  Positioned(
                    top: 8 * scale,
                    left: 8 * scale,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * scale,
                        vertical: 3 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF120D08).withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8 * scale),
                        border: Border.all(
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.5),
                          width: 1 * scale,
                        ),
                      ),
                      child: Text(
                        catText,
                        style: GoogleFonts.outfit(
                          fontSize: 9 * scale,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: const Color(0xFFFBBF24),
                        ),
                      ),
                    ),
                  ),

                  // Price Tag Overlay Bottom-Right
                  if (priceText.isNotEmpty)
                    Positioned(
                      bottom: 6 * scale,
                      right: 8 * scale,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10 * scale,
                          vertical: 4 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E140B),
                          borderRadius: BorderRadius.circular(10 * scale),
                          border: Border.all(
                            color: const Color(0xFFFBBF24),
                            width: 1.2 * scale,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFBBF24)
                                  .withValues(alpha: 0.3),
                              blurRadius: 8 * scale,
                            ),
                          ],
                        ),
                        child: Text(
                          priceText,
                          style: GoogleFonts.outfit(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Section fits tightly to text without extra vertical spacing
            Padding(
              padding: EdgeInsets.fromLTRB(
                10 * scale,
                8 * scale,
                10 * scale,
                8 * scale,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.headline.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: const Color(0xFFFEF3C7),
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
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.2,
                      ),
                    ),
                  ],
                  if (item.pairingNote != null &&
                      item.pairingNote!.isNotEmpty) ...[
                    SizedBox(height: 3 * scale),
                    Row(
                      children: [
                        Icon(
                          Icons.wine_bar_rounded,
                          size: 11 * scale,
                          color: const Color(0xFFF59E0B),
                        ),
                        SizedBox(width: 3 * scale),
                        Expanded(
                          child: Text(
                            item.pairingNote!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 9.5 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFF59E0B),
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
      color: const Color(0xFF26190E),
      child: Center(
        child: Text(
          item.emoji,
          style: TextStyle(fontSize: 36 * scale),
        ),
      ),
    );
  }
}
