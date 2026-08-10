import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../domain/models/idle_content.dart';

/// Decoupled Right Popular Favorites & Specials Column List Card Component
class PopularFavoritesListCard extends StatelessWidget {
  final List<IdleSlide> sideItems;
  final double scale;
  final String fallbackCurrency;

  const PopularFavoritesListCard({
    super.key,
    required this.sideItems,
    required this.scale,
    this.fallbackCurrency = 'ETB',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFF120D08).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.25),
          width: 1.5 * scale,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu_rounded,
                color: const Color(0xFFFBBF24),
                size: 22 * scale,
              ),
              SizedBox(width: 10 * scale),
              Text(
                'POPULAR FAVORITES & SPECIALS',
                style: GoogleFonts.outfit(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),

          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              itemCount: sideItems.length,
              separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
              itemBuilder: (context, idx) {
                final item = sideItems[idx];
                final bool isActive = idx == 0;

                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14 * scale,
                    vertical: 12 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18120C),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFFF59E0B)
                          : const Color(0xFFFBBF24).withValues(alpha: 0.25),
                      width: isActive ? 2 * scale : 1 * scale,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                              blurRadius: 12 * scale,
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      if (isActive)
                        Container(
                          width: 4 * scale,
                          height: 28 * scale,
                          margin: EdgeInsets.only(right: 10 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(2 * scale),
                          ),
                        ),

                      _buildDishIcon(item, scale),
                      SizedBox(width: 14 * scale),

                      Expanded(
                        child: Text(
                          item.headline.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: const Color(0xFFFEF3C7),
                          ),
                        ),
                      ),

                      if (item.price != null) ...[
                        SizedBox(width: 10 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14 * scale,
                            vertical: 6 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF100B07),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: const Color(0xFFFBBF24),
                              width: 1.5 * scale,
                            ),
                          ),
                          child: Text(
                            '${item.price!.toStringAsFixed(0)} ${item.currency ?? fallbackCurrency}',
                            style: GoogleFonts.outfit(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFBBF24),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishIcon(IdleSlide item, double scale) {
    final String name = item.headline.toLowerCase();
    IconData iconData = Icons.restaurant_rounded;

    if (name.contains('calamari') || name.contains('squid') || name.contains('fish')) {
      iconData = Icons.set_meal_rounded;
    } else if (name.contains('steak') || name.contains('beef') || name.contains('ribeye')) {
      iconData = Icons.kebab_dining_rounded;
    } else if (name.contains('risotto') || name.contains('rice') || name.contains('truffle')) {
      iconData = Icons.rice_bowl_rounded;
    } else if (name.contains('salad') || name.contains('greens')) {
      iconData = Icons.local_dining_rounded;
    } else if (name.contains('taco') || name.contains('lobster')) {
      iconData = Icons.lunch_dining_rounded;
    } else if (name.contains('cake') || name.contains('chocolate') || name.contains('lava')) {
      iconData = Icons.cake_rounded;
    } else if (name.contains('crème') || name.contains('brûlée') || name.contains('dessert')) {
      iconData = Icons.bakery_dining_rounded;
    } else if (name.contains('burger') || name.contains('wagyu')) {
      iconData = Icons.fastfood_rounded;
    }

    return Container(
      width: 38 * scale,
      height: 38 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFFBBF24).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
        ),
      ),
      child: Icon(
        iconData,
        color: const Color(0xFFFBBF24),
        size: 22 * scale,
      ),
    );
  }
}
