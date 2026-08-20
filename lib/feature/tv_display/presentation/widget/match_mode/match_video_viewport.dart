import 'dart:math';
import 'package:flutter/material.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import '../../theme/tv_display_colors.dart';

/// Renders the 75% Main Viewport for Match Mode.
/// Supports live HDMI/USB video input, stream URL feeds, and an animated
/// sports stadium HUD fallback when no external decoder is connected.
class MatchVideoViewport extends StatefulWidget {
  final SettingsModel settings;
  final double scale;
  final Widget? customVideoChild;

  const MatchVideoViewport({
    super.key,
    required this.settings,
    required this.scale,
    this.customVideoChild,
  });

  @override
  State<MatchVideoViewport> createState() => _MatchVideoViewportState();
}

class _MatchVideoViewportState extends State<MatchVideoViewport>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final home = widget.settings.homeTeam ?? 'Arsenal';
    final away = widget.settings.awayTeam ?? 'Chelsea';
    final score = widget.settings.matchScore ?? '2 - 1';
    final minute = widget.settings.matchMinute ?? "78'";
    final matchTitle = widget.settings.matchTitle ?? 'Premier League Live';

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(
          color: TvDisplayColors.hudBorder.withValues(alpha: 0.35),
          width: 2 * s,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 20 * s,
            offset: Offset(0, 8 * s),
          ),
          BoxShadow(
            color: TvDisplayColors.accentCyan.withValues(alpha: 0.08),
            blurRadius: 24 * s,
            spreadRadius: 1 * s,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14 * s),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Video Layer / Custom External Feed
              if (widget.customVideoChild != null)
                widget.customVideoChild!
              else
                _buildStadiumFallback(s, home, away, score, minute, matchTitle),

              // 2. Subtle Aspect Ratio Safe-Area Guide / Ambient Vignette
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.1,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.35),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Floating Minimal Top Match Badge (Broadcast Standard)
              Positioned(
                top: 14 * s,
                left: 16 * s,
                child: _buildTopScoreBug(s, home, away, score, minute, matchTitle),
              ),

              // 4. Floating Live Broadcast Pill
              Positioned(
                top: 14 * s,
                right: 16 * s,
                child: _buildLiveIndicator(s),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopScoreBug(
    double s,
    String home,
    String away,
    String score,
    String minute,
    String matchTitle,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * s, vertical: 8 * s),
      decoration: BoxDecoration(
        color: const Color(0xDD0D0D18),
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(color: Colors.white12, width: 1 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10 * s,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_soccer_rounded, color: TvDisplayColors.accentGold, size: 18 * s),
          SizedBox(width: 8 * s),
          Text(
            home.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14 * s,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(width: 8 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2 * s),
            decoration: BoxDecoration(
              color: TvDisplayColors.accentPink.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6 * s),
              border: Border.all(color: TvDisplayColors.accentPink.withValues(alpha: 0.5)),
            ),
            child: Text(
              score,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 14 * s,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(width: 8 * s),
          Text(
            away.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14 * s,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(width: 12 * s),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(4 * s),
            ),
            child: Text(
              minute,
              style: TextStyle(
                color: TvDisplayColors.accentGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12 * s,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIndicator(double s) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 6 * s),
          decoration: BoxDecoration(
            color: TvDisplayColors.liveStatus.withValues(alpha: 0.85 + 0.15 * _pulseAnim.value),
            borderRadius: BorderRadius.circular(8 * s),
            boxShadow: [
              BoxShadow(
                color: TvDisplayColors.liveStatus.withValues(alpha: 0.4 * _pulseAnim.value),
                blurRadius: 12 * s,
                spreadRadius: 2 * s,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7 * s,
                height: 7 * s,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6 * s),
              Text(
                'LIVE DSTV FEED',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11 * s,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Simulated dynamic stadium visualizer when no external HDMI decoder is currently streaming
  Widget _buildStadiumFallback(
    double s,
    String home,
    String away,
    String score,
    String minute,
    String matchTitle,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF071426), Color(0xFF040A14)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dynamic Pitch Field Lines
          CustomPaint(
            painter: _FootballPitchPainter(),
          ),

          // Central Match Arena Info
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 6 * s),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20 * s),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    matchTitle.toUpperCase(),
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 13 * s,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                SizedBox(height: 20 * s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Home Team
                    _buildTeamCard(s, home, isHome: true),
                    SizedBox(width: 24 * s),
                    // Score
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24 * s, vertical: 12 * s),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16 * s),
                        border: Border.all(color: TvDisplayColors.accentCyan.withValues(alpha: 0.4)),
                        boxShadow: [
                          BoxShadow(
                            color: TvDisplayColors.accentCyan.withValues(alpha: 0.2),
                            blurRadius: 20 * s,
                          ),
                        ],
                      ),
                      child: Text(
                        score,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42 * s,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 24 * s),
                    // Away Team
                    _buildTeamCard(s, away, isHome: false),
                  ],
                ),
                SizedBox(height: 18 * s),
                Text(
                  'MATCH IN PROGRESS • $minute',
                  style: TextStyle(
                    color: TvDisplayColors.accentGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14 * s,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(double s, String name, {required bool isHome}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72 * s,
          height: 72 * s,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            shape: BoxShape.circle,
            border: Border.all(
              color: isHome ? TvDisplayColors.accentPink : TvDisplayColors.accentPurple,
              width: 3 * s,
            ),
            boxShadow: [
              BoxShadow(
                color: (isHome ? TvDisplayColors.accentPink : TvDisplayColors.accentPurple)
                    .withValues(alpha: 0.3),
                blurRadius: 16 * s,
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name.substring(0, min(3, name.length)).toUpperCase() : 'FC',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20 * s,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        SizedBox(height: 8 * s),
        Text(
          name,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16 * s,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _FootballPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Outer border
    canvas.drawRect(Rect.fromLTWH(20, 20, size.width - 40, size.height - 40), paint);

    // Center line
    canvas.drawLine(
      Offset(size.width / 2, 20),
      Offset(size.width / 2, size.height - 20),
      paint,
    );

    // Center circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.height * 0.22, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
