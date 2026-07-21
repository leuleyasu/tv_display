part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 13 — STORIES (Instagram story reel, polaroid frames)
// ═══════════════════════════════════════════════════════════════

class _StoriesLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final List<String>? storyImages;
  final bool isAsset;
  final String name;
  final String wish;
  final Color accent;

  const _StoriesLayout({
    required this.state,
    required this.scale,
    required this.box,
    required this.imageUrl,
    required this.storyImages,
    required this.isAsset,
    required this.name,
    required this.wish,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final imgs = <String>[];
    if (storyImages != null && storyImages!.isNotEmpty) {
      imgs.addAll(storyImages!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      imgs.add(imageUrl!);
    }

    final nameSize = min(box.maxWidth * 0.045, 64.0) * scale;
    final wishSize = 18 * scale;

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
                constraints: BoxConstraints(maxWidth: box.maxWidth * 0.75),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Story frames stage ──
          SizedBox(
            height: 360 * scale,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Left frame (small, tilted left)
                if (imgs.isNotEmpty)
                  _StoryFrame(
                    state: state,
                    url: imgs[0],
                    isAsset: isAsset,
                    accent: accent,
                    scale: scale,
                    size: 170 * scale,
                    rotation: -0.14,
                    offsetX: -150 * scale,
                    offsetY: 40 * scale,
                    entryDelay: 0.0,
                    label: 'memory 01',
                    badgeColor: const Color(0xFFFF007A),
                  ),

                // Hero / center frame (biggest, slight tilt)
                _StoryFrame(
                  state: state,
                  url: imgs.length > 1
                      ? imgs[1]
                      : (imgs.isNotEmpty ? imgs[0] : null),
                  isAsset: isAsset,
                  accent: accent,
                  scale: scale,
                  size: imgs.length > 1 ? 230 * scale : 280 * scale,
                  rotation: imgs.length > 1 ? 0.04 : 0.0,
                  offsetX: 0,
                  offsetY: imgs.length > 1 ? -10 * scale : 0,
                  entryDelay: 0.12,
                  label: 'today',
                  badgeColor: accent,
                  isHero: true,
                ),

                // Right frame (medium, tilted right)
                if (imgs.length > 2)
                  _StoryFrame(
                    state: state,
                    url: imgs[2],
                    isAsset: isAsset,
                    accent: accent,
                    scale: scale,
                    size: 195 * scale,
                    rotation: 0.10,
                    offsetX: 150 * scale,
                    offsetY: 25 * scale,
                    entryDelay: 0.24,
                    label: 'memory 02',
                    badgeColor: const Color(0xFF22D3EE),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Story progress dots ──
          _StoryProgressDots(
            count: imgs.isEmpty ? 1 : imgs.length.clamp(1, 3),
            activeIndex: 1,
            scale: scale,
            accent: accent,
          ),

          const SizedBox(height: 24),

          // ── Name ──
          _EntryAnimated(
            animation: state._nameIn,
            child: _ShimmerName(
              state: state,
              name: name,
              accent: accent,
              fontSize: nameSize,
              scale: scale,
            ),
          ),

          if (wish.isNotEmpty) ...[
            const SizedBox(height: 8),
            _WishLine(
              state: state,
              wish: wish,
              fontSize: wishSize,
              scale: scale,
              maxLines: 2,
            ),
          ],

          const SizedBox(height: 18),

          // ── Emoji row ──
          _EmojiRow(
            state: state,
            emojis: const ['📸', '✨', '🥂', '🎬', '💫'],
            scale: scale,
            size: 32 * scale,
          ),
        ],
      ),
    );
  }
}

/// One polaroid-style frame in the story reel.
class _StoryFrame extends StatelessWidget {
  final _BirthdayOverlayState state;
  final String? url;
  final bool isAsset;
  final Color accent;
  final double scale;
  final double size;
  final double rotation;
  final double offsetX;
  final double offsetY;
  final double entryDelay;
  final String label;
  final Color badgeColor;
  final bool isHero;

  const _StoryFrame({
    required this.state,
    required this.url,
    required this.isAsset,
    required this.accent,
    required this.scale,
    required this.size,
    required this.rotation,
    required this.offsetX,
    required this.offsetY,
    required this.entryDelay,
    required this.label,
    required this.badgeColor,
    this.isHero = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state._entranceCtrl,
      builder: (context, _) {
        final raw = (state._entranceCtrl.value - entryDelay) / (1 - entryDelay);
        final t = raw.clamp(0.0, 1.0);
        return Center(
          child: Transform.translate(
            offset: Offset(
              offsetX,
              offsetY + (1 - Curves.easeOutCubic.transform(t)) * 50,
            ),
            child: Transform.rotate(
              angle: rotation,
              child: Opacity(
                opacity: t,
                child: Transform.scale(
                  scale: 0.6 + 0.4 * Curves.easeOutBack.transform(t),
                  child: Container(
                    width: size,
                    height: size * 1.28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(isHero ? 24 : 18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                        if (isHero)
                          BoxShadow(
                            color: accent.withValues(alpha: 0.45),
                            blurRadius: 50,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    padding: EdgeInsets.all(isHero ? 10 * scale : 8 * scale),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(isHero ? 16 : 12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _image(),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.0),
                                      Colors.black.withValues(alpha: 0.35),
                                    ],
                                    stops: const [0.0, 0.55, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8 * scale,
                            left: 8 * scale,
                            child: _StoryBadge(
                              label: label,
                              color: badgeColor,
                              scale: scale,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _image() {
    if (url == null || url!.isEmpty) return _fallback();
    if (isAsset) {
      return Image.asset(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }
    return Image.network(
      url!,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, p) =>
          p == null ? child : _fallback(loading: true),
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback({bool loading = false}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.5),
            const Color(0xFF1a1a2e),
            const Color(0xFF0f3460),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: loading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: accent.withValues(alpha: 0.6),
                  strokeWidth: 2,
                ),
              )
            : Text('📸', style: TextStyle(fontSize: 40 * scale)),
      ),
    );
  }
}

/// Small label badge on each story frame.
class _StoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double scale;

  const _StoryBadge({
    required this.label,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.7),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: 6 * scale),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.spaceMono(
              fontSize: 9 * scale,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress dots (IG-style bars).
class _StoryProgressDots extends StatelessWidget {
  final int count;
  final int activeIndex;
  final double scale;
  final Color accent;

  const _StoryProgressDots({
    required this.count,
    required this.activeIndex,
    required this.scale,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: 4 * scale),
          width: isActive ? 32 * scale : 18 * scale,
          height: 3 * scale,
          decoration: BoxDecoration(
            color: isActive ? accent : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.6), blurRadius: 6)
                  ]
                : null,
          ),
        );
      }),
    );
  }
}
