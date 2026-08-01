import 'package:flutter/material.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import 'tv_display_screen.dart';

/// Dedicated UI Screen for Nightclub business type.
/// Features neon pink & electric purple aesthetics, DJ Stage visualizers,
/// high-energy party lighting overlays, and dynamic equalizer status indicators.
class NightclubDisplayScreen extends StatelessWidget {
  final String organizationId;

  const NightclubDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    const theme = BusinessTypeTvTheme(
      typeId: 'nightclub',
      primaryAccent: Color(0xFFFF007A),
      secondaryAccent: Color(0xFFA78BFA),
      bgColor: Color(0xFF070712),
      orbColor1: Color(0xFFB8005C),
      orbColor2: Color(0xFF660033),
      cardBorderColor: Color(0xFFFF007A),
      adBadgeLabel: 'SPONSORED AD',
      qrPromptCta: 'SCAN TO JOIN THE PARTY',
      footerStatusText: 'LIVE FROM THE CLUB',
      topBarTag: 'DJ ON STAGE',
      footerStyle: FooterIndicatorStyle.equalizer,
    );

    return Stack(
      children: [
        // Base TV Display initialized for Nightclub
        TvDisplayScreen(
          organizationId: organizationId,
          businessType: 'nightclub',
        ),

        // Custom Neon Nightclub Top Badge Indicator
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
                  color: theme.primaryAccent.withValues(alpha: 0.25),
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.nightlife_rounded,
                  color: Color(0xFFFF007A),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'NIGHTCLUB MODE',
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
