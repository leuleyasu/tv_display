import 'package:flutter/material.dart';

/// Stateful Smooth Horizontal Marquee Scrolling Ticker Widget
class MarqueeTickerText extends StatefulWidget {
  final String text;
  final double scale;
  final TextStyle style;

  const MarqueeTickerText({
    super.key,
    required this.text,
    required this.scale,
    required this.style,
  });

  @override
  State<MarqueeTickerText> createState() => _MarqueeTickerTextState();
}

class _MarqueeTickerTextState extends State<MarqueeTickerText>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 28),
    )..addListener(() {
        if (_scrollController.hasClients) {
          final maxExtent = _scrollController.position.maxScrollExtent;
          if (maxExtent > 0) {
            _scrollController.jumpTo(_animController.value * maxExtent);
          }
        }
      });
    _animController.repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * widget.scale),
        child: Text(
          '${widget.text}   ***   ${widget.text}',
          style: widget.style,
        ),
      ),
    );
  }
}
