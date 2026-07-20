part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 14 — CONFETTI POP (Playful confetti burst + bold text)
// ═══════════════════════════════════════════════════════════════

class _ConfettiPopLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _ConfettiPopLayout({
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
    final nameSize = min(box.maxWidth * 0.055, 72.0) * scale;
    return AnimatedBuilder(
      animation: state._entranceCtrl,
      builder: (context, child) => Opacity(
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
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF1a0033), const Color(0xFF0a0014)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.symmetric(
              horizontal: 32 * scale, vertical: 40 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎉', style: TextStyle(fontSize: 64 * scale)),
              SizedBox(height: 16 * scale),
              _EntryAnimated(
                animation: state._nameIn,
                child: Text(
                  name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: nameSize,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 4,
                    shadows: [Shadow(color: accent, blurRadius: 30)],
                  ),
                ),
              ),
              if (wish.isNotEmpty) ...[
                SizedBox(height: 12 * scale),
                _WishLine(
                    state: state,
                    wish: wish,
                    fontSize: 18 * scale,
                    scale: scale),
              ],
              SizedBox(height: 20 * scale),
              _EmojiRow(
                  state: state,
                  emojis: const ['🎊', '🎉', '🥳', '🎈', '🎁', '✨'],
                  scale: scale,
                  size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LAYOUT 15 — MAGAZINE (Editorial spread, big typography)
// ═══════════════════════════════════════════════════════════════

class _MagazineLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _MagazineLayout({
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
    final nameSize = min(box.maxWidth * 0.07, 96.0) * scale;
    return AnimatedBuilder(
      animation: state._entranceCtrl,
      builder: (context, child) => Opacity(
        opacity: state._entranceFade.value,
        child: SlideTransition(
          position: state._entranceSlide,
          child: ScaleTransition(
            scale: state._entranceScale,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: box.maxWidth * 0.85),
              child: child,
            ),
          ),
        ),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            color: Colors.white,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: _BirthdayImage(
                          state: state,
                          url: imageUrl,
                          scale: scale,
                          box: box,
                          accent: accent),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(32 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _EntryAnimated(
                          animation: state._nameIn,
                          rise: 0,
                          child: Text(
                            'HAPPY BIRTHDAY',
                            style: GoogleFonts.playfairDisplay(
                                fontSize: nameSize * 0.3,
                                fontWeight: FontWeight.w400,
                                color: accent,
                                letterSpacing: 6),
                          )),
                      SizedBox(height: 4 * scale),
                      _EntryAnimated(
                          animation: state._nameIn,
                          rise: 0,
                          child: Text(
                            name,
                            style: GoogleFonts.playfairDisplay(
                                fontSize: nameSize,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF1a1a1a),
                                height: 1.0),
                          )),
                      if (wish.isNotEmpty) ...[
                        SizedBox(height: 14 * scale),
                        _WishLine(
                            state: state,
                            wish: '“$wish”',
                            fontSize: 16 * scale,
                            scale: scale,
                            maxLines: 2),
                      ],
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

// ═══════════════════════════════════════════════════════════════
// LAYOUT 16 — PHOTO BOOTH (Film strip of memories)
// ═══════════════════════════════════════════════════════════════

class _PhotoBoothLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _PhotoBoothLayout({
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
      builder: (context, child) => Opacity(
        opacity: state._entranceFade.value,
        child: SlideTransition(
          position: state._entranceSlide,
          child: ScaleTransition(
            scale: state._entranceScale,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: box.maxWidth * 0.55),
              child: child,
            ),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: const Color(0xFF1a1a2e),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 240 * scale,
                color: const Color(0xFF0f0f23),
                child: Row(
                  children: [
                    Expanded(child: _photoFrame(0)),
                    Container(
                        width: 4, color: Colors.white.withValues(alpha: 0.05)),
                    Expanded(child: _photoFrame(1)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Column(
                  children: [
                    _EntryAnimated(
                        animation: state._nameIn,
                        child: _ShimmerName(
                            state: state,
                            name: name,
                            accent: accent,
                            fontSize: nameSize,
                            scale: scale)),
                    if (wish.isNotEmpty) ...[
                      SizedBox(height: 10 * scale),
                      _WishLine(
                          state: state,
                          wish: wish,
                          fontSize: 16 * scale,
                          scale: scale),
                    ],
                    SizedBox(height: 16 * scale),
                    _EmojiRow(
                        state: state,
                        emojis: const ['📸', '🎞️', '🎬', '🎭'],
                        scale: scale,
                        size: 26),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoFrame(int i) {
    final colors = [accent, const Color(0xFFFF007A)];
    return Container(
      margin: EdgeInsets.all(8 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: [colors[i].withValues(alpha: 0.3), const Color(0xFF0f0f23)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child:
            Text(i == 0 ? '📸' : '🎞️', style: TextStyle(fontSize: 48 * scale)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LAYOUT 17 — BALLOONS (Floating helium balloons + name)
// ═══════════════════════════════════════════════════════════════

class _BalloonsLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _BalloonsLayout({
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
      builder: (context, child) => Opacity(
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
      ),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF1a1a3e), const Color(0xFF0a0a1e)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ...List.generate(8, (i) => _balloon(i)),
                Padding(
                  padding: EdgeInsets.all(32 * scale),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _EntryAnimated(
                        animation: state._nameIn,
                        child: Text(
                          name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: nameSize,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 4,
                            shadows: [Shadow(color: accent, blurRadius: 20)],
                          ),
                        ),
                      ),
                      if (wish.isNotEmpty) ...[
                        SizedBox(height: 10 * scale),
                        _WishLine(
                            state: state,
                            wish: wish,
                            fontSize: 16 * scale,
                            scale: scale),
                      ],
                      SizedBox(height: 14 * scale),
                      _EmojiRow(
                          state: state,
                          emojis: const ['🎈', '🎉', '🥳', '✨'],
                          scale: scale,
                          size: 28),
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

  Widget _balloon(int i) {
    final rng = Random(i * 7);
    final colors = [
      accent,
      const Color(0xFFFF007A),
      const Color(0xFF22D3EE),
      const Color(0xFFA855F7),
      const Color(0xFF10B981)
    ];
    final c = colors[i % colors.length];
    final x = 0.05 + rng.nextDouble() * 0.9;
    final y = -0.1 + rng.nextDouble() * 0.5;
    final size = 20 + rng.nextDouble() * 30;
    return AnimatedBuilder(
      animation: state._glowCtrl,
      builder: (context, _) {
        final float = sin(state._glowCtrl.value * 2 + i) * 6 * scale;
        return Positioned(
          left: x * 100 * scale - size * scale,
          top: y * 100 * scale + float,
          child: Transform.rotate(
            angle: sin(state._glowCtrl.value + i) * 0.1,
            child: Container(
              width: size * scale,
              height: size * 1.2 * scale,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 12)
                ],
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 4 * scale),
                  child: Text('🎈',
                      style: TextStyle(fontSize: size * 0.6 * scale)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LAYOUT 18 — RETRO GEOMETRIC (80s Memphis, squiggles + color)
// ═══════════════════════════════════════════════════════════════

class _RetroGeometricLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _RetroGeometricLayout({
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
      builder: (context, child) => Opacity(
        opacity: state._entranceFade.value,
        child: SlideTransition(
          position: state._entranceSlide,
          child: ScaleTransition(
            scale: state._entranceScale,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: box.maxWidth * 0.55),
              child: child,
            ),
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          color: const Color(0xFFF5F0E8),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Geometric shapes
              ..._shapes(),
              Padding(
                padding: EdgeInsets.all(32 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _EntryAnimated(
                        animation: state._nameIn,
                        rise: 0,
                        child: Text(
                          'HAPPY BIRTHDAY',
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2A2A2A),
                              letterSpacing: 4),
                        )),
                    SizedBox(height: 6 * scale),
                    _EntryAnimated(
                        animation: state._nameIn,
                        rise: 0,
                        child: Text(
                          name,
                          style: GoogleFonts.spaceGrotesk(
                              fontSize: nameSize,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1a1a1a),
                              letterSpacing: -1),
                        )),
                    if (wish.isNotEmpty) ...[
                      SizedBox(height: 14 * scale),
                      _WishLine(
                          state: state,
                          wish: wish,
                          fontSize: 16 * scale,
                          scale: scale),
                    ],
                    SizedBox(height: 20 * scale),
                    _EmojiRow(
                        state: state,
                        emojis: const ['💃', '🕺', '🎶', '✨', '🎉'],
                        scale: scale,
                        size: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _shapes() {
    return [
      Positioned(
          top: -20,
          right: -20,
          child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle))),
      Positioned(
        bottom: 40,
        left: -30,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFFF007A).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      Positioned(
        top: 60,
        left: 20,
        child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFF22D3EE).withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8))),
      ),
      Positioned(
        bottom: 80,
        right: 30,
        child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12))),
      ),
    ];
  }
}
