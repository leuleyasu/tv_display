import 'package:flutter/material.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import 'equalizer_bars.dart';

/// Dynamic footer status indicator (Equalizer, Flame, Steam, Pulse, Star).
class FooterIndicator extends StatelessWidget {
  final double scale;
  final BusinessTypeTvTheme tvTheme;

  const FooterIndicator({
    super.key,
    required this.scale,
    required this.tvTheme,
  });

  @override
  Widget build(BuildContext context) {
    switch (tvTheme.footerStyle) {
      case FooterIndicatorStyle.equalizer:
        return EqualizerBars(scale: scale, color: tvTheme.primaryAccent);
      case FooterIndicatorStyle.flameDot:
        return Icon(
          Icons.local_fire_department_rounded,
          color: tvTheme.primaryAccent,
          size: 20 * scale,
        );
      case FooterIndicatorStyle.steam:
        return Icon(
          Icons.coffee_rounded,
          color: tvTheme.primaryAccent,
          size: 20 * scale,
        );
      case FooterIndicatorStyle.pulse:
        return Icon(
          Icons.bolt_rounded,
          color: tvTheme.primaryAccent,
          size: 20 * scale,
        );
      case FooterIndicatorStyle.star:
        return Icon(
          Icons.star_rounded,
          color: tvTheme.primaryAccent,
          size: 20 * scale,
        );
    }
  }
}
