import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tv_display_colors.dart';

/// Animated Shoutout Name with spring overshoot scaling and gradient sweep shader.
class AnimatedShoutoutName extends StatelessWidget {
  final String name;
  final Color accent;
  final Color accentSoft;
  final double fontSize;
  final double scale;
  final bool isVip;
  final Animation<double> nameAnim;
  final Animation<double> orbAnim;
  final Animation<double> vipSweepAnim;
  final String? fontFamily;

  const AnimatedShoutoutName({
    super.key,
    required this.name,
    required this.accent,
    required this.accentSoft,
    required this.fontSize,
    required this.scale,
    required this.isVip,
    required this.nameAnim,
    required this.orbAnim,
    required this.vipSweepAnim,
    this.fontFamily,
  });

  TextStyle _getFontStyle() {
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      height: 1.05,
      letterSpacing: isVip ? 10 : 8,
      shadows: [
        Shadow(
          color: accent.withValues(alpha: 0.55),
          blurRadius: 32 * scale,
        ),
        Shadow(
          color: accent.withValues(alpha: 0.3),
          blurRadius: 64 * scale,
        ),
      ],
    );
    if (fontFamily != null && fontFamily!.isNotEmpty) {
      return GoogleFonts.getFont(fontFamily!, textStyle: base);
    }
    return GoogleFonts.spaceGrotesk(textStyle: base);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([nameAnim, orbAnim, vipSweepAnim]),
      builder: (context, _) {
        final t = nameAnim.value;
        final double punch = t == 0 ? 0.6 : (t > 1 ? 1.0 : t);
        final double overshoot =
            punch < 1 ? 0.6 + 0.4 * Curves.easeOutBack.transform(punch) : 1.0;
        final double pulse = (sin(orbAnim.value * pi * 2) * 0.04) + 1.0;
        final double scaleNow = overshoot * pulse;
        final double sweep = (orbAnim.value * 2 - 1);
        return Opacity(
          opacity: punch.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scaleNow,
            child: ShaderMask(
              shaderCallback: (bounds) {
                if (isVip) {
                  return LinearGradient(
                    begin: Alignment(-1.0 + sweep * 2, 0),
                    end: Alignment(1.0 + sweep * 2, 0),
                    colors: const [
                      TvDisplayColors.goldDeep,
                      TvDisplayColors.goldAccent,
                      Colors.white,
                      TvDisplayColors.goldAccent,
                      TvDisplayColors.goldDeep,
                    ],
                    stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                  ).createShader(bounds);
                }
                return LinearGradient(
                  begin: Alignment(-1.0 + sweep * 2, 0),
                  end: Alignment(1.0 + sweep * 2, 0),
                  colors: [
                    accent,
                    accentSoft,
                    Colors.white,
                    accentSoft,
                    accent,
                  ],
                  stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _getFontStyle(),
              ),
            ),
          ),
        );
      },
    );
  }
}
