import 'package:flutter/material.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import '../theme/tv_display_colors.dart';

/// Top or Bottom linear progress indicator bar for Shoutout display duration.
class ShoutoutProgressStrip extends StatelessWidget {
  final bool isVip;
  final double progressValue;
  final String businessType;
  final bool isBottom;

  const ShoutoutProgressStrip({
    super.key,
    required this.isVip,
    required this.progressValue,
    required this.businessType,
    this.isBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    final tvTheme = BusinessTypeTvTheme.of(businessType);
    final Color progressColor =
        isVip ? TvDisplayColors.amberAccent : tvTheme.primaryAccent;

    if (isBottom) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: IgnorePointer(
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      );
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 4,
        child: LinearProgressIndicator(
          value: progressValue,
          backgroundColor: Colors.white.withValues(alpha: 0.06),
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: 4,
        ),
      ),
    );
  }
}
