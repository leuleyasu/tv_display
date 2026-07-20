part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 3 — SPLIT (landscape magazine cover, best for TV)
// ═══════════════════════════════════════════════════════════════

class _SplitLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;
  final String? badgeText;

  const _SplitLayout({
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
    final nameSize = min(box.maxWidth * 0.04, 64.0) * scale;
    final wishSize = 19 * scale;

    return _BirthdayCardShell(
      state: state,
      scale: scale,
      box: box,
      maxWidthFactor: 0.85,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 45,
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
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            accent.withValues(alpha: 0.0),
                            accent,
                            accent.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 55,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  40 * scale,
                  28 * scale,
                  40 * scale,
                  28 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _EntryAnimated(
                      animation: state._nameIn,
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: accent,
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10 * scale),
                          Text(
                            'TODAY · CELEBRATION',
                            style: GoogleFonts.spaceMono(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                    _ShimmerName(
                      state: state,
                      name: name,
                      accent: accent,
                      fontSize: nameSize,
                      scale: scale,
                      align: TextAlign.left,
                    ),
                    SizedBox(height: 14 * scale),
                    Row(
                      children: [
                        Container(
                          width: 60 * scale,
                          height: 2,
                          decoration: BoxDecoration(color: accent),
                        ),
                        if (badgeText != null) ...[
                          SizedBox(width: 12 * scale),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10 * scale,
                              vertical: 4 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.4),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeText!,
                              style: GoogleFonts.spaceMono(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                    if (wish.isNotEmpty)
                      _WishLine(
                        state: state,
                        wish: wish,
                        fontSize: wishSize,
                        scale: scale,
                        maxLines: 3,
                      ),
                    SizedBox(height: 18 * scale),
                    _EmojiRow(
                      state: state,
                      emojis: const ['🎂', '🎉', '🎈', '🎁', '🥳', '✨'],
                      scale: scale,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
