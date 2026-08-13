import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/business_type_tv_theme.dart';
import 'pulse_dot.dart';

/// Top bar with venue branding, glowing title, and real-time clock.
class TvTopHeaderBar extends StatelessWidget {
  final double scale;
  final String businessType;
  final String orgName;
  final DateTime now;
  final Animation<double> orbAnim;

  const TvTopHeaderBar({
    super.key,
    required this.scale,
    required this.businessType,
    required this.orgName,
    required this.now,
    required this.orbAnim,
  });

  @override
  Widget build(BuildContext context) {
    final tvTheme = BusinessTypeTvTheme.of(businessType);
    final TextStyle baseStyle = GoogleFonts.spaceGrotesk(
      fontSize: 26 * scale,
      fontWeight: FontWeight.w900,
      letterSpacing: 6.0,
    );

    return Positioned(
      top: 30 * scale,
      left: 40 * scale,
      right: 40 * scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PulseDot(color: tvTheme.primaryAccent, size: 8 * scale),
              SizedBox(width: 12 * scale),
              AnimatedBuilder(
                animation: orbAnim,
                builder: (context, child) {
                  final glow = orbAnim.value * 0.5 + 0.5;
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(-0.8 + orbAnim.value * 1.6, 0.0),
                      end: const Alignment(1.0, 0.0),
                      colors: [
                        tvTheme.primaryAccent.withValues(alpha: 0.6),
                        Colors.white,
                        Colors.white,
                        tvTheme.primaryAccent.withValues(alpha: 0.6),
                      ],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      orgName.isNotEmpty
                          ? orgName.toUpperCase()
                          : 'SYSTEM.CORE // ACTIVE',
                      style: baseStyle.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: tvTheme.primaryAccent
                                .withValues(alpha: glow * 0.7),
                            blurRadius: 20 * scale,
                          ),
                          Shadow(
                            color: tvTheme.primaryAccent
                                .withValues(alpha: glow * 0.3),
                            blurRadius: 40 * scale,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(now),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Text(
                DateFormat('EEEE, MMM d').format(now).toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
