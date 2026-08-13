import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/models/shoutout_request.dart';
import '../../../../core/models/settings_model.dart';
import '../theme/tv_display_colors.dart';
import 'animated_shoutout_name.dart';
import 'message_frame.dart';
import 'shoutout_message_quote.dart';
import 'shoutout_sender_meta.dart';
import 'vip_badge.dart';

/// Framed Shoutout Card Content container with entrance animations and bracket frame.
class FramedShoutoutContent extends StatelessWidget {
  final ShoutoutRequest msg;
  final bool isVip;
  final BoxConstraints box;
  final double scale;
  final SettingsModel? settings;
  final int currentIndex;
  final int totalMessages;
  final AnimationController entryCtrl;
  final Animation<double> entryAnim;
  final Animation<double> frameAnim;
  final Animation<double> scanAnim;
  final Animation<double> vipSweepAnim;
  final Animation<double> nameAnim;
  final Animation<double> orbAnim;
  final Animation<double> metaAnim;
  final bool noPadding;

  const FramedShoutoutContent({
    super.key,
    required this.msg,
    required this.isVip,
    required this.box,
    required this.scale,
    required this.settings,
    required this.currentIndex,
    required this.totalMessages,
    required this.entryCtrl,
    required this.entryAnim,
    required this.frameAnim,
    required this.scanAnim,
    required this.vipSweepAnim,
    required this.nameAnim,
    required this.orbAnim,
    required this.metaAnim,
    this.noPadding = false,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSizeCap = settings?.fontSize ?? 72.0;
    final double userNameSize = min(
          box.maxWidth * 0.028,
          fontSizeCap * 0.72,
        ) *
        scale;
    final double msgSize = min(
          box.maxWidth * 0.05,
          fontSizeCap * 0.95,
        ) *
        scale;

    final Color accent =
        isVip ? TvDisplayColors.goldAccent : TvDisplayColors.accentPink;
    final Color accentSoft =
        isVip ? TvDisplayColors.amberAccent : TvDisplayColors.pinkSoft;
    final Color accentDeep =
        isVip ? TvDisplayColors.goldDeep : TvDisplayColors.accentPink;

    final bool hasUser = msg.userName != null && msg.userName!.isNotEmpty;

    final double cardMaxWidth =
        noPadding ? double.infinity : box.maxWidth * 0.78;
    final double cardPaddingH = 48 * scale;
    final double cardPaddingV = 38 * scale;

    final card = AnimatedBuilder(
      animation: entryCtrl,
      builder: (context, child) {
        final double t = entryAnim.value;
        final double slideX = (1 - t) * 40;
        final double scaleIn = 0.94 + 0.06 * t;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(slideX, 0),
            child: Transform.scale(
              scale: scaleIn,
              child: child,
            ),
          ),
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardMaxWidth),
        child: MessageFrame(
          accent: accent,
          accentDeep: accentDeep,
          drawProgress: frameAnim.value,
          scanProgress: scanAnim.value,
          isVip: isVip,
          borderRadius: 18,
          child: Stack(
            children: [
              if (isVip)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: vipSweepAnim,
                      builder: (_, __) {
                        return CustomPaint(
                          painter: GoldSweepPainter(
                            progress: vipSweepAnim.value,
                            goldAccent: TvDisplayColors.goldAccent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: cardPaddingH,
                  vertical: cardPaddingV,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    VipBadge(
                      isVip: isVip,
                      scale: scale,
                      nameAnim: nameAnim,
                    ),
                    SizedBox(height: box.maxHeight * 0.04),
                    if (hasUser) ...[
                      AnimatedShoutoutName(
                        name: msg.userName!.toUpperCase(),
                        accent: accent,
                        accentSoft: accentSoft,
                        fontSize: userNameSize,
                        scale: scale,
                        isVip: isVip,
                        nameAnim: nameAnim,
                        orbAnim: orbAnim,
                        vipSweepAnim: vipSweepAnim,
                        fontFamily: settings?.fontFamily,
                      ),
                      SizedBox(height: box.maxHeight * 0.035),
                    ],
                    ShoutoutMessageQuote(
                      text: msg.message.trim().isEmpty
                          ? '> DROP YOUR SHOUTOUT'
                          : '> ${msg.message}',
                      accent: accent,
                      fontSize: msgSize,
                      scale: scale,
                      currentIndex: currentIndex,
                      entryAnim: entryAnim,
                      orbAnim: orbAnim,
                      fontFamily: settings?.fontFamily,
                    ),
                    SizedBox(height: box.maxHeight * 0.035),
                    ShoutoutSenderMeta(
                      msg: msg,
                      isVip: isVip,
                      scale: scale,
                      currentIndex: currentIndex,
                      totalMessages: totalMessages,
                      metaAnim: metaAnim,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (noPadding) return card;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: box.maxWidth * 0.1),
      child: card,
    );
  }
}
