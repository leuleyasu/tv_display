import 'package:flutter/material.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import 'tv_display_screen.dart';

/// Dedicated UI Screen for Restaurant business type.
/// Features a gourmet fine-dining theme, amber gold accents, chef specials highlight,
/// and customized hospitality signage overlay.
class RestaurantDisplayScreen extends StatelessWidget {
  final String organizationId;

  const RestaurantDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    const theme = BusinessTypeTvTheme(
      typeId: 'restaurant',
      primaryAccent: Color(0xFFF59E0B),
      secondaryAccent: Color(0xFFEF4444),
      bgColor: Color(0xFF0F0C0A),
      orbColor1: Color(0xFF7A4A00),
      orbColor2: Color(0xFF5C2D00),
      cardBorderColor: Color(0xFFF59E0B),
      adBadgeLabel: 'CHEF\'S SPECIAL / PROMO',
      qrPromptCta: 'SCAN FOR MENU & SPECIALS',
      footerStatusText: 'FINE DINING & HOSPITALITY',
      topBarTag: 'DINING ROOM',
      footerStyle: FooterIndicatorStyle.flameDot,
    );

    return Stack(
      children: [
        // Base TV Display initialized for Restaurant
        TvDisplayScreen(
          organizationId: organizationId,
          businessType: 'restaurant',
        ),

        // Custom Gourmet Restaurant Top Badge Indicator
        Positioned(
          top: 16,
          right: 32,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.primaryAccent.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryAccent.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.restaurant_menu_rounded,
                    color: Color(0xFFF59E0B),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'RESTAURANT MODE',
                    style: TextStyle(
                      color: theme.primaryAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
