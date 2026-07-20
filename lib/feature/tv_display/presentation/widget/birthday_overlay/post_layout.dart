part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 1 — POST (Instagram feed style, portrait card)
// ═══════════════════════════════════════════════════════════════

class _PostLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _PostLayout({
    required this.state,
    required this.scale,
    required this.box,
    required this.imageUrl,
    required this.name,
    required this.wish,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final nameSize = min(box.maxWidth * 0.045, 64.0) * scale;
    final wishSize = 18 * scale;
    final emojiSize = 32 * scale;

    return _BirthdayCardShell(
      state: state,
      scale: scale,
      box: box,
      maxWidthFactor: 0.55,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _BirthdayImage(
                  state: state,
                  url: imageUrl,
                  scale: scale,
                  box: box,
                  accent: accent,
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.35),
                          ],
                          stops: const [0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24 * scale,
              18 * scale,
              24 * scale,
              22 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36 * scale,
                      height: 36 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [accent, const Color(0xFFFF007A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.5),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.cake_rounded,
                        color: Colors.white,
                        size: 20 * scale,
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'happy_birthday',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Sponsored · Just now',
                            style: GoogleFonts.spaceMono(
                              fontSize: 11 * scale,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _LiveDot(scale: scale, color: accent),
                  ],
                ),
                SizedBox(height: 16 * scale),
                _EntryAnimated(
                  animation: state._nameIn,
                  child: _ShimmerName(
                    state: state,
                    name: name,
                    accent: accent,
                    fontSize: nameSize,
                    scale: scale,
                    align: TextAlign.left,
                  ),
                ),
                if (wish.isNotEmpty) ...[
                  SizedBox(height: 8 * scale),
                  _WishLine(
                    state: state,
                    wish: wish,
                    fontSize: wishSize,
                    scale: scale,
                    maxLines: 3,
                  ),
                ],
                SizedBox(height: 18 * scale),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14 * scale),
                Row(
                  children: [
                    _PostAction(
                      icon: Icons.favorite_rounded,
                      label: '2.4K',
                      color: const Color(0xFFFF3B6B),
                      scale: scale,
                      filled: true,
                    ),
                    SizedBox(width: 22 * scale),
                    _PostAction(
                      icon: Icons.mode_comment_rounded,
                      label: '184',
                      color: Colors.white,
                      scale: scale,
                    ),
                    SizedBox(width: 22 * scale),
                    _PostAction(
                      icon: Icons.send_rounded,
                      label: 'Share',
                      color: Colors.white,
                      scale: scale,
                    ),
                    const Spacer(),
                    _EmojiRow(
                      state: state,
                      emojis: const ['🎂', '🎉', '🎈', '🎁', '🥳'],
                      scale: scale,
                      size: emojiSize,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  final double scale;
  final Color color;
  const _LiveDot({required this.scale, required this.color});
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8 * widget.scale,
              height: 8 * widget.scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.7),
                    blurRadius: 8 * (0.5 + _c.value * 0.8),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6 * widget.scale),
            Text(
              'LIVE',
              style: GoogleFonts.spaceMono(
                fontSize: 11 * widget.scale,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PostAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double scale;
  final bool filled;
  const _PostAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.scale,
    this.filled = false,
  });
  @override
  State<_PostAction> createState() => _PostActionState();
}

class _PostActionState extends State<_PostAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartCtrl;
  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.filled) {
          _heartCtrl.forward(from: 0.6);
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.3).animate(
              CurvedAnimation(parent: _heartCtrl, curve: Curves.elasticOut),
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: 20 * widget.scale,
            ),
          ),
          SizedBox(width: 6 * widget.scale),
          Text(
            widget.label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13 * widget.scale,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
