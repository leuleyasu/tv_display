import 'package:flutter/material.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import 'tv_display_screen.dart';

/// Dedicated UI Screen for Gym & Fitness Center business type.
/// Features high-contrast Cyber Emerald & Cyan performance styling, pulse metric overlays,
/// daily workout challenge tickers, and dynamic class schedule indicators.
class GymDisplayScreen extends StatelessWidget {
  final String organizationId;

  const GymDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    const theme = BusinessTypeTvTheme(
      typeId: 'gym',
      primaryAccent: Color(0xFF10B981),
      secondaryAccent: Color(0xFF06B6D4),
      bgColor: Color(0xFF0A110D),
      orbColor1: Color(0xFF065F46),
      orbColor2: Color(0xFF047857),
      cardBorderColor: Color(0xFF10B981),
      adBadgeLabel: 'PROMOTIONAL ANNOUNCEMENT',
      qrPromptCta: 'SCAN FOR CLASSES & WORKOUTS',
      footerStatusText: 'PEAK PERFORMANCE NETWORK',
      topBarTag: 'FITNESS CENTER',
      footerStyle: FooterIndicatorStyle.pulse,
    );

    return Stack(
      children: [
        // Base TV Display initialized for Gym
        TvDisplayScreen(
          organizationId: organizationId,
          businessType: 'gym',
        ),

        // Custom Cyber Gym Top Badge Indicator
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
                  Icons.fitness_center_rounded,
                  color: Color(0xFF10B981),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'GYM MODE',
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
