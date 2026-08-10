import 'package:flutter/material.dart';

import '../widget/tv_active_shoutouts_view.dart';
import '../widget/tv_base_shell.dart';
import '../widget/views/lounge_idle_view.dart';

/// Dedicated Independent UI Screen for Lounge business type.
class LoungeDisplayScreen extends StatelessWidget {
  final String organizationId;

  const LoungeDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return TvBaseShell(
      organizationId: organizationId,
      businessType: 'lounge',
      builder: (context, state, shellContext) {
        if (!state.isIdleMode && state.messages.isNotEmpty) {
          return TvActiveShoutoutsView(
            state: state,
            shellContext: shellContext,
            businessType: 'lounge',
          );
        }

        return LoungeIdleView(
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
