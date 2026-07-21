part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 4 — NEON (Cyberpunk, animated grid + scanlines + glow)
// ═══════════════════════════════════════════════════════════════

class _NeonLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _NeonLayout({
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
    final nameSize = min(box.maxWidth * 0.05, 72.0) * scale;

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
                constraints: BoxConstraints(maxWidth: box.maxWidth * 0.6),
                child: child,
              ),
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cyberpunk dark gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0a0014),
                      Color(0xFF1a0033),
                      Color(0xFF000010)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              // Animated perspective grid
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: state._shimmerCtrl,
                  builder: (context, _) => CustomPaint(
                    painter: _NeonGridPainter(
                      progress: state._shimmerCtrl.value,
                      color: accent,
                    ),
                  ),
                ),
              ),
              // Image (hexagon-clipped) on the right side as a poster
              if (imageUrl != null && imageUrl!.isNotEmpty)
                Positioned(
                  top: 24 * scale,
                  right: 24 * scale,
                  width: 140 * scale,
                  height: 140 * scale,
                  child: AnimatedBuilder(
                    animation: state._glowCtrl,
                    builder: (context, child) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(
                                alpha: 0.6 * state._glowCtrl.value),
                            blurRadius: 30,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFF007A)
                                .withValues(alpha: 0.4 * state._glowCtrl.value),
                            blurRadius: 50,
                          ),
                        ],
                      ),
                      child: ClipOval(
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
                ),
              // Scanline overlay
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ScanlinePainter(),
                  ),
                ),
              ),
              // Big neon title
              Positioned(
                left: 28 * scale,
                right: 28 * scale,
                bottom: 80 * scale,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _EntryAnimated(
                      animation: state._nameIn,
                      child: Text(
                        'HAPPY',
                        style: GoogleFonts.orbitron(
                          fontSize: nameSize * 0.6,
                          fontWeight: FontWeight.w900,
                          color: accent.withValues(alpha: 0.7),
                          letterSpacing: 8,
                          shadows: [
                            Shadow(color: accent, blurRadius: 20),
                          ],
                        ),
                      ),
                    ),
                    _EntryAnimated(
                      animation: state._nameIn,
                      rise: 0,
                      child: _NeonName(
                        state: state,
                        name: name,
                        accent: accent,
                        fontSize: nameSize,
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                    if (wish.isNotEmpty)
                      _WishLine(
                        state: state,
                        wish: wish,
                        fontSize: 15 * scale,
                        scale: scale,
                        maxLines: 2,
                      ),
                  ],
                ),
              ),
              // Neon tags
              Positioned(
                left: 28 * scale,
                bottom: 28 * scale,
                child: _EntryAnimated(
                  animation: state._emojisIn,
                  rise: 0,
                  child: Row(
                    children: [
                      _NeonChip(
                          label: 'SYS.DATE/TODAY', color: accent, scale: scale),
                      SizedBox(width: 10 * scale),
                      _NeonChip(
                          label: 'LEVEL UP',
                          color: const Color(0xFFFF007A),
                          scale: scale),
                    ],
                  ),
                ),
              ),
              // Floating emoji corner
              Positioned(
                right: 24 * scale,
                bottom: 24 * scale,
                child: _EntryAnimated(
                  animation: state._emojisIn,
                  rise: 0,
                  child: Text('🎂',
                      style: TextStyle(fontSize: 48 * scale, shadows: [
                        Shadow(color: accent, blurRadius: 30),
                      ])),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeonName extends StatelessWidget {
  final _BirthdayOverlayState state;
  final String name;
  final Color accent;
  final double fontSize;
  const _NeonName({
    required this.state,
    required this.name,
    required this.accent,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state._glowCtrl,
      builder: (context, _) {
        return Text(
          name.toUpperCase(),
          style: GoogleFonts.orbitron(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 4,
            height: 1.0,
            shadows: [
              Shadow(color: accent, blurRadius: 30 * state._glowCtrl.value),
              Shadow(color: accent.withValues(alpha: 0.8), blurRadius: 50),
              Shadow(
                  color: const Color(0xFFFF007A).withValues(alpha: 0.4),
                  blurRadius: 80),
            ],
          ),
        );
      },
    );
  }
}

class _NeonChip extends StatelessWidget {
  final String label;
  final Color color;
  final double scale;
  const _NeonChip(
      {required this.label, required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10),
        ],
      ),
      child: Text(
        label,
        style: GoogleFonts.spaceMono(
          fontSize: 10 * scale,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: color,
        ),
      ),
    );
  }
}

class _NeonGridPainter extends CustomPainter {
  final double progress;
  final Color color;
  _NeonGridPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 1;
    // Perspective floor grid
    final centerX = size.width / 2;
    final horizonY = size.height * 0.5;
    // Vertical lines converging
    for (int i = 0; i < 20; i++) {
      final t = (i - 9.5) / 10;
      final x = centerX + t * size.width * 0.8;
      canvas.drawLine(Offset(centerX, horizonY), Offset(x, size.height), paint);
    }
    // Horizontal scrolling lines
    for (int i = 0; i < 12; i++) {
      final t = ((i / 12) + progress * 0.3) % 1.0;
      final y = horizonY + t * (size.height - horizonY);
      final alpha = (t * t).clamp(0.05, 0.6);
      final p = Paint()
        ..color = color.withValues(alpha: alpha)
        ..strokeWidth = 1.2;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _NeonGridPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.04);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) => false;
}
