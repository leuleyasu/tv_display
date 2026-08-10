import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/models/music_request.dart';
import '../theme/tv_display_colors.dart';
import 'now_playing_screen.dart';

/// Standalone display view for rendering active music request screen.
class TvNowPlayingView extends StatelessWidget {
  final MusicRequest? request;

  const TvNowPlayingView({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    if (request == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return NowPlayingScreen(request: request!, scale: scale);
        },
      ),
    );
  }
}
