import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/models/music_request.dart';
import '../cubit/tv_display_state.dart';
import '../theme/tv_display_colors.dart';
import '../util/tv_display_content_helper.dart';
import '../widget/birthday_overlay/birthday_overlay.dart';
import '../widget/now_playing_screen.dart';
import '../widget/tv_active_shoutouts_view.dart';
import '../widget/tv_base_shell.dart';
import '../widget/views/nightclub_idle_view.dart';

/// Dedicated Independent UI Screen for Nightclub business type.
/// Features high-energy nightlife shoutouts, DJ music request overlays, and birthday wishes.
class NightclubDisplayScreen extends StatelessWidget {
  final String organizationId;

  const NightclubDisplayScreen({
    super.key,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return TvBaseShell(
      organizationId: organizationId,
      businessType: 'nightclub',
      builder: (context, state, shellContext) {
        // Nightlife Specific Phases: Music Requests & Birthday Celebrations
        if (state.showMusicPhase) {
          return _buildNowPlayingScreen(state.nowPlaying);
        }
        if (state.showBirthdayPhase) {
          return _buildBirthdayOverlay(state);
        }
        if (state.showBirthdayWishesPhase) {
          return _buildBirthdayWishOverlay(state);
        }

        // Active Shoutouts View
        if (!state.isIdleMode && state.messages.isNotEmpty) {
          return TvActiveShoutoutsView(
            state: state,
            shellContext: shellContext,
            businessType: 'nightclub',
          );
        }

        // Idle Content
        final slides =
            TvDisplayContentHelper.getEffectiveSlides(state, 'nightclub');
        final suggestions =
            TvDisplayContentHelper.getEffectiveSuggestions(state, 'nightclub');

        return NightclubIdleView(
          effectiveSlides: slides,
          effectiveSuggestions: suggestions,
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

  Widget _buildBirthdayOverlay(TvDisplayState state) {
    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return BirthdayOverlay(
            imageUrl: state.birthdayImageUrls.isNotEmpty
                ? state.birthdayImageUrls.first
                : null,
            name: state.birthdayName,
            wish: state.birthdayWish,
            scale: scale,
            layout: BirthdayLayout.auto,
            accentColor: const Color(0xFFFBBF24),
            isAsset: false,
          );
        },
      ),
    );
  }

  Widget _buildBirthdayWishOverlay(TvDisplayState state) {
    if (state.birthdayWishes.isEmpty) return const SizedBox.shrink();
    final wish = state.birthdayWishes[state.birthdayWishIndex];
    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final isAnonymous = wish['isAnonymous'] == true;
          final name = isAnonymous
              ? 'Anonymous'
              : (wish['userName'] as String? ?? 'Someone');
          final content = wish['content'] as String? ?? '';
          final toName = wish['toName'] as String? ?? state.birthdayName;
          return BirthdayOverlay(
            imageUrl: state.birthdayImageUrls.isNotEmpty
                ? state.birthdayImageUrls.first
                : null,
            name: toName,
            wish: '$name says: $content',
            scale: scale,
            layout: BirthdayLayout.auto,
            accentColor: const Color(0xFFFBBF24),
            isAsset: false,
          );
        },
      ),
    );
  }

  Widget _buildNowPlayingScreen(MusicRequest? req) {
    if (req == null) return const SizedBox.shrink();
    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return NowPlayingScreen(request: req, scale: scale);
        },
      ),
    );
  }
}
