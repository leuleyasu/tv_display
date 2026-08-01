import 'package:flutter/material.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import 'tv_display_screen.dart';

/// Dedicated UI Screen for Cafe business type.
/// Features an artisan roast coffee aesthetic, warm latte gold and fresh mint colors,
/// steam animation indicators, and cozy bakery atmosphere overlays.
class CafeDisplayScreen extends StatelessWidget {
  final String organizationId;

  const CafeDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    const theme = BusinessTypeTvTheme(
      typeId: 'cafe',
      primaryAccent: Color(0xFFD97706),
      secondaryAccent: Color(0xFF10B981),
      bgColor: Color(0xFF140D0A),
      orbColor1: Color(0xFF6B3A11),
      orbColor2: Color(0xFF422208),
      cardBorderColor: Color(0xFFD97706),
      adBadgeLabel: 'CAFE HIGHLIGHT',
      qrPromptCta: 'SCAN TO ORDER & EXPLORE',
      footerStatusText: 'FRESH BREW & ARTISAN BAKERY',
      topBarTag: 'ARTISAN CAFE',
      footerStyle: FooterIndicatorStyle.steam,
    );

    return Stack(
      children: [
        // Base TV Display initialized for Cafe
        TvDisplayScreen(
          organizationId: organizationId,
          businessType: 'cafe',
        ),

        // Custom Artisan Cafe Top Badge Indicator
        Positioned(
          top: 16,
          right: 32,
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
                  Icons.coffee_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'CAFE MODE',
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
      ],
    );
  }
}
