import 'dart:math';
import 'package:flutter/material.dart';
import '../cubit/tv_display_state.dart';
import '../theme/tv_display_colors.dart';
import 'birthday_overlay/birthday_overlay.dart';

/// Standalone display view for rendering birthday announcements and wishes overlays.
class TvBirthdayDisplayView extends StatelessWidget {
  final TvDisplayState state;
  final bool isWishesPhase;

  const TvBirthdayDisplayView({
    super.key,
    required this.state,
    this.isWishesPhase = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isWishesPhase) {
      if (state.birthdayWishes.isEmpty) return const SizedBox.shrink();
      final wish = state.birthdayWishes[state.birthdayWishIndex];
      final isAnonymous = wish['isAnonymous'] == true;
      final name = isAnonymous
          ? 'Anonymous'
          : (wish['userName'] as String? ?? 'Someone');
      final content = wish['content'] as String? ?? '';
      final toName = wish['toName'] as String? ?? state.birthdayName;

      return Scaffold(
        backgroundColor: TvDisplayColors.backgroundDeep,
        body: LayoutBuilder(
          builder: (ctx, box) {
            final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
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
}
