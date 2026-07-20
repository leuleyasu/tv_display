part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 8 — AURORA (Northern lights + stars, no image required)
// ═══════════════════════════════════════════════════════════════

class _AuroraLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _AuroraLayout({
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
    final nameSize = min(box.maxWidth * 0.06, 88.0) * scale;

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
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: const Color(0xFF020416),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Stars
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: state._shimmerCtrl,
                    builder: (context, _) => CustomPaint(
                      painter:
                          _StarsPainter(progress: state._shimmerCtrl.value),
                    ),
                  ),
                ),
                // Aurora waves
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: state._glowCtrl,
                    builder: (context, _) => CustomPaint(
                      painter: _AuroraPainter(
                        progress: state._glowCtrl.value,
                        colors: [
                          accent,
                          const Color(0xFF06B6D4),
                          const Color(0xFF8B5CF6),
                          const Color(0xFF10B981),
                        ],
                      ),
                    ),
                  ),
                ),
                // Optional image as a soft moon-disk
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Positioned(
                    top: 28 * scale,
                    right: 28 * scale,
                    width: 130 * scale,
                    height: 130 * scale,
                    child: AnimatedBuilder(
                      animation: state._glowCtrl,
                      child: ClipOval(
                        child: _BirthdayImage(
                          state: state,
                          url: imageUrl,
                          scale: scale,
                          box: box,
                          accent: accent,
                        ),
                      ),
                      builder: (context, child) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(
                                  alpha: 0.4 * state._glowCtrl.value),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                    ),
                  ),
                // Foreground content
                Positioned(
                  left: 40 * scale,
                  right: 40 * scale,
                  bottom: 60 * scale,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _EntryAnimated(
                        animation: state._nameIn,
                        child: Text(
                          '✦  TONIGHT  ✦',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12 * scale,
                            color: Colors.white.withValues(alpha: 0.7),
                            letterSpacing: 6,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      _EntryAnimated(
                        animation: state._nameIn,
                        rise: 0,
                        child: Text(
                          name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: nameSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.0,
                            shadows: [
                              Shadow(color: accent, blurRadius: 30),
                              Shadow(
                                  color: accent.withValues(alpha: 0.5),
                                  blurRadius: 60),
                            ],
                          ),
                        ),
                      ),
                      if (wish.isNotEmpty) ...[
                        SizedBox(height: 14 * scale),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 520 * scale),
                          child: _WishLine(
                            state: state,
                            wish: wish,
                            fontSize: 16 * scale,
                            scale: scale,
                            maxLines: 3,
                          ),
                        ),
                      ],
                      SizedBox(height: 18 * scale),
                      _EmojiRow(
                        state: state,
                        emojis: const ['🎂', '🌌', '✨', '🎉', '🥂', '🌠'],
                        scale: scale,
                        size: 28,
                      ),
                    ],
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

class _StarsPainter extends CustomPainter {
  final double progress;
  _StarsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rng = Random(7);
    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = 0.4 + rng.nextDouble() * 1.6;
      final twinkle = (sin(progress * 6.28 * 2 + i) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: 0.3 + 0.7 * twinkle);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _AuroraPainter extends CustomPainter {
  final double progress;
  final List<Color> colors;
  _AuroraPainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    for (int i = 0; i < colors.length; i++) {
      final path = Path();
      final baseY = h * (0.2 + i * 0.12);
      final amp = 60.0 + 20.0 * i;
      final offset = progress * 6.28;
      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 8) {
        final y = baseY +
            sin((x / size.width) * 4 * pi + offset + i) * amp +
            cos((x / size.width) * 2 * pi + offset * 0.7 + i) * amp * 0.5;
        path.lineTo(x, y);
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors[i].withValues(alpha: 0.35 - i * 0.05),
            colors[i].withValues(alpha: 0.0),
          ],
        ).createShader(Offset.zero & size)
        ..blendMode = BlendMode.plus;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
