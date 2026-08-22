import 'package:flutter/material.dart';
import '../widget/tv_base_shell.dart';
import '../widget/tv_layout_factory.dart';
import '../widget/views/butcher_idle_view.dart';

/// Dedicated Independent UI Screen for Butcher House (ሥጋ ቤት) business type.
/// Features 4K Bento Grid meat cuts, daily kilo pricing, prep matrix, and digestive upsells.
/// Excludes nightclub liveboard takeovers while supporting split-screen Match Mode and Telebirr QR payments.
class ButcherDisplayScreen extends StatelessWidget {
  final String organizationId;

  const ButcherDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return TvBaseShell(
      organizationId: organizationId,
      businessType: 'butcher',
      builder: (context, state, shellContext) {
        final templateId = (state.settings?.tvLayoutTemplate ?? 'fullscreen').trim().toLowerCase();
        final tickerNewsText = state.settings?.tickerNewsText ?? '';

        final effectiveQr = (state.qrCodeUrl != null && state.qrCodeUrl!.isNotEmpty)
            ? state.qrCodeUrl
            : state.settings?.qrCodeUrl;

        final defaultView = ButcherIdleView(
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
          businessType: 'butcher',
          tickerNewsText: tickerNewsText,
        );
      },
    );
  }
}
