import 'package:flutter/material.dart';
import '../../../../core/models/settings_model.dart';
import 'match_video_viewport.dart';
import 'match_ad_sidebar.dart';
import 'match_bottom_ticker.dart';

/// Full composite L-Bar Match Mode Layout (75% Video + 20-25% Ad Sidebar + 5% Ticker).
class LBarMatchLayout extends StatelessWidget {
  final SettingsModel settings;
  final Map<String, dynamic>? currentCampaign;
  final double adProgress;
  final String qrData;
  final Widget? customVideoChild;

  const LBarMatchLayout({
    super.key,
    required this.settings,
    required this.currentCampaign,
    required this.adProgress,
    required this.qrData,
    this.customVideoChild,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive scale based on standard 1080p width (1920px)
        final scale = (constraints.maxWidth / 1920.0).clamp(0.6, 2.0);
        final sidebarFlex = (settings.sidebarWidthPercent * 100).toInt().clamp(18, 30);
        final mainFlex = 100 - sidebarFlex;

        return Container(
          color: const Color(0xFF070712),
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            children: [
              // ── Top Main Row: 75% Video Viewport + 25% Ad Sidebar ──
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Video Viewport (75-77%)
                    Expanded(
                      flex: mainFlex,
                      child: MatchVideoViewport(
                        settings: settings,
                        scale: scale,
                        customVideoChild: customVideoChild,
                      ),
                    ),

                    SizedBox(width: 14 * scale),

                    // Ad & Patron QR Sidebar (23-25%)
                    Expanded(
                      flex: sidebarFlex,
                      child: MatchAdSidebar(
                        settings: settings,
                        currentCampaign: currentCampaign,
                        adProgress: adProgress,
                        scale: scale,
                        qrData: qrData,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12 * scale),

              // ── Bottom Row: 5-8% Live Marquee Ticker ───────────────
              MatchBottomTicker(
                settings: settings,
                scale: scale,
              ),
            ],
          ),
        );
      },
    );
  }
}
