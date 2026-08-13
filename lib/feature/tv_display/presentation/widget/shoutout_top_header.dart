import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tv_display_colors.dart';
import 'pulse_dot.dart';
import 'vip_badge.dart';

/// Top header containing venue branding and VIP badge overlay.
class ShoutoutTopHeader extends StatelessWidget {
  final bool isVip;
  final double scale;
  final Animation<double> nameAnim;

  const ShoutoutTopHeader({
    super.key,
    required this.isVip,
    required this.scale,
    required this.nameAnim,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 36 * scale,
      left: 48 * scale,
      right: 48 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              PulseDot(
                color: isVip ? TvDisplayColors.amberAccent : Colors.white70,
                size: 8 * scale,
              ),
              SizedBox(width: 10 * scale),
              Text(
                'NIGHT TRACK TV',
                style: GoogleFonts.spaceMono(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          VipBadge(
            isVip: isVip,
            scale: scale,
            nameAnim: nameAnim,
          ),
        ],
      ),
    );
  }
}
