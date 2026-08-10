import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import '../theme/tv_display_colors.dart';
import 'tech_grid_painter.dart';

/// Ambient blurred background orbs and overlay tech grid.
class AmbientOrbs extends StatelessWidget {
  final bool isVip;
  final BoxConstraints box;
  final String businessType;
  final Animation<double> orbAnim;

  const AmbientOrbs({
    super.key,
    required this.isVip,
    required this.box,
    required this.businessType,
    required this.orbAnim,
  });

  Widget _orb(Color color, double opacity, double w, double h, double blur) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: const SizedBox.expand(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tvTheme = BusinessTypeTvTheme.of(businessType);
    final Color c1 = isVip
        ? TvDisplayColors.amberOrb
        : (businessType == 'nightclub'
            ? TvDisplayColors.pinkOrb
            : tvTheme.orbColor1);
    final Color c2 = isVip
        ? TvDisplayColors.amberOrb2
        : (businessType == 'nightclub'
            ? TvDisplayColors.pinkOrb2
            : tvTheme.orbColor2);
    final Color gridAccent =
        isVip ? TvDisplayColors.amberAccent : tvTheme.primaryAccent;

    return Stack(
      children: [
        // Ambient orbs FIRST (rendered in the back, behind the grid)
        AnimatedBuilder(
          animation: orbAnim,
          builder: (_, __) {
            final double t = orbAnim.value;
            return Stack(
              children: [
                Positioned(
                  top: ui.lerpDouble(-120, -20, t),
                  left: ui.lerpDouble(-100, 20, t),
                  child: _orb(c1, 0.25, 600, 700, 100),
                ),
                Positioned(
                  bottom: ui.lerpDouble(-150, -40, t),
                  right: ui.lerpDouble(-80, 40, t),
                  child: _orb(c2, 0.35, 500, 600, 80),
                ),
                Positioned(
                  top: ui.lerpDouble(
                      box.maxHeight * 0.2, box.maxHeight * 0.4, 1 - t),
                  right:
                      ui.lerpDouble(box.maxWidth * 0.1, box.maxWidth * 0.3, t),
                  child: _orb(
                      isVip
                          ? TvDisplayColors.amberAccent
                          : tvTheme.primaryAccent,
                      0.08,
                      300,
                      300,
                      120),
                ),
              ],
            );
          },
        ),
        // Grid layers drawn AFTER orbs so they sit on top
        Positioned.fill(
          child: CustomPaint(
            painter: TechGridPainter(
              color: gridAccent.withValues(alpha: 0.25),
            ),
          ),
        ),
      ],
    );
  }
}
