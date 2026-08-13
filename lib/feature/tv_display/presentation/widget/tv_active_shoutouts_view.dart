import 'dart:math';
import 'package:flutter/material.dart';

import '../cubit/tv_display_state.dart';
import '../theme/tv_display_colors.dart';
import 'ambient_orbs.dart';
import 'framed_shoutout_content.dart';
import 'shoutout_message_qr.dart';
import 'shoutout_progress_strip.dart';
import 'tv_base_shell.dart';
import 'tv_pagination_dots.dart';
import 'tv_top_header_bar.dart';

/// Standard visual layout for rendering live user shoutout messages.
/// Can be composed directly by any business screen when user shoutouts are active.
class TvActiveShoutoutsView extends StatelessWidget {
  final TvDisplayState state;
  final TvShellContext shellContext;
  final String businessType;

  const TvActiveShoutoutsView({
    super.key,
    required this.state,
    required this.shellContext,
    required this.businessType,
  });

  @override
  Widget build(BuildContext context) {
    if (state.messages.isEmpty || state.currentIndex >= state.messages.length) {
      return const SizedBox.shrink();
    }

    final msg = state.messages[state.currentIndex];
    final isVip = msg.isVip;
    final bool hasQr =
        state.qrCodeUrl != null && state.qrCodeUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: TvDisplayColors.backgroundDeep,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          return Stack(
            children: [
              AmbientOrbs(
                isVip: isVip,
                box: box,
                businessType: businessType,
                orbAnim: shellContext.orbAnim,
              ),
              ShoutoutProgressStrip(
                isVip: isVip,
                progressValue: state.progressValue,
                businessType: businessType,
              ),
              TvTopHeaderBar(
                scale: scale,
                businessType: businessType,
                orgName: state.orgName,
                now: shellContext.now,
                orbAnim: shellContext.orbAnim,
              ),
              Center(
                child: FadeTransition(
                  opacity: shellContext.fadeAnim,
                  child: hasQr
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: box.maxWidth * 0.06),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ShoutoutMessageQr(
                                qrCodeUrl: state.qrCodeUrl,
                                scale: scale,
                                customQrSize: state.settings?.qrCodeSize,
                              ),
                              SizedBox(width: box.maxWidth * 0.05),
                              Flexible(
                                child: FramedShoutoutContent(
                                  msg: msg,
                                  isVip: isVip,
                                  box: box,
                                  scale: scale,
                                  settings: state.settings,
                                  currentIndex: state.currentIndex,
                                  totalMessages: state.messages.length,
                                  entryCtrl: shellContext.entryCtrl,
                                  entryAnim: shellContext.entryAnim,
                                  frameAnim: shellContext.frameAnim,
                                  scanAnim: shellContext.scanAnim,
                                  vipSweepAnim: shellContext.vipSweepAnim,
                                  nameAnim: shellContext.nameAnim,
                                  orbAnim: shellContext.orbAnim,
                                  metaAnim: shellContext.metaAnim,
                                  noPadding: true,
                                ),
                              ),
                            ],
                          ),
                        )
                      : FramedShoutoutContent(
                          msg: msg,
                          isVip: isVip,
                          box: box,
                          scale: scale,
                          settings: state.settings,
                          currentIndex: state.currentIndex,
                          totalMessages: state.messages.length,
                          entryCtrl: shellContext.entryCtrl,
                          entryAnim: shellContext.entryAnim,
                          frameAnim: shellContext.frameAnim,
                          scanAnim: shellContext.scanAnim,
                          vipSweepAnim: shellContext.vipSweepAnim,
                          nameAnim: shellContext.nameAnim,
                          orbAnim: shellContext.orbAnim,
                          metaAnim: shellContext.metaAnim,
                        ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: TvPaginationDots(
                    totalCount: state.messages.length,
                    currentIndex: state.currentIndex,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
