import 'package:flutter/material.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import '../../theme/tv_display_colors.dart';

/// Renders the 5-8% Bottom Marquee Ticker for Match Mode.
/// Continuously scrolls live scores, venue match specials, and sponsor messages.
class MatchBottomTicker extends StatefulWidget {
  final SettingsModel settings;
  final double scale;

  const MatchBottomTicker({
    super.key,
    required this.settings,
    required this.scale,
  });

  @override
  State<MatchBottomTicker> createState() => _MatchBottomTickerState();
}

class _MatchBottomTickerState extends State<MatchBottomTicker>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _scrollAnimationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..addListener(() {
        if (_scrollController.hasClients) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          if (maxScroll > 0) {
            _scrollController.jumpTo(_scrollAnimationController.value * maxScroll);
          }
        }
      })
      ..repeat();
  }

  @override
  void dispose() {
    _scrollAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scale;
    final venueName = widget.settings.organizationName ?? widget.settings.houseName ?? 'Venue';
    final customTicker = widget.settings.matchTickerText ?? widget.settings.tickerNewsText;

    final tickerItems = [
      if (customTicker.isNotEmpty) '📢 $customTicker',
      '⚽ LIVE MATCH BROADCAST • WELCOME TO ${venueName.toUpperCase()}',
      '🍻 MATCH SPECIAL: Buy 2 Draft Beers Get 1 Free During Halftime!',
      '💳 Scan on-screen QR code to pay table bills & order drinks instantly',
      '⚡ Powered by HoursSignage DOOH Smart TV Network',
      '🎵 VIP DJ Song Queue & Shoutouts active from your phone',
    ];

    return Container(
      height: 48 * s,
      decoration: BoxDecoration(
        color: TvDisplayColors.tickerBackground,
        borderRadius: BorderRadius.circular(10 * s),
        border: Border.all(color: Colors.white12, width: 1 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10 * s,
            offset: Offset(0, -2 * s),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Fixed Badge: LIVE UPDATES
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14 * s),
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [TvDisplayColors.accentPink, TvDisplayColors.accentPurple],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(9 * s),
                bottomLeft: Radius.circular(9 * s),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: Colors.white, size: 18 * s),
                SizedBox(width: 6 * s),
                Text(
                  'MATCH TICKER',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12 * s,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          // Scrolling Marquee Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final text = tickerItems[index % tickerItems.length];
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24 * s),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5 * s,
                          height: 5 * s,
                          decoration: const BoxDecoration(
                            color: TvDisplayColors.accentCyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 10 * s),
                        Text(
                          text,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13 * s,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
