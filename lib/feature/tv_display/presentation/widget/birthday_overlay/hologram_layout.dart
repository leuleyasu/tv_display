part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 12 — HOLOGRAM (Star Wars projection, cyan glow)
// ═══════════════════════════════════════════════════════════════

class _HologramLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _HologramLayout({
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
    final cyan = const Color(0xFF38BDF8);

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
          borderRadius: BorderRadius.circular(8),
          child: Container(
            color: const Color(0xFF000000),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Glow background
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(0, -0.3),
                        radius: 1.2,
                        colors: [Color(0xFF0a1a2e), Color(0xFF000000)],
                      ),
                    ),
                  ),
                ),
                // Horizontal scan lines (very visible)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _HoloScanlinePainter()),
                  ),
                ),
                // Glitch overlay
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: state._glowCtrl,
                    builder: (context, _) => Opacity(
                      opacity: 0.5 + 0.5 * state._glowCtrl.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              cyan.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                            begin: Alignment(-1 + state._glowCtrl.value * 2, 0),
                            end: Alignment(1 + state._glowCtrl.value * 2, 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // "PROJECTING" header
                Positioned(
                  top: 24 * scale,
                  left: 20 * scale,
                  child: _EntryAnimated(
                    animation: state._nameIn,
                    rise: 0,
                    child: Row(
                      children: [
                        AnimatedBuilder(
                          animation: state._glowCtrl,
                          builder: (context, _) => Container(
                            width: 6 * scale,
                            height: 6 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: cyan,
                              boxShadow: [
                                BoxShadow(
                                  color: cyan.withValues(
                                      alpha: 0.5 + 0.5 * state._glowCtrl.value),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          'PROJECTING // 0xBDAY',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10 * scale,
                            color: cyan,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                            shadows: [Shadow(color: cyan, blurRadius: 6)],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Center: avatar inside pulsing rings
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.only(top: 60 * scale),
                    child: Center(
                      child: SizedBox(
                        width: 140 * scale,
                        height: 140 * scale,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer rings
                            AnimatedBuilder(
                              animation: state._glowCtrl,
                              child: Padding(
                                padding: EdgeInsets.all(4 * scale),
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
                              builder: (context, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 140 * scale,
                                      height: 140 * scale,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: cyan.withValues(alpha: 0.3),
                                            width: 1),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale:
                                          0.85 + 0.05 * state._glowCtrl.value,
                                      child: Container(
                                        width: 120 * scale,
                                        height: 120 * scale,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color:
                                                  cyan.withValues(alpha: 0.4),
                                              width: 1),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 100 * scale,
                                      height: 100 * scale,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: cyan.withValues(alpha: 0.6),
                                            width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: cyan.withValues(alpha: 0.4),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                      child: child,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Big name
                Positioned(
                  left: 24 * scale,
                  right: 24 * scale,
                  bottom: 70 * scale,
                  child: _EntryAnimated(
                    animation: state._nameIn,
                    child: Text(
                      name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: nameSize,
                        fontWeight: FontWeight.w200,
                        color: Colors.white,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(color: cyan, blurRadius: 14),
                          Shadow(
                              color: cyan.withValues(alpha: 0.6),
                              blurRadius: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                if (wish.isNotEmpty)
                  Positioned(
                    left: 24 * scale,
                    right: 24 * scale,
                    bottom: 38 * scale,
                    child: _EntryAnimated(
                      animation: state._wishIn,
                      child: Text(
                        '// ${wish.toLowerCase()}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceMono(
                          fontSize: 11 * scale,
                          color: cyan.withValues(alpha: 0.85),
                          letterSpacing: 1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                // Emitter base
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12 * scale,
                  child: Center(
                    child: Container(
                      width: 80 * scale,
                      height: 4 * scale,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cyan.withValues(alpha: 0),
                            cyan,
                            cyan.withValues(alpha: 0)
                          ],
                        ),
                        boxShadow: [BoxShadow(color: cyan, blurRadius: 8)],
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

class _HoloScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.08);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HoloScanlinePainter oldDelegate) => false;
}
