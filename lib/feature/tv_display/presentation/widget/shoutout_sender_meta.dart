import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/shoutout_request.dart';
import '../theme/tv_display_colors.dart';

/// Shoutout Sender Metadata component displaying timestamp, message index, and meta dashes.
class ShoutoutSenderMeta extends StatelessWidget {
  final ShoutoutRequest msg;
  final bool isVip;
  final double scale;
  final int currentIndex;
  final int totalMessages;
  final Animation<double> metaAnim;

  const ShoutoutSenderMeta({
    super.key,
    required this.msg,
    required this.isVip,
    required this.scale,
    required this.currentIndex,
    required this.totalMessages,
    required this.metaAnim,
  });

  Widget _metaDash(Color accent, double scale, {required String align}) {
    return SizedBox(
      width: 60 * scale,
      child: Row(
        children: [
          if (align == 'right') const Spacer(),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: align == 'left'
                      ? [
                          Colors.transparent,
                          accent.withValues(alpha: 0.6),
                        ]
                      : [
                          accent.withValues(alpha: 0.6),
                          Colors.transparent,
                        ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color accent =
        isVip ? TvDisplayColors.goldAccent : TvDisplayColors.accentPink;
    return AnimatedBuilder(
      animation: metaAnim,
      builder: (context, child) {
        return Opacity(
          opacity: metaAnim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - metaAnim.value) * 12),
            child: child,
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _metaDash(accent, scale, align: 'left'),
          SizedBox(width: 12 * scale),
          Icon(
            Icons.schedule_send_rounded,
            size: 11 * scale,
            color: accent.withValues(alpha: 0.6),
          ),
          SizedBox(width: 6 * scale),
          Text(
            DateFormat('HH:mm').format(msg.createdAt),
            style: GoogleFonts.spaceMono(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: accent.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: 18 * scale),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 18 * scale),
          Text(
            'MSG ${currentIndex + 1}/$totalMessages',
            style: GoogleFonts.spaceMono(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: accent.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: 12 * scale),
          _metaDash(accent, scale, align: 'right'),
        ],
      ),
    );
  }
}
