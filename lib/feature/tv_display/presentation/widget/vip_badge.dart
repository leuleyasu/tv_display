import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tv_display_colors.dart';
import 'pulse_dot.dart';

/// VIP or Standard Shoutout Status Badge.
class VipBadge extends StatelessWidget {
  final bool isVip;
  final double scale;
  final Animation<double> nameAnim;

  const VipBadge({
    super.key,
    required this.isVip,
    required this.scale,
    required this.nameAnim,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent =
        isVip ? TvDisplayColors.goldAccent : TvDisplayColors.pinkSoft;
    final Color bg = isVip
        ? TvDisplayColors.goldAccent.withValues(alpha: 0.14)
        : accent.withValues(alpha: 0.12);
    final Color border = isVip
        ? TvDisplayColors.goldAccent.withValues(alpha: 0.45)
        : accent.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: nameAnim,
      builder: (context, child) {
        final t = nameAnim.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.6 + 0.4 * t,
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 18 * scale,
          vertical: 8 * scale,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border),
          boxShadow: isVip
              ? [
                  BoxShadow(
                    color: TvDisplayColors.goldAccent.withValues(alpha: 0.25),
                    blurRadius: 18,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PulseDot(color: accent, size: 6 * scale),
            SizedBox(width: 10 * scale),
            Icon(
              isVip ? Icons.workspace_premium_rounded : Icons.campaign_rounded,
              size: 12 * scale,
              color: accent,
            ),
            SizedBox(width: 6 * scale),
            Text(
              isVip ? 'OVERRIDE: VIP_SHOUTOUT' : 'SYS_MSG: SHOUTOUT',
              style: GoogleFonts.spaceMono(
                fontSize: 11 * scale,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
