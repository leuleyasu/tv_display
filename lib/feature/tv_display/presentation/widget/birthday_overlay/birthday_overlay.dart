import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

part 'confetti.dart';
part 'shared.dart';
part 'post_layout.dart';
part 'polaroid_layout.dart';
part 'split_layout.dart';
part 'neon_layout.dart';
part 'glass_layout.dart';
part 'cinema_layout.dart';
part 'bento_layout.dart';
part 'aurora_layout.dart';
part 'hud_layout.dart';
part 'terminal_layout.dart';
part 'ai_chat_layout.dart';
part 'hologram_layout.dart';
part 'stories_layout.dart';
part 'placeholder_layouts.dart';

/// Which "card style" the dashboard wants to render.
///
/// ── Classic (kept for backward compatibility) ──
/// `post`     — Instagram-feed style, portrait card
/// `polaroid` — white frame + slight rotation, like a printed photo
/// `split`    — landscape magazine spread, best for TV
///
/// ── New cool designs ──
/// `neon`     — Cyberpunk neon glow with animated grid + scanlines
/// `glass`    — Frosted glassmorphism with floating orbs
/// `cinema`   — Vintage film strip with projector spotlights
/// `bento`    — Apple-style bento grid with multiple tiles
/// `aurora`   — Northern lights with twinkling stars
///
/// `auto`     — picks a layout based on aspect / presence of image
enum BirthdayLayout {
  post,
  polaroid,
  split,
  neon,
  glass,
  cinema,
  bento,
  aurora,
  hud,
  terminal,
  aiChat,
  hologram,
  stories,
  confettiPop,
  magazine,
  photoBooth,
  balloons,
  retroGeometric,
  auto,
}

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

  /// Whether [imageUrl] refers to a local asset (vs. a network URL).
  final bool isAsset;

  /// Optional extra images for the [BirthdayLayout.stories] layout.
  /// When omitted, the layout reuses [imageUrl] as the hero frame.
  final List<String>? storyImages;

  /// Whether [storyImages] entries are local assets (vs network URLs).
  /// Falls back to [isAsset] when not provided.
  final bool? storiesIsAsset;

  const BirthdayOverlay({
    super.key,
    this.imageUrl,
    required this.name,
    this.wish = '',
    required this.scale,
    this.layout = BirthdayLayout.stories,
    this.accentColor = const Color(0xFFFBBF24),
    this.badgeText,
    this.isAsset = false,
    this.storyImages,
    this.storiesIsAsset,
  });

  @override
  State<BirthdayOverlay> createState() => _BirthdayOverlayState();
}

class _BirthdayOverlayState extends State<BirthdayOverlay>
    with TickerProviderStateMixin {
  /// Whether [widget.imageUrl] points to a local asset.
  bool get isAsset => widget.isAsset;
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

    // Auto: spread the cool new designs across aspect ratios.
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return BirthdayLayout.aurora; // works great without an image
    }
    final size = MediaQuery.maybeOf(context)?.size ?? const Size(1920, 1080);
    if (size.width > size.height * 1.4) {
      return BirthdayLayout.bento; // TV → bento spread
    } else if (size.width > size.height) {
      return BirthdayLayout.split; // tablet → split
    } else {
      return BirthdayLayout.neon; // portrait → neon
    }
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

      // ── NEW COOL LAYOUTS ──
      case BirthdayLayout.neon:
        return _NeonLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.glass:
        return _GlassLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.cinema:
        return _CinemaLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.bento:
        return _BentoLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
          badgeText: widget.badgeText,
        );
      case BirthdayLayout.aurora:
        return _AuroraLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );

      // ── TECH & AI LAB ──
      case BirthdayLayout.hud:
        return _HudLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
          badgeText: widget.badgeText,
        );
      case BirthdayLayout.terminal:
        return _TerminalLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.aiChat:
        return _AiChatLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.hologram:
        return _HologramLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );

      case BirthdayLayout.stories:
        return _StoriesLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          storyImages: widget.storyImages,
          isAsset: widget.storiesIsAsset ?? widget.isAsset,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );

      case BirthdayLayout.confettiPop:
        return _ConfettiPopLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.magazine:
        return _MagazineLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.photoBooth:
        return _PhotoBoothLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.balloons:
        return _BalloonsLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );
      case BirthdayLayout.retroGeometric:
        return _RetroGeometricLayout(
          state: this,
          scale: scale,
          box: box,
          imageUrl: widget.imageUrl,
          name: widget.name,
          wish: widget.wish,
          accent: widget.accentColor,
        );

      case BirthdayLayout.auto:
        // Handled by _effectiveLayout
        return const SizedBox.shrink();
    }
  }

  // ── Confetti layer ──────────────────────────────────────────
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
