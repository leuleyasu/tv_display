import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Which "card style" the dashboard wants to render.
/// `post`     — Instagram-feed style, portrait card
/// `polaroid` — white frame + slight rotation, like a printed photo
/// `split`    — landscape magazine spread, best for TV
/// `auto`     — picks a layout based on aspect / presence of image
enum BirthdayLayout { post, polaroid, split, auto }

class BirthdayOverlay extends StatefulWidget {
  final String? imageUrl;
  final String name;
  final String wish;
  final double scale;

  /// Force a specific layout. Defaults to [BirthdayLayout.auto].
  final BirthdayLayout layout;

  /// Accent color (default gold). Lets the dashboard tint per event.
  final Color accentColor;

  /// Optional age / years badge shown on the split layout.
  final String? badgeText;

  const BirthdayOverlay({
    super.key,
    this.imageUrl,
    required this.name,
    this.wish = '',
    required this.scale,
    this.layout = BirthdayLayout.auto,
    this.accentColor = const Color(0xFFFBBF24),
    this.badgeText,
  });

  @override
  State<BirthdayOverlay> createState() => _BirthdayOverlayState();
}

class _BirthdayOverlayState extends State<BirthdayOverlay>
    with TickerProviderStateMixin {
  // ── Animations ──────────────────────────────────────────────
  late AnimationController _confettiCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _entranceCtrl;

  late Animation<double> _entranceFade;
  late Animation<double> _entranceScale;
  late Animation<Offset> _entranceSlide;
  late Animation<double> _imageZoom;

  // Stagger entry for name → wish → emoji row
  late Animation<double> _nameIn;
  late Animation<double> _wishIn;
  late Animation<double> _emojisIn;

  // ── Data ────────────────────────────────────────────────────
  final List<_ConfettiPiece> _confetti = [];
  final Random _random = Random();

  /// Slight rotation used by the polaroid layout. Picked once on mount
  /// so it stays stable while the overlay is on screen.
  late double _polaroidRotation;

  static const _bgColor = Color(0xFF070712);
  static const _cardBg = Color(0xFF0E0E1A);
  static const _polaroidWhite = Color(0xFFF7F4EC);

  BirthdayLayout get _effectiveLayout {
    if (widget.layout != BirthdayLayout.auto) return widget.layout;
    // Auto: prefer split for landscape TV, post for portrait, polaroid
    // when there's no image. The dashboard can always force a choice.
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return BirthdayLayout.polaroid;
    }
    final size = MediaQuery.maybeOf(context)?.size ?? const Size(1920, 1080);
    return size.width > size.height * 1.4
        ? BirthdayLayout.split
        : BirthdayLayout.post;
  }

  @override
  void initState() {
    super.initState();

    _polaroidRotation = (_random.nextDouble() - 0.5) * 6; // ±3°

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..forward();

    _entranceFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _entranceScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.05, 0.85, curve: Curves.easeOutCubic),
      ),
    );
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _imageZoom = Tween<double>(begin: 1.12, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Staggered content entry — name, then wish, then emoji row.
    _nameIn = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOutBack),
    );
    _wishIn = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.50, 0.90, curve: Curves.easeOut),
    );
    _emojisIn = CurvedAnimation(
      parent: _entranceCtrl,
      curve: const Interval(0.70, 1.0, curve: Curves.easeOutCubic),
    );

    _generateConfetti();
  }

  void _generateConfetti() {
    for (int i = 0; i < 38; i++) {
      final isRibbon = _random.nextBool();
      _confetti.add(_ConfettiPiece(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.015 + _random.nextDouble() * 0.03,
        burstSeed: _random.nextDouble(),
        size: 4 + _random.nextDouble() * 8,
        shape: isRibbon ? _ConfettiShape.ribbon : _ConfettiShape.circle,
        color: [
          widget.accentColor,
          const Color(0xFFFF007A),
          Colors.cyanAccent,
          Colors.greenAccent,
          Colors.purpleAccent,
          Colors.white,
        ][_random.nextInt(6)]
            .withValues(alpha: 0.6 + _random.nextDouble() * 0.4),
        rotation: _random.nextDouble() * 6.28,
        rotationSpeed: 0.02 + _random.nextDouble() * 0.06,
      ));
    }
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _glowCtrl.dispose();
    _shimmerCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final scale = widget.scale;
          return Stack(
            children: [
              _buildBackdrop(box),
              _buildConfetti(),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: box.maxWidth * 0.04,
                    vertical: box.maxHeight * 0.05,
                  ),
                  child: _buildLayout(scale, box),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Backdrop (gradient or image at low opacity) ───────────
  Widget _buildBackdrop(BoxConstraints box) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.2),
            radius: 1.2,
            colors: [
              widget.accentColor.withValues(alpha: 0.18),
              const Color(0xFF120A1F),
              _bgColor,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  // ── Layout dispatch ────────────────────────────────────────
  Widget _buildLayout(double scale, BoxConstraints box) {
    switch (_effectiveLayout) {
      case BirthdayLayout.post:
        return _PostLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.polaroid:
        return _PolaroidLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
          rotation: _polaroidRotation,
        );
      case BirthdayLayout.split:
        return _SplitLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
          badgeText: widget.badgeText,
        );
      case BirthdayLayout.auto:
        // Handled by _effectiveLayout
        return const SizedBox.shrink();
    }
  }

  // ── Confetti layer (unchanged) ─────────────────────────────
  Widget _buildConfetti() {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _confettiCtrl,
        builder: (context, child) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(
              confetti: _confetti,
              progress: _confettiCtrl.value,
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Shared bits used by all three layouts
// ═══════════════════════════════════════════════════════════════

/// Wraps a child in the same entrance + card frame so all three
/// layouts share one feel.
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
      child: Image.network(
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

/// Big gold-shimmer name (used by all three layouts). Animates in
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
          // ── Image (top, 4:3) ──────────────────────────────
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
                // Subtle bottom gradient so any overlaid text stays
                // readable if you ever want to add a caption on the
                // image later.
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

          // ── Body (IG-style) ───────────────────────────────
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
                // Header row: avatar dot + handle + timestamp
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
                    // Live dot
                    _LiveDot(scale: scale, color: accent),
                  ],
                ),

                SizedBox(height: 16 * scale),

                // Big name
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

                // Divider (IG "caption" line)
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

                // Action row (decorative — heart/comment/share)
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

// ═══════════════════════════════════════════════════════════════
// LAYOUT 2 — POLAROID (white frame, slight rotation, sticker-y)
// ═══════════════════════════════════════════════════════════════

class _PolaroidLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;
  final double rotation;

  const _PolaroidLayout({
    required this.state,
    required this.scale,
    required this.box,
    required this.imageUrl,
    required this.name,
    required this.wish,
    required this.accent,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    final nameSize = min(box.maxWidth * 0.05, 72.0) * scale;
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
                constraints: BoxConstraints(
                  maxWidth: box.maxWidth * 0.55,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Polaroid frame ────────────────────────────────
          Transform.rotate(
            angle: rotation * pi / 180,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                18 * scale,
                18 * scale,
                18 * scale,
                80 * scale,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F4EC),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 35,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: _BirthdayImage(
                      state: state,
                      url: imageUrl,
                      scale: scale,
                      box: box,
                      accent: accent,
                    ),
                  ),
                  SizedBox(height: 18 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                    child: _EntryAnimated(
                      animation: state._nameIn,
                      child: Text(
                        name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.caveat(
                          fontSize: nameSize * 1.1,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2A2A2A),
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 28 * scale),

          // ── Floating stickers around the polaroid ──────────
          _EntryAnimated(
            animation: state._emojisIn,
            rise: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Sticker(emoji: '🎉', scale: scale, tilt: -8),
                SizedBox(width: 12 * scale),
                _Sticker(emoji: '🎈', scale: scale, tilt: 6),
                SizedBox(width: 12 * scale),
                _Sticker(emoji: '🎂', scale: scale, tilt: -4),
                SizedBox(width: 12 * scale),
                _Sticker(emoji: '🎁', scale: scale, tilt: 9),
                SizedBox(width: 12 * scale),
                _Sticker(emoji: '🥳', scale: scale, tilt: -6),
              ],
            ),
          ),

          if (wish.isNotEmpty) ...[
            SizedBox(height: 18 * scale),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 540 * scale),
              child: _WishLine(
                state: state,
                wish: '"$wish"',
                fontSize: wishSize,
                scale: scale,
                maxLines: 3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Sticker extends StatefulWidget {
  final String emoji;
  final double scale;
  final double tilt; // degrees
  const _Sticker(
      {required this.emoji, required this.scale, required this.tilt});

  @override
  State<_Sticker> createState() => _StickerState();
}

class _StickerState extends State<_Sticker>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
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
      builder: (context, _) {
        // Gentle float + counter-rotation so each sticker feels alive
        return Transform.translate(
          offset: Offset(0, -4 * _c.value),
          child: Transform.rotate(
            angle: (widget.tilt + (_c.value - 0.5) * 4) * pi / 180,
            child: Container(
              padding: EdgeInsets.all(8 * widget.scale),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Text(
                widget.emoji,
                style: TextStyle(fontSize: 36 * widget.scale),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
            // ── Image (left, ~45%) ──────────────────────────
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
                  // Accent strip on the right edge of the image
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

            // ── Content (right, ~55%) ───────────────────────
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
                    // Top eyebrow row
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

                    // Big name
                    _ShimmerName(
                      state: state,
                      name: name,
                      accent: accent,
                      fontSize: nameSize,
                      scale: scale,
                      align: TextAlign.left,
                    ),

                    SizedBox(height: 14 * scale),

                    // Divider with badge
                    Row(
                      children: [
                        Container(
                          width: 60 * scale,
                          height: 2,
                          decoration: BoxDecoration(
                            color: accent,
                          ),
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

                    // Emoji row
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
} // ═══════════════════════════════════════════════════════════════
// Confetti + animation helpers (unchanged from your original, just
// moved to the bottom so the layouts read top-down)
// ═══════════════════════════════════════════════════════════════

enum _ConfettiShape { ribbon, circle }

class _ConfettiPiece {
  final double x;
  final double y;
  final double speed;
  final double burstSeed;
  final double size;
  final Color color;
  final double rotation;
  final double rotationSpeed;
  final _ConfettiShape shape;

  const _ConfettiPiece({
    required this.x,
    required this.y,
    required this.speed,
    required this.burstSeed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> confetti;
  final double progress;

  _ConfettiPainter({required this.confetti, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      final burstBoost =
          (1 - progress).clamp(0.0, 1.0) * piece.burstSeed * 0.08;
      final y = (piece.y + progress * (piece.speed + burstBoost)) % 1.0;
      final x = piece.x + sin(progress * 4 + piece.rotation) * 0.02;

      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(piece.rotation + progress * piece.rotationSpeed);

      final paint = Paint()..color = piece.color;

      if (piece.shape == _ConfettiShape.circle) {
        canvas.drawCircle(Offset.zero, piece.size * 0.45, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: piece.size * 0.5,
              height: piece.size * 1.6,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
