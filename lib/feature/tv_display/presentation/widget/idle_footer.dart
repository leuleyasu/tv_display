import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import 'energy_meter.dart';
import 'footer_indicator.dart';
import 'pulse_dot.dart';

/// Complete Idle Screen Footer component displaying venue indicators and EnergyMeter.
class IdleFooter extends StatelessWidget {
  final double scale;
  final double monoFontSize;
  final BusinessTypeTvTheme tvTheme;
  final double energyLevel;

  const IdleFooter({
    super.key,
    required this.scale,
    required this.monoFontSize,
    required this.tvTheme,
    required this.energyLevel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FooterIndicator(scale: scale, tvTheme: tvTheme),
        SizedBox(width: 10 * scale),
        PulseDot(color: tvTheme.primaryAccent, size: 7 * scale),
        SizedBox(width: 8 * scale),
        Text(
          tvTheme.footerStatusText,
          style: GoogleFonts.spaceMono(
            fontSize: monoFontSize,
            letterSpacing: 4,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        if (tvTheme.footerStyle == FooterIndicatorStyle.equalizer) ...[
          SizedBox(width: 22 * scale),
          Container(
            width: 1,
            height: 14 * scale,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          SizedBox(width: 22 * scale),
          Text(
            'ENERGY',
            style: GoogleFonts.spaceMono(
              fontSize: monoFontSize,
              letterSpacing: 3,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          SizedBox(width: 8 * scale),
          EnergyMeter(
            scale: scale,
            level: energyLevel,
            fontSize: monoFontSize,
          ),
        ],
      ],
    );
  }
}
