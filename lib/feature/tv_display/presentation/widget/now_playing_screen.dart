import 'dart:math' as math;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:night_track_tv/feature/tv_display/presentation/screen/tv_display_screen.dart';

import '../../../../core/models/music_request.dart';

import 'pulse_dot.dart';

import 'tech_grid_painter.dart';

/// Full-screen "Now Playing" overlay shown as a phase in the TV display
/// cycle whenever a song is currently playing in the venue.
///
/// The music chrome (spinning album, badge, track name, artist, equalizer)
/// is preserved exactly as in the original layout. The **engagement** layer
/// (dedication + requester) is promoted to the main character via:
///  - dedication: huge italic type, decorative quote marks, sweep gradient,
///    overshoot entry, radial halo
///  - requester: big bold name in a glowing accent pill with a pulsing heart
class NowPlayingScreen extends StatefulWidget {
  final MusicRequest request;
  final double scale;

  /// Accent color. Defaults to the same `_pinkAccent` used in
  /// TvDisplayScreen so the music phase feels part of the same brand.
  /// Pass `Color(0xFF22D3EE)` for a cyan "music" vibe.
  final Color accent;

  const NowPlayingScreen({
    super.key,
    required this.request,
    required this.scale,
    this.accent = const Color(0xFFFF007A),
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen>
    with TickerProviderStateMixin {
  // ── Animations ─────────────────────────────────────────────
  late final AnimationController _spinCtrl; // album rotation
  late final AnimationController _pulseCtrl; // album glow
  late final AnimationController _orbCtrl; // bg orbs
  late final Animation<double> _orbAnim;
  late final AnimationController _radarCtrl; // album radar pulse
  late final Animation<double> _radarAnim;
  late final AnimationController _breathCtrl; // album breath
  late final Animation<double> _breathAnim;
  late final AnimationController _entryCtrl; // card entry
  late final Animation<double> _entryAnim;
  late final Animation<double> _frameAnim; // brackets draw-in
  late final Animation<double> _nameAnim; // name punch-in
  late final Animation<double> _metaAnim; // meta slide-up
  late final AnimationController _progressCtrl; // 8s countdown
  late final Animation<double> _progressAnim;
  // NEW (engagement only): pulsing heart on requester badge
  late final AnimationController _heartCtrl;
  late final Animation<double> _heartAnim;
  late final AnimationController _gridSweepCtrl;
  late final Animation<double> _gridSweepAnim;

  // ── Color tokens (mirror TvDisplayScreen) ──────────────────
  static const _bgColor = Color(0xFF070712);
  static const _pinkOrb = Color(0xFFB8005C);
  static const _pinkOrb2 = Color(0xFF660033);

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _orbAnim = CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut);
    _radarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _radarAnim = CurvedAnimation(parent: _radarCtrl, curve: Curves.linear);
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _breathAnim = CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _entryAnim =
        CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic);
    _frameAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    _nameAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutBack),
    );
    _metaAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );

    _progressCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.request.durationSeconds),
    );
    _progressAnim =
        CurvedAnimation(parent: _progressCtrl, curve: Curves.linear);

    // NEW: heart pulse for the requester badge
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _heartAnim = CurvedAnimation(parent: _heartCtrl, curve: Curves.easeInOut);

    _gridSweepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _gridSweepAnim = CurvedAnimation(
      parent: _gridSweepCtrl,
      curve: Curves.linear,
    );

    _entryCtrl.forward();
    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _pulseCtrl.dispose();
    _orbCtrl.dispose();
    _radarCtrl.dispose();
    _breathCtrl.dispose();
    _entryCtrl.dispose();
    _progressCtrl.dispose();
    _heartCtrl.dispose();
    _gridSweepCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasDedication = widget.request.dedication != null &&
        widget.request.dedication!.trim().isNotEmpty;
    final hasRequester = widget.request.userName != null &&
        widget.request.userName!.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: _bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          return Stack(
            children: [
              // ── Background layers ──
              _buildOrbs(box),
              _buildGrid(),
              _buildParticles(),
              // ── UI chrome ──
              _buildProgressStrip(),
              _buildTopBar(),
              // ── Main framed card ──
              Center(
                child: _buildFramedContent(box),
              ),
              // ── Standalone heroes ──
              if (hasDedication) _buildHeroDedicationStandalone(box),
              if (hasRequester) _buildHeroRequesterStandalone(box),
              // ── Footer ──
              Positioned(
                bottom: 22 * widget.scale,
                left: 0,
                right: 0,
                child: Center(child: _buildFooter()),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Background orbs ────────────────────────────────────────
  Widget _buildOrbs(BoxConstraints box) {
    return AnimatedBuilder(
      animation: _orbAnim,
      builder: (_, __) {
        final double t = _orbAnim.value;
        return Stack(
          children: [
            Positioned(
              top: ui.lerpDouble(-120, -20, t)!,
              left: ui.lerpDouble(-100, 20, t)!,
              child: _orb(_pinkOrb, 0.25, 600, 700, 100),
            ),
            Positioned(
              bottom: ui.lerpDouble(-150, -40, t)!,
              right: ui.lerpDouble(-80, 40, t)!,
              child: _orb(_pinkOrb2, 0.35, 500, 600, 80),
            ),
            Positioned(
              top: ui.lerpDouble(
                  box.maxHeight * 0.15, box.maxHeight * 0.35, 1 - t)!,
              right:
                  ui.lerpDouble(box.maxWidth * 0.05, box.maxWidth * 0.25, t)!,
              child: _orb(widget.accent, 0.08, 300, 300, 120),
            ),
          ],
        );
      },
    );
  }

  Widget _orb(Color color, double opacity, double w, double h, double blur) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildGrid() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: TechGridPainter(
              color: widget.accent.withValues(alpha: 0.35),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _gridSweepAnim,
              builder: (_, __) => CustomPaint(
                painter: _GridSweepPainter(
                  progress: _gridSweepAnim.value,
                  color: widget.accent,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: Listenable.merge([_gridSweepAnim, _orbAnim]),
              builder: (_, __) => CustomPaint(
                painter: _GridDotsPainter(
                  sweep: _gridSweepAnim.value,
                  pulse: _orbAnim.value,
                  color: widget.accent,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParticles() {
    return Positioned.fill(
      child: IgnorePointer(
        child: FloatingParticles(
          seed: widget.request.trackName.hashCode,
          accent: widget.accent,
        ),
      ),
    );
  }

  // ── 8s countdown progress strip ────────────────────────────
  Widget _buildProgressStrip() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 4,
        child: AnimatedBuilder(
          animation: _progressAnim,
          builder: (_, __) => LinearProgressIndicator(
            value: 1 - _progressAnim.value,
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(widget.accent),
            minHeight: 4,
          ),
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────
  Widget _buildTopBar() {
    final baseStyle = GoogleFonts.spaceGrotesk(
      fontSize: 18 * widget.scale,
      fontWeight: FontWeight.w900,
      letterSpacing: 6.0,
    );
    return Positioned(
      top: 30 * widget.scale,
      left: 40 * widget.scale,
      right: 40 * widget.scale,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              PulseDot(color: widget.accent, size: 8 * widget.scale),
              SizedBox(width: 12 * widget.scale),
              Text(
                'NOW_PLAYING // SYS',
                style: baseStyle.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: widget.accent.withValues(alpha: 0.7),
                      blurRadius: 20 * widget.scale,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'AUTO-DISMISS',
                style: GoogleFonts.spaceMono(
                  fontSize: 11 * widget.scale,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
              SizedBox(width: 10 * widget.scale),
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (_, __) {
                  final secs = widget.request.durationSeconds;
                  final s = ((secs * (1 - _progressAnim.value)).ceil())
                      .clamp(0, secs);
                  return Text(
                    '${s}s',
                    style: GoogleFonts.spaceMono(
                      fontSize: 14 * widget.scale,
                      fontWeight: FontWeight.w800,
                      color: widget.accent,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Framed content (original horizontal layout preserved) ─
  Widget _buildFramedContent(BoxConstraints box) {
    final cardMaxWidth = box.maxWidth * 0.84;
    final card = AnimatedBuilder(
      animation: _entryCtrl,
      builder: (context, child) {
        final double t = _entryAnim.value;
        final double slideX = (1 - t) * 40;
        final double scaleIn = 0.94 + 0.06 * t;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(slideX, 0),
            child: Transform.scale(
              scale: scaleIn,
              child: child,
            ),
          ),
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cardMaxWidth),
        child: _MessageFrame(
          accent: widget.accent,
          drawProgress: _frameAnim.value,
          borderRadius: 18,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 48 * widget.scale,
              vertical: 42 * widget.scale,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAlbumArt(box),
                SizedBox(width: 60 * widget.scale),
                Flexible(
                  child: _buildTrackInfo(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: box.maxHeight * 0.10,
        bottom: box.maxHeight * 0.07,
      ),
      child: card,
    );
  }

  // ── Album art (spinning vinyl with glow) — UNCHANGED ───────
  Widget _buildAlbumArt(BoxConstraints box) {
    final imageUrl = widget.request.imageUrl;
    final size =
        math.min(box.maxWidth * 0.18, box.maxHeight * 0.5).clamp(180.0, 380.0);

    return AnimatedBuilder(
      animation: Listenable.merge([_spinCtrl, _pulseCtrl, _breathAnim]),
      builder: (context, child) {
        final glow = _pulseCtrl.value * 0.5 + 0.5;
        final breath = 1.0 + (_breathAnim.value - 0.5) * 0.04;
        return Transform.scale(
          scale: breath,
          child: SizedBox(
            width: size + 30,
            height: size + 30,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Radar pulse rings
                ...List.generate(2, (i) {
                  final double t = (_radarAnim.value + i / 2) % 1.0;
                  return Container(
                    width: size + 30 + t * 60,
                    height: size + 30 + t * 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.accent.withValues(alpha: (1 - t) * 0.35),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
                // Outer glow ring
                Container(
                  width: size + 18,
                  height: size + 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.accent.withValues(alpha: 0.3 + glow * 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.4 * glow),
                        blurRadius: 50,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
                // Spinning disc
                Transform.rotate(
                  angle: _spinCtrl.value * 2 * math.pi,
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: child,
                  ),
                ),
                // Vinyl center label
                Container(
                  width: size * 0.22,
                  height: size * 0.22,
                  decoration: BoxDecoration(
                    color: widget.accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: size * 0.06,
                      height: size * 0.06,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _AlbumFallback(size: size),
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : _AlbumFallback(size: size),
              )
            : _AlbumFallback(size: size),
      ),
    );
  }

  // ── Track info (right column) — UNCHANGED structure, only
  //    the dedication + requester children are upgraded to hero
  //    treatments below.
  Widget _buildTrackInfo() {
    final nameSize = (42 * widget.scale).clamp(28.0, 64.0);
    final artistSize = (20 * widget.scale).clamp(15.0, 28.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBadge(),
        SizedBox(height: 18 * widget.scale),
        _buildAnimatedTrackName(
          widget.request.trackName,
          fontSize: nameSize,
        ),
        SizedBox(height: 10 * widget.scale),
        _buildArtistLine(artistSize),
        SizedBox(height: 18 * widget.scale),
        _buildEqualizerRow(),
      ],
    );
  }

  Widget _buildBadge() {
    return AnimatedBuilder(
      animation: _nameAnim,
      builder: (context, child) {
        final t = _nameAnim.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.scale(scale: 0.6 + 0.4 * t, child: child),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16 * widget.scale,
          vertical: 7 * widget.scale,
        ),
        decoration: BoxDecoration(
          color: widget.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: widget.accent.withValues(alpha: 0.45),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PulseDot(color: widget.accent, size: 6 * widget.scale),
            SizedBox(width: 10 * widget.scale),
            Icon(
              Icons.graphic_eq_rounded,
              size: 12 * widget.scale,
              color: widget.accent,
            ),
            SizedBox(width: 6 * widget.scale),
            Text(
              'SYS_AUDIO: NOW_PLAYING',
              style: GoogleFonts.spaceMono(
                fontSize: 11 * widget.scale,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: widget.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedTrackName(String name, {required double fontSize}) {
    return AnimatedBuilder(
      animation: Listenable.merge([_nameAnim, _orbAnim]),
      builder: (context, _) {
        final t = _nameAnim.value;
        final double punch = t == 0 ? 0.6 : (t > 1 ? 1.0 : t);
        final double overshoot =
            punch < 1 ? 0.6 + 0.4 * Curves.easeOutBack.transform(punch) : 1.0;
        final double sweep = (_orbAnim.value * 2 - 1);
        return Opacity(
          opacity: punch.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: overshoot,
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment(-1.0 + sweep * 2, 0),
                  end: Alignment(1.0 + sweep * 2, 0),
                  colors: [
                    widget.accent,
                    Colors.white,
                    widget.accent,
                    Colors.white,
                    widget.accent,
                  ],
                  stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcIn,
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: _baseFont(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(
                      color: widget.accent.withValues(alpha: 0.55),
                      blurRadius: 32 * widget.scale,
                    ),
                    Shadow(
                      color: widget.accent.withValues(alpha: 0.3),
                      blurRadius: 64 * widget.scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtistLine(double fontSize) {
    return AnimatedBuilder(
      animation: _metaAnim,
      builder: (context, child) {
        return Opacity(
          opacity: _metaAnim.value,
          child: Transform.translate(
            offset: Offset(0, (1 - _metaAnim.value) * 12),
            child: child,
          ),
        );
      },
      child: Row(
        children: [
          Text(
            'BY',
            style: GoogleFonts.spaceMono(
              fontSize: fontSize * 0.7,
              letterSpacing: 3,
              fontWeight: FontWeight.w800,
              color: widget.accent.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(width: 8 * widget.scale),
          Flexible(
            child: Text(
              widget.request.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _baseFont(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEqualizerRow() {
    return AnimatedBuilder(
      animation: _metaAnim,
      builder: (_, child) => Opacity(
        opacity: _metaAnim.value,
        child: child,
      ),
      child: _EqualizerBars(
        scale: widget.scale,
        color: widget.accent,
        barCount: 6,
        height: 24 * widget.scale,
        width: 3 * widget.scale,
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // ENGAGEMENT HEROES — only these two methods were upgraded.
  // Everything above (album, badge, track name, artist, equalizer)
  // is identical to the original.
  // ═════════════════════════════════════════════════════════════

  /// Standalone dedication — floats to the right of the framed card,
  /// big italic quote with oversized decorative quotation marks.
  /// No container — just pure typography with glow.
  Widget _buildHeroDedicationStandalone(BoxConstraints box) {
    final dedSize = (44 * widget.scale).clamp(30.0, 64.0);
    final quoteSize = 140 * widget.scale;
    return Positioned(
      bottom: box.maxHeight * 0.18,
      right: box.maxWidth * 0.03,
      child: AnimatedBuilder(
        animation: Listenable.merge([_nameAnim, _orbAnim, _pulseCtrl]),
        builder: (context, _) {
          final t = _nameAnim.value.clamp(0.0, 1.0);
          final overshoot = 0.5 + 0.5 * Curves.easeOutBack.transform(t);
          final sweep = (_orbAnim.value * 2 - 1);
          final halo = _pulseCtrl.value * 0.5 + 0.5;

          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset((1 - t) * 60, 0),
              child: Transform.scale(
                scale: overshoot,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Opening quote
                    Positioned(
                      top: -quoteSize * 0.35,
                      left: -quoteSize * 0.1,
                      child: Text(
                        '“',
                        style: TextStyle(
                          fontSize: quoteSize,
                          height: 1,
                          color: widget.accent.withValues(alpha: 0.2 * halo),
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    // Closing quote
                    Positioned(
                      bottom: -quoteSize * 0.45,
                      right: -quoteSize * 0.05,
                      child: Text(
                        '”',
                        style: TextStyle(
                          fontSize: quoteSize,
                          height: 1,
                          color: widget.accent.withValues(alpha: 0.2 * halo),
                          fontFamily: 'serif',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    // Dedication text
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment(-1.0 + sweep * 2, 0),
                        end: Alignment(1.0 + sweep * 2, 0),
                        colors: const [
                          Colors.white,
                          Colors.white,
                          Color(0xFFFFD6E8),
                          Colors.white,
                          Colors.white,
                        ],
                        stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        widget.request.dedication!.trim(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: dedSize,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                          letterSpacing: 0.3,
                          shadows: [
                            Shadow(
                              color: widget.accent.withValues(alpha: 0.55),
                              blurRadius: 36 * widget.scale,
                            ),
                            Shadow(
                              color: widget.accent.withValues(alpha: 0.3),
                              blurRadius: 72 * widget.scale,
                            ),
                          ],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Standalone requester — floats near the left edge of the screen,
  /// no container, just bold kicker + massive name with a pulsing
  /// heart accent floating next to it.
  Widget _buildHeroRequesterStandalone(BoxConstraints box) {
    final nameSize = (46 * widget.scale).clamp(32.0, 64.0);
    return Positioned(
      bottom: box.maxHeight * 0.08,
      left: box.maxWidth * 0.06,
      child: AnimatedBuilder(
        animation: Listenable.merge([_metaAnim, _heartAnim, _pulseCtrl]),
        builder: (context, _) {
          final t = _metaAnim.value.clamp(0.0, 1.0);
          final heartScale = 1.0 + _heartAnim.value * 0.2;
          final halo = _pulseCtrl.value * 0.5 + 0.5;

          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 30),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing heart — floating freely, no wrap
                  Transform.scale(
                    scale: heartScale,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: widget.accent.withValues(alpha: 0.6 + halo * 0.4),
                      size: 28 * widget.scale,
                      shadows: [
                        Shadow(
                          color: widget.accent.withValues(alpha: 0.7),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 18 * widget.scale),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REQUESTED BY',
                        style: GoogleFonts.spaceMono(
                          fontSize: 12 * widget.scale,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w800,
                          color: widget.accent.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 4 * widget.scale),
                      Text(
                        widget.request.userName!.trim(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: nameSize,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: widget.accent.withValues(alpha: 0.55),
                              blurRadius: 24,
                            ),
                            Shadow(
                              color: widget.accent.withValues(alpha: 0.3),
                              blurRadius: 48,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Footer (live indicator) — UNCHANGED ────────────────────
  Widget _buildFooter() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _EqualizerBars(
          scale: widget.scale * 0.85,
          color: widget.accent,
          barCount: 5,
          height: 14 * widget.scale,
          width: 2.5 * widget.scale,
        ),
        SizedBox(width: 12 * widget.scale),
        PulseDot(color: widget.accent, size: 7 * widget.scale),
        SizedBox(width: 8 * widget.scale),
        Text(
          'LIVE FROM THE BOOTH',
          style: GoogleFonts.spaceMono(
            fontSize: 12 * widget.scale,
            letterSpacing: 4,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  TextStyle _baseFont({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 0,
    Color color = Colors.white,
    double height = 1.0,
    List<Shadow> shadows = const [],
  }) {
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
      height: height,
      shadows: shadows,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Album art fallback
// ═══════════════════════════════════════════════════════════════

class _AlbumFallback extends StatelessWidget {
  final double size;
  const _AlbumFallback({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF007A).withValues(alpha: 0.35),
            Colors.black.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: Colors.white54,
          size: size * 0.4,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Message frame (corner brackets) — same pattern as the main
// TvDisplayScreen, slimmed for the music overlay.
// ═══════════════════════════════════════════════════════════════

class _MessageFrame extends StatelessWidget {
  final Widget child;
  final Color accent;
  final double drawProgress;
  final double borderRadius;
  const _MessageFrame({
    required this.child,
    required this.accent,
    required this.drawProgress,
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E1A).withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.25),
                blurRadius: 40,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.6),
                        radius: 1.1,
                        colors: [
                          accent.withValues(alpha: 0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _CornerBracketsPainter(
                      progress: drawProgress,
                      color: accent,
                      radius: borderRadius,
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CornerBracketsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double radius;
  _CornerBracketsPainter({
    required this.progress,
    required this.color,
    required this.radius,
  });

  static const double _armLong = 90;
  static const double _armShort = 36;
  static const double _thickness = 3;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    const cornerCount = 4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = _thickness
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = _thickness + 4
      ..strokeCap = StrokeCap.square
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..style = PaintingStyle.stroke;

    void drawArm(Offset from, Offset to, double p) {
      if (p <= 0) return;
      final end = Offset.lerp(from, to, p.clamp(0.0, 1.0))!;
      canvas.drawLine(from, end, glowPaint);
      canvas.drawLine(from, end, paint);
    }

    final r = radius;
    final corners = <_CornerOrigin>[
      _CornerOrigin(Offset(r, 0), const Offset(1, 0), const Offset(0, 1)),
      _CornerOrigin(
          Offset(size.width - r, 0), const Offset(-1, 0), const Offset(0, 1)),
      _CornerOrigin(
          Offset(r, size.height), const Offset(1, 0), const Offset(0, -1)),
      _CornerOrigin(Offset(size.width - r, size.height), const Offset(-1, 0),
          const Offset(0, -1)),
    ];

    for (int i = 0; i < cornerCount; i++) {
      final c = corners[i];
      final local = ((progress - i * 0.08) / 0.68).clamp(0.0, 1.0);
      if (local <= 0) continue;
      final longP = (local / 0.65).clamp(0.0, 1.0);
      final shortP = ((local - 0.65) / 0.35).clamp(0.0, 1.0);
      final longEnd = c.origin + c.longDir * _armLong;
      final shortEnd = c.origin + c.shortDir * _armShort;
      drawArm(c.origin, longEnd, longP);
      drawArm(c.origin, shortEnd, shortP);
      if (local >= 1.0) {
        final dotPaint = Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
        canvas.drawCircle(c.origin, 4, dotPaint);
        canvas.drawCircle(c.origin, 2.5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CornerBracketsPainter old) =>
      old.progress != progress || old.color != color;
}

class _CornerOrigin {
  final Offset origin;
  final Offset longDir;
  final Offset shortDir;
  const _CornerOrigin(this.origin, this.longDir, this.shortDir);
}

// ═══════════════════════════════════════════════════════════════
// Equalizer bars (self-contained, music-reactive)
// ═══════════════════════════════════════════════════════════════

class _EqualizerBars extends StatefulWidget {
  final double scale;
  final Color color;
  final int barCount;
  final double height;
  final double width;
  const _EqualizerBars({
    required this.scale,
    required this.color,
    this.barCount = 5,
    this.height = 18,
    this.width = 3,
  });

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<double> _phases;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat();
    _phases =
        List.generate(widget.barCount, (_) => _random.nextDouble() * 6.28);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (i) {
          final norm =
              (0.3 + (math.sin(_ctrl.value * 6.28 + _phases[i]) + 1) * 0.35)
                  .clamp(0.3, 1.0);
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 1.5 * widget.scale),
            width: widget.width,
            height: widget.height * norm,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(1),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// Floating particles (subtle, music-themed)
// ═══════════════════════════════════════════════════════════════

class _FloatingParticles extends StatefulWidget {
  final int seed;
  final Color accent;
  const _FloatingParticles({required this.seed, required this.accent});
  @override
  State<_FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<_FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;
  late math.Random _random;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 24))
          ..repeat();
    _respawn();
  }

  void _respawn() {
    _random = math.Random(widget.seed);
    final palette = <Color>[
      widget.accent,
      const Color(0xFFFF5C9E),
      const Color(0xFFFBBF24),
      const Color(0xFF22D3EE),
      Colors.white,
    ];
    _particles = List.generate(20, (_) {
      return _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.03 + _random.nextDouble() * 0.05,
        size: 1.2 + _random.nextDouble() * 3.0,
        sway: 0.01 + _random.nextDouble() * 0.02,
        phase: _random.nextDouble() * 6.28,
        opacity: 0.25 + _random.nextDouble() * 0.4,
        color: palette[_random.nextInt(palette.length)],
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ParticlePainter(
              particles: _particles,
              progress: _ctrl.value,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final double sway;
  final double phase;
  final double opacity;
  final Color color;
  const _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.sway,
    required this.phase,
    required this.opacity,
    required this.color,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      double y = p.y - progress * p.speed;
      y = y - y.floor();
      final x = p.x + math.sin(progress * 6.28 + p.phase) * p.sway;
      final double edgeFade =
          (y < 0.05 ? y / 0.05 : (y > 0.95 ? (1 - y) / 0.05 : 1.0))
              .clamp(0.0, 1.0);
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity * edgeFade);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}

// ═══════════════════════════════════════════════════════════════
// Background grid overlays — slow scan sweep + glowing dots
// that ride the sweep band. Pairs with TechGridPainter for a
// layered "tech HUD" feel.
// ═══════════════════════════════════════════════════════════════

class _GridSweepPainter extends CustomPainter {
  final double progress;
  final Color color;
  _GridSweepPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;

    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.10),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 60, size.width, 120));
    canvas.drawRect(Rect.fromLTWH(0, y - 60, size.width, 120), glowPaint);

    final linePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.32),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 2));
    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), linePaint);
  }

  @override
  bool shouldRepaint(covariant _GridSweepPainter old) =>
      old.progress != progress || old.color != color;
}

class _GridDotsPainter extends CustomPainter {
  final double sweep;
  final double pulse;
  final Color color;
  _GridDotsPainter({
    required this.sweep,
    required this.pulse,
    required this.color,
  });

  static const double _spacing = 120;

  @override
  void paint(Canvas canvas, Size size) {
    final cols = (size.width / _spacing).floor() + 2;
    final rows = (size.height / _spacing).floor() + 2;
    final sweepY = sweep * size.height;

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        final x = i * _spacing.toDouble();
        final y = j * _spacing.toDouble();
        final dist = (y - sweepY).abs();
        final band = (1.0 - (dist / 90)).clamp(0.0, 1.0);
        if (band <= 0) continue;

        final breathing =
            0.5 + 0.5 * (math.sin(pulse * 6.28 + (i + j) * 0.4) * 0.5 + 0.5);
        final intensity = band * (0.55 + 0.45 * breathing);

        final glow = Paint()
          ..color = color.withValues(alpha: intensity * 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        final dot = Paint()..color = color.withValues(alpha: intensity * 0.9);

        canvas.drawCircle(Offset(x, y), 3.2, glow);
        canvas.drawCircle(Offset(x, y), 1.6, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridDotsPainter old) =>
      old.sweep != sweep || old.pulse != pulse || old.color != color;
}
