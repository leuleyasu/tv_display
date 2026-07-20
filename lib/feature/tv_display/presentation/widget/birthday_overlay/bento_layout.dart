part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 7 — BENTO (Apple-style bento grid)
// ═══════════════════════════════════════════════════════════════

class _BentoLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;
  final String? badgeText;

  const _BentoLayout({
    required this.state,
    required this.scale,
    required this.box,
    required this.imageUrl,
    required this.name,
    required this.wish,
    required this.accent,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final bigName = min(box.maxWidth * 0.06, 96.0) * scale;
    return AnimatedBuilder(
      animation: state._entranceCtrl,
      builder: (context, child) {
        return Opacity(
          opacity: state._entranceFade.value,
          child: SlideTransition(
            position: state._entranceSlide,
            child: ScaleTransition(
              scale: state._entranceScale,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: box.maxWidth * 0.92),
                child: child,
              ),
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Row(
                children: [
                  // Big name tile
                  Expanded(
                    flex: 6,
                    child: _BentoTile(
                      color: accent,
                      scale: scale,
                      state: state,
                      delay: 0.0,
                      child: Padding(
                        padding: EdgeInsets.all(24 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _EntryAnimated(
                              animation: state._nameIn,
                              rise: 0,
                              child: Row(
                                children: [
                                  Text('🎂',
                                      style: TextStyle(fontSize: 28 * scale)),
                                  SizedBox(width: 8 * scale),
                                  Text(
                                    'HAPPY BIRTHDAY',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13 * scale,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomLeft,
                              child: _EntryAnimated(
                                animation: state._nameIn,
                                rise: 0,
                                child: Text(
                                  name,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: bigName,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                    height: 0.95,
                                    letterSpacing: -2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14 * scale),
                  // Photo tile
                  Expanded(
                    flex: 4,
                    child: _BentoTile(
                      color: const Color(0xFF1a1a2e),
                      scale: scale,
                      state: state,
                      delay: 0.1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _BirthdayImage(
                          state: state,
                          url: imageUrl,
                          scale: scale,
                          box: box,
                          accent: accent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14 * scale),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  // Wish tile
                  Expanded(
                    flex: 4,
                    child: _BentoTile(
                      color: const Color(0xFF14142b),
                      scale: scale,
                      state: state,
                      delay: 0.2,
                      child: Padding(
                        padding: EdgeInsets.all(20 * scale),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'THE WISH',
                              style: GoogleFonts.spaceMono(
                                fontSize: 10 * scale,
                                color: accent,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 8 * scale),
                            if (wish.isNotEmpty)
                              Expanded(
                                child: _WishLine(
                                  state: state,
                                  wish: wish,
                                  fontSize: 18 * scale,
                                  scale: scale,
                                  maxLines: 4,
                                ),
                              )
                            else
                              Text(
                                'Wishing you the best',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18 * scale,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14 * scale),
                  // Stat tile
                  Expanded(
                    flex: 2,
                    child: _BentoTile(
                      color: const Color(0xFFFF007A),
                      scale: scale,
                      state: state,
                      delay: 0.3,
                      child: Padding(
                        padding: EdgeInsets.all(16 * scale),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🎉',
                              style: TextStyle(fontSize: 32 * scale),
                            ),
                            SizedBox(height: 6 * scale),
                            if (badgeText != null)
                              Text(
                                badgeText!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            Text(
                              'YEARS',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.spaceMono(
                                fontSize: 9 * scale,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 2,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 14 * scale),
                  // Emoji tile
                  Expanded(
                    flex: 3,
                    child: _BentoTile(
                      color: const Color(0xFF06B6D4),
                      scale: scale,
                      state: state,
                      delay: 0.4,
                      child: Padding(
                        padding: EdgeInsets.all(16 * scale),
                        child: _EmojiRow(
                          state: state,
                          emojis: const ['🎂', '🎉', '🎈', '🎁', '🥳', '✨'],
                          scale: scale,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  final Color color;
  final double scale;
  final _BirthdayOverlayState state;
  final double delay;
  final Widget child;
  const _BentoTile({
    required this.color,
    required this.scale,
    required this.state,
    required this.child,
    this.delay = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state._entranceCtrl,
      builder: (context, c) {
        final t = ((state._entranceCtrl.value - delay) / 0.6).clamp(0.0, 1.0);
        return Opacity(
          opacity: Curves.easeOut.transform(t),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 20),
            child: Transform.scale(
              scale: 0.92 + 0.08 * Curves.easeOutCubic.transform(t),
              child: c,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      ),
    );
  }
}
