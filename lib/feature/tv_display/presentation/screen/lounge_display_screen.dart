import 'package:flutter/material.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import 'tv_display_screen.dart';

/// Dedicated UI Screen for Lounge business type.
/// Features executive luxury lavender & champagne gold styling, star shimmers,
/// cocktail dedication tickers, and VIP cabana atmosphere overlays.
class LoungeDisplayScreen extends StatelessWidget {
  final String organizationId;

  const LoungeDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    const theme = BusinessTypeTvTheme(
      typeId: 'lounge',
      primaryAccent: Color(0xFFA78BFA),
      secondaryAccent: Color(0xFFFBBF24),
      bgColor: Color(0xFF0B0A12),
      orbColor1: Color(0xFF4C1D95),
      orbColor2: Color(0xFF31106A),
      cardBorderColor: Color(0xFFA78BFA),
      adBadgeLabel: 'LOUNGE EXCLUSIVE',
      qrPromptCta: 'SCAN TO RESERVE & DEDICATE',
      footerStatusText: 'EXECUTIVE LOUNGE & COCKTAILS',
      topBarTag: 'VIP LOUNGE',
      footerStyle: FooterIndicatorStyle.star,
    );

    return Stack(
      children: [
        // Base TV Display initialized for Lounge
        TvDisplayScreen(
          organizationId: organizationId,
          businessType: 'lounge',
        ),

        // Custom Executive Lounge Top Badge Indicator
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
                    Icons.local_bar_rounded,
                    color: Color(0xFFA78BFA),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LOUNGE MODE',
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
