import 'package:flutter/material.dart';

import '../widget/tv_active_shoutouts_view.dart';
import '../widget/tv_base_shell.dart';
import '../widget/tv_layout_factory.dart';
import '../widget/views/restaurant_idle_view.dart';

/// Dedicated Independent UI Screen for Restaurant business type.
/// Features fine-dining gourmet menu layouts, chef highlights, and template dispatching.
class RestaurantDisplayScreen extends StatelessWidget {
  final String organizationId;

  const RestaurantDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return TvBaseShell(
      organizationId: organizationId,
      businessType: 'restaurant',
      builder: (context, state, shellContext) {
        if (!state.isIdleMode && state.messages.isNotEmpty) {
          return TvActiveShoutoutsView(
            state: state,
            shellContext: shellContext,
            businessType: 'restaurant',
          );
        }

        final templateId = (state.settings?.tvLayoutTemplate ?? 'fullscreen').trim().toLowerCase();
        final tickerNewsText = state.settings?.tickerNewsText ?? '';

        final effectiveQr = (state.qrCodeUrl != null && state.qrCodeUrl!.isNotEmpty)
            ? state.qrCodeUrl
            : state.settings?.qrCodeUrl;

        final defaultView = RestaurantIdleView(
          menuItems: state.menuItems,
          idleSlideIndex: state.idleSlideIndex,
          settings: state.settings,
          orgName: state.orgName,
          now: shellContext.now,
          qrCodeUrl: effectiveQr,
          energyLevel: shellContext.energyLevel,
          isWorldCupEnabled: state.isWorldCupEnabled,
          fadeAnim: shellContext.fadeAnim,
          idleBreathAnim: shellContext.idleBreathAnim,
          orbAnim: shellContext.orbAnim,
          idleRadarAnim: shellContext.idleRadarAnim,
        );

        if (templateId == 'fullscreen' || templateId == 'bottom_bar' || templateId.isEmpty) {
          return defaultView;
        }

        return TvLayoutFactory(
          templateId: templateId,
          defaultView: defaultView,
          settings: state.settings,
          orgName: state.orgName,
          qrCodeUrl: effectiveQr,
          menuItems: state.menuItems,
          businessType: 'restaurant',
          tickerNewsText: tickerNewsText,
        );
      },
    );
  }
}
