part of 'birthday_overlay.dart';

/// Wraps a child in the same entrance + card frame so all layouts
/// share one feel.
class _BirthdayCardShell extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final Widget child;
  final double maxWidthFactor; // 0..1 of screen width
  final double radius;

  const _BirthdayCardShell({
    required this.state,
    required this.scale,
    required this.box,
    required this.child,
    this.maxWidthFactor = 0.7,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final maxW = box.maxWidth * maxWidthFactor;
    return AnimatedBuilder(
      animation: state._entranceCtrl,
      builder: (context, c) {
        return Opacity(
          opacity: state._entranceFade.value,
          child: SlideTransition(
            position: state._entranceSlide,
            child: ScaleTransition(
              scale: state._entranceScale,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: c,
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E1A),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child,
        ),
      ),
    );
  }
}

/// Network image with a subtle zoom-in driven by the entrance ctrl.
/// Falls back to a beautiful gradient + emoji if the image is missing
/// or fails to load.
class _BirthdayImage extends StatelessWidget {
  final _BirthdayOverlayState state;
  final String? url;
  final double scale;
  final BoxConstraints box;
  final Color accent;
  final BoxFit fit;

  const _BirthdayImage({
    required this.state,
    required this.url,
    required this.scale,
    required this.box,
    required this.accent,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return _imageFallback();
    }
    return AnimatedBuilder(
      animation: state._entranceCtrl,
      builder: (context, child) {
        return Transform.scale(
          scale: state._imageZoom.value,
          child: child,
        );
      },
      child: state.isAsset
          ? Image.asset(
              url!,
              fit: fit,
              errorBuilder: (context, err, st) => _imageFallback(),
            )
          : Image.network(
              url!,
              fit: fit,
              loadingBuilder: (context, child, p) =>
                  p == null ? child : _imageFallback(loading: true),
              errorBuilder: (context, err, st) => _imageFallback(),
            ),
    );
  }

  Widget _imageFallback({bool loading = false}) {
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
            ? CircularProgressIndicator(color: accent.withValues(alpha: 0.5))
            : Text('🎂', style: TextStyle(fontSize: 80 * scale)),
      ),
    );
  }
}

/// Big gold-shimmer name (used by all layouts). Animates in
/// via the staggered _nameIn curve and shimmers continuously.
class _ShimmerName extends StatelessWidget {
  final _BirthdayOverlayState state;
  final String name;
  final Color accent;
  final double fontSize;
  final double scale;
  final TextAlign align;

  const _ShimmerName({
    required this.state,
    required this.name,
    required this.accent,
    required this.fontSize,
    required this.scale,
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([state._shimmerCtrl, state._glowCtrl]),
      builder: (context, _) {
        final glow = state._glowCtrl.value;
        final sweep = state._shimmerCtrl.value;
        final dx = -2.5 + sweep * 5.0;
        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              accent,
              accent,
              Colors.white,
              accent,
              accent,
            ],
            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
            begin: Alignment(dx - 0.6, 0),
            end: Alignment(dx + 0.6, 0),
          ).createShader(bounds),
          child: Text(
            name.toUpperCase(),
            textAlign: align,
            style: GoogleFonts.spaceGrotesk(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.05,
              letterSpacing: 6,
              shadows: [
                Shadow(
                  color: accent.withValues(alpha: 0.5 * glow),
                  blurRadius: 30 * scale * glow,
                ),
                Shadow(
                  color: accent.withValues(alpha: 0.25 * glow),
                  blurRadius: 60 * scale * glow,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The wish line, fades in slightly after the name.
class _WishLine extends StatelessWidget {
  final _BirthdayOverlayState state;
  final String wish;
  final double fontSize;
  final double scale;
  final int maxLines;

  const _WishLine({
    required this.state,
    required this.wish,
    required this.fontSize,
    required this.scale,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (wish.isEmpty) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: state._entranceCtrl,
      builder: (context, _) {
        return Opacity(
          opacity: state._wishIn.value,
          child: Transform.translate(
            offset: Offset(0, (1 - state._wishIn.value) * 8),
            child: Text(
              wish,
              textAlign: TextAlign.center,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.spaceGrotesk(
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: Colors.white.withValues(alpha: 0.75),
                height: 1.4,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Staggered emoji row that pops in at the end of the entrance.
class _EmojiRow extends StatelessWidget {
  final _BirthdayOverlayState state;
  final List<String> emojis;
  final double scale;
  final double size;

  const _EmojiRow({
    required this.state,
    required this.emojis,
    required this.scale,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state._entranceCtrl,
      builder: (context, _) {
        final t = state._emojisIn.value;
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 10 * scale,
          children: List.generate(emojis.length, (i) {
            // Each emoji gets a tiny extra delay
            final local = ((t - i * 0.08) / 0.6).clamp(0.0, 1.0);
            return Transform.scale(
              scale: 0.4 + 0.6 * Curves.easeOutBack.transform(local),
              child: Opacity(
                opacity: local,
                child: Text(
                  emojis[i],
                  style: TextStyle(fontSize: size * scale),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Wraps a child with a single entrance animation (used to keep the
/// per-element entry staggered without each child writing its own
/// AnimatedBuilder).
class _EntryAnimated extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double rise;
  const _EntryAnimated({
    required this.animation,
    required this.child,
    this.rise = 12,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, c) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - animation.value) * rise),
            child: Transform.scale(
              scale: 0.92 +
                  0.08 *
                      Curves.easeOutCubic.transform(
                        animation.value.clamp(0.0, 1.0),
                      ),
              child: c,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
