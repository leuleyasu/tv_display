part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 6 — CINEMA (Vintage film strip, projector spotlights)
// ═══════════════════════════════════════════════════════════════

class _CinemaLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _CinemaLayout({
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
    final nameSize = min(box.maxWidth * 0.06, 80.0) * scale;

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
                constraints: BoxConstraints(maxWidth: box.maxWidth * 0.7),
                child: child,
              ),
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: const Color(0xFF0a0a0a),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Sepia-warm gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.3),
                      radius: 1.4,
                      colors: [
                        accent.withValues(alpha: 0.25),
                        const Color(0xFF1a0e05),
                        const Color(0xFF000000),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Spotlight beams
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: state._glowCtrl,
                    builder: (context, _) => CustomPaint(
                      painter: _SpotlightPainter(
                        progress: state._glowCtrl.value,
                        color: accent,
                      ),
                    ),
                  ),
                ),
                // Image (sepia-treated via blend)
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      80 * scale,
                      50 * scale,
                      80 * scale,
                      50 * scale,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Stack(
                        children: [
                          _BirthdayImage(
                            state: state,
                            url: imageUrl,
                            scale: scale,
                            box: box,
                            accent: accent,
                          ),
                          // Sepia overlay
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accent.withValues(alpha: 0.35),
                                      Colors.black.withValues(alpha: 0.4),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Film perforations (top + bottom)
                Positioned.fill(
                  child: Column(
                    children: [
                      _FilmStrip(scale: scale, horizontal: true),
                      const Spacer(),
                      _FilmStrip(scale: scale, horizontal: true),
                    ],
                  ),
                ),
                // Title (vintage)
                Positioned(
                  bottom: 80 * scale,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _EntryAnimated(
                        animation: state._nameIn,
                        child: Text(
                          'HAPPY BIRTHDAY',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: nameSize * 0.4,
                            color: accent,
                            letterSpacing: 6,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      _EntryAnimated(
                        animation: state._nameIn,
                        rise: 0,
                        child: Text(
                          name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: nameSize,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                  color: accent.withValues(alpha: 0.6),
                                  blurRadius: 25),
                            ],
                          ),
                        ),
                      ),
                      if (wish.isNotEmpty) ...[
                        SizedBox(height: 10 * scale),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 500 * scale),
                          child: _WishLine(
                            state: state,
                            wish: '— $wish —',
                            fontSize: 14 * scale,
                            scale: scale,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // "Now Showing" badge
                Positioned(
                  top: 50 * scale,
                  right: 90 * scale,
                  child: _EntryAnimated(
                    animation: state._emojisIn,
                    rise: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 6 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        '★ NOW SHOWING ★',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                // Frame number corner
                Positioned(
                  top: 50 * scale,
                  left: 90 * scale,
                  child: _EntryAnimated(
                    animation: state._nameIn,
                    rise: 0,
                    child: Text(
                      'REEL 01 / 01',
                      style: GoogleFonts.spaceMono(
                        fontSize: 10 * scale,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilmStrip extends StatelessWidget {
  final double scale;
  final bool horizontal;
  const _FilmStrip({required this.scale, this.horizontal = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22 * scale,
      decoration: const BoxDecoration(color: Color(0xFF0a0a0a)),
      child: Row(
        children: List.generate(24, (i) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 6 * scale),
            child: Container(
              width: 14 * scale,
              height: 14 * scale,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final double progress;
  final Color color;
  _SpotlightPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0, -0.4 + (progress - 0.5) * 0.1),
        radius: 1.0,
        colors: [
          color.withValues(alpha: 0.25),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
