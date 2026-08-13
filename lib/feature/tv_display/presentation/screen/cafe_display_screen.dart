import 'package:flutter/material.dart';

import '../widget/tv_active_shoutouts_view.dart';
import '../widget/tv_base_shell.dart';
import '../widget/views/cafe_idle_view.dart';

/// Dedicated Independent UI Screen for Cafe business type.
/// Decoupled from monolithic TvDisplayScreen. Fully flexible for custom Cafe UI layouts.
class CafeDisplayScreen extends StatelessWidget {
  final String organizationId;

  const CafeDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return TvBaseShell(
      organizationId: organizationId,
      businessType: 'cafe',
      builder: (context, state, shellContext) {
        // If live user shoutout messages are active, show the shoutouts view layer
        if (!state.isIdleMode && state.messages.isNotEmpty) {
          return TvActiveShoutoutsView(
            state: state,
            shellContext: shellContext,
            businessType: 'cafe',
          );
        }

        return CafeIdleView(
          menuItems: state.menuItems,
          idleSlideIndex: state.idleSlideIndex,
          settings: state.settings,
          orgName: state.orgName,
          now: shellContext.now,
          qrCodeUrl: state.qrCodeUrl,
          energyLevel: shellContext.energyLevel,
          isWorldCupEnabled: state.isWorldCupEnabled,
          fadeAnim: shellContext.fadeAnim,
          idleBreathAnim: shellContext.idleBreathAnim,
          orbAnim: shellContext.orbAnim,
          idleRadarAnim: shellContext.idleRadarAnim,
        );
      },
    );
  }
}
