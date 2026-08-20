import 'package:flutter/material.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import '../../theme/tv_display_colors.dart';

/// Renders the 75% Main Viewport for Match Mode.
/// Presents 100% pure, unobstructed live video directly from the DSTV/HDMI decoder,
/// preserving all native broadcast scores, timers, and official match graphics.
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
      duration: const Duration(seconds: 2),
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
    final venueName = widget.settings.organizationName ?? widget.settings.houseName ?? 'Venue Live Feed';

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16 * s),
        border: Border.all(
          color: TvDisplayColors.hudBorder.withValues(alpha: 0.3),
          width: 2 * s,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 20 * s,
            offset: Offset(0, 8 * s),
          ),
          BoxShadow(
            color: TvDisplayColors.accentCyan.withValues(alpha: 0.05),
            blurRadius: 20 * s,
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
              // 1. Live Video Viewport (100% Unobstructed Video Surface)
              if (widget.customVideoChild != null)
                widget.customVideoChild!
              else
                _buildStandbySignalScreen(s, venueName),

              // 2. Subtle Live HDMI Status Pill (Top-Right Only)
              Positioned(
                top: 14 * s,
                right: 16 * s,
                child: _buildLivePill(s),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivePill(double s) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 10 * s, vertical: 5 * s),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(8 * s),
            border: Border.all(
              color: TvDisplayColors.liveStatus.withValues(alpha: 0.6 + 0.4 * _pulseAnim.value),
              width: 1 * s,
            ),
            boxShadow: [
              BoxShadow(
                color: TvDisplayColors.liveStatus.withValues(alpha: 0.3 * _pulseAnim.value),
                blurRadius: 8 * s,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7 * s,
                height: 7 * s,
                decoration: BoxDecoration(
                  color: TvDisplayColors.liveStatus,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TvDisplayColors.liveStatus.withValues(alpha: 0.8),
                      blurRadius: 6 * s,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6 * s),
              Text(
                'LIVE HDMI',
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

  /// Clean, elegant standby screen shown when waiting for HDMI decoder video feed
  Widget _buildStandbySignalScreen(double s, String venueName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [Color(0xFF0D1829), Color(0xFF040711)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(18 * s),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
                border: Border.all(color: TvDisplayColors.accentCyan.withValues(alpha: 0.3), width: 2 * s),
                boxShadow: [
                  BoxShadow(
                    color: TvDisplayColors.accentCyan.withValues(alpha: 0.15),
                    blurRadius: 24 * s,
                  ),
                ],
              ),
              child: Icon(
                Icons.settings_input_hdmi_rounded,
                color: TvDisplayColors.accentCyan,
                size: 44 * s,
              ),
            ),
            SizedBox(height: 18 * s),
            Text(
              venueName.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18 * s,
                letterSpacing: 2.5,
              ),
            ),
            SizedBox(height: 8 * s),
            Text(
              'LIVE MATCH BROADCAST FEED',
              style: TextStyle(
                color: TvDisplayColors.accentGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12 * s,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 6 * s),
            Text(
              'Plug in DSTV / HDMI decoder to display live match video',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11 * s,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
