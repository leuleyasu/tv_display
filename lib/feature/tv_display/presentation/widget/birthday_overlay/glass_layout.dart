part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 5 — GLASS (Glassmorphism, frosted glass, floating orbs)
// ═══════════════════════════════════════════════════════════════

class _GlassLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _GlassLayout({
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
    final nameSize = min(box.maxWidth * 0.05, 64.0) * scale;

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
                constraints: BoxConstraints(maxWidth: box.maxWidth * 0.65),
                child: child,
              ),
            ),
          ),
        );
      },
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Colorful gradient base
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1E1B4B),
                      Color(0xFF312E81),
                      Color(0xFF581C87),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Image fills the background softly
              if (imageUrl != null && imageUrl!.isNotEmpty)
                _BirthdayImage(
                  state: state,
                  url: imageUrl,
                  scale: scale,
                  box: box,
                  accent: accent,
                ),
              // Floating gradient orbs
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: state._glowCtrl,
                  builder: (context, _) => Stack(
                    children: [
                      _GradientOrb(
                        color: accent,
                        size: 220 * scale,
                        x: 0.1 + 0.05 * state._glowCtrl.value,
                        y: 0.15,
                        scale: scale,
                      ),
                      _GradientOrb(
                        color: const Color(0xFFFF007A),
                        size: 180 * scale,
                        x: 0.7,
                        y: 0.6 - 0.05 * state._glowCtrl.value,
                        scale: scale,
                      ),
                      _GradientOrb(
                        color: const Color(0xFF06B6D4),
                        size: 160 * scale,
                        x: 0.4,
                        y: 0.85 + 0.04 * state._glowCtrl.value,
                        scale: scale,
                      ),
                    ],
                  ),
                ),
              ),
              // Dark scrim
              Positioned.fill(
                child: Container(color: Colors.black.withValues(alpha: 0.15)),
              ),
              // Glass card
              Center(
                child: Padding(
                  padding: EdgeInsets.all(28 * scale),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          28 * scale,
                          24 * scale,
                          28 * scale,
                          24 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Top glass pill
                            _EntryAnimated(
                              animation: state._nameIn,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14 * scale,
                                  vertical: 6 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '🎉  TODAY IS THE DAY  🎉',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 18 * scale),
                            _EntryAnimated(
                              animation: state._nameIn,
                              child: _ShimmerName(
                                state: state,
                                name: name,
                                accent: Colors.white,
                                fontSize: nameSize,
                                scale: scale,
                              ),
                            ),
                            if (wish.isNotEmpty) ...[
                              SizedBox(height: 14 * scale),
                              _WishLine(
                                state: state,
                                wish: wish,
                                fontSize: 16 * scale,
                                scale: scale,
                                maxLines: 3,
                              ),
                            ],
                            SizedBox(height: 18 * scale),
                            _EmojiRow(
                              state: state,
                              emojis: const ['🎂', '🎈', '🥂', '🎁', '✨'],
                              scale: scale,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientOrb extends StatelessWidget {
  final Color color;
  final double size;
  final double x; // 0..1
  final double y; // 0..1
  final double scale;
  const _GradientOrb({
    required this.color,
    required this.size,
    required this.x,
    required this.y,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: -size * 0.3 + x * 0,
      top: 0,
      child: FractionalTranslation(
        translation: Offset(x, y),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.7),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
