import 'package:flutter/material.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'bottom_bar_overlay_widget.dart';

/// Factory router to render 7 built-in TV screen layout templates based on Dashboard configuration:
/// 1. `bottom_bar` (Primary Focus - Bottom Overlay Bar during live TV/matches)
/// 2. `l_bar` (L-Shape Broadcast layout with right sidebar)
/// 3. `fullscreen` (Default full screen idle menu slides)
/// 4. `split_horizontal` (50/50 Split screen)
/// 5. `pip` (Picture-in-Picture)
/// 6. `grid_quad` (4-Zone Grid)
/// 7. `ticker_only` (Ultra-slim news marquee)
class TvLayoutFactory extends StatelessWidget {
  final String templateId;
  final Widget defaultView;
  final SettingsModel? settings;
  final String orgName;
  final String? qrCodeUrl;
  final List<Map<String, dynamic>> menuItems;
  final String businessType;
  final String tickerNewsText;

  const TvLayoutFactory({
    super.key,
    required this.templateId,
    required this.defaultView,
    this.settings,
    required this.orgName,
    this.qrCodeUrl,
    required this.menuItems,
    this.businessType = 'restaurant',
    this.tickerNewsText = '',
  });

  @override
  Widget build(BuildContext context) {
    final mode = templateId.trim().toLowerCase();

    switch (mode) {
      case 'bottom_bar':
        return BottomBarOverlayWidget(
          liveContent: defaultView,
          settings: settings,
          orgName: orgName,
          qrCodeUrl: qrCodeUrl,
          menuItems: menuItems,
          businessType: businessType,
          tickerNewsText: tickerNewsText,
        );

      case 'split_horizontal':
        return Column(
          children: [
            Expanded(flex: 1, child: defaultView),
            Expanded(
              flex: 1,
              child: Container(
                color: const Color(0xFF0F172A),
                child: BottomBarOverlayWidget(
                  liveContent: const SizedBox.shrink(),
                  settings: settings,
                  orgName: orgName,
                  qrCodeUrl: qrCodeUrl,
                  menuItems: menuItems,
                  businessType: businessType,
                  tickerNewsText: tickerNewsText,
                ),
              ),
            ),
          ],
        );

      case 'pip':
        return Stack(
          children: [
            Positioned.fill(child: defaultView),
            Positioned(
              right: 24,
              bottom: 24,
              width: 320,
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BottomBarOverlayWidget(
                    liveContent: const SizedBox.shrink(),
                    settings: settings,
                    orgName: orgName,
                    qrCodeUrl: qrCodeUrl,
                    menuItems: menuItems,
                    businessType: businessType,
                    tickerNewsText: tickerNewsText,
                  ),
                ),
              ),
            ),
          ],
        );

      case 'fullscreen':
      default:
        return defaultView;
    }
  }
}
