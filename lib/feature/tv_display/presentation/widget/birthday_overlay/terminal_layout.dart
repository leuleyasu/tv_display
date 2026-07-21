part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 10 — TERMINAL (Hacker CLI, ASCII cake, blinking cursor)
// ═══════════════════════════════════════════════════════════════

class _TerminalLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _TerminalLayout({
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
    final green = const Color(0xFF4ADE80);

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
          borderRadius: BorderRadius.circular(6),
          child: Container(
            color: const Color(0xFF0a0e0a),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Subtle matrix rain
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: state._confettiCtrl,
                    builder: (context, _) => CustomPaint(
                      painter: _MatrixRainPainter(
                          progress: state._confettiCtrl.value),
                    ),
                  ),
                ),
                // CRT scanlines
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _TerminalScanlinePainter()),
                  ),
                ),
                // Profile image (faint terminal-style badge)
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  Positioned(
                    top: 16 * scale,
                    right: 16 * scale,
                    width: 60 * scale,
                    height: 60 * scale,
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
                // Terminal content
                Padding(
                  padding: EdgeInsets.all(20 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _TermLine(
                        state: state,
                        scale: scale,
                        delay: 0.0,
                        children: [
                          _TermSpan('yara@birthday:~',
                              color: green, bold: true),
                          _TermSpan(' ./celebrate.sh',
                              color: Colors.white.withValues(alpha: 0.6)),
                        ],
                      ),
                      SizedBox(height: 6 * scale),
                      _TermLine(
                        state: state,
                        scale: scale,
                        delay: 0.15,
                        children: [
                          _TermSpan('[',
                              color: Colors.white.withValues(alpha: 0.5)),
                          _TermSpan('OK', color: const Color(0xFFfacc15)),
                          _TermSpan('] booting cake_engine v2.5 ...',
                              color: Colors.white.withValues(alpha: 0.7)),
                        ],
                      ),
                      _TermLine(
                        state: state,
                        scale: scale,
                        delay: 0.25,
                        children: [
                          _TermSpan('[',
                              color: Colors.white.withValues(alpha: 0.5)),
                          _TermSpan('OK', color: const Color(0xFFfacc15)),
                          _TermSpan('] loading wishes.db (365 entries)',
                              color: Colors.white.withValues(alpha: 0.7)),
                        ],
                      ),
                      _TermLine(
                        state: state,
                        scale: scale,
                        delay: 0.35,
                        children: [
                          _TermSpan('[',
                              color: Colors.white.withValues(alpha: 0.5)),
                          _TermSpan('OK', color: const Color(0xFFfacc15)),
                          _TermSpan('] deploying joy.cake to user...',
                              color: Colors.white.withValues(alpha: 0.7)),
                        ],
                      ),
                      SizedBox(height: 10 * scale),
                      // ASCII cake
                      _EntryAnimated(
                        animation: state._nameIn,
                        rise: 0,
                        child: Text(
                          '''       )  (  )
      (   ) )
       ) ( (
    _______(_)_
 .-'---------|  
( C|/\\/\\/\\/|
 '-._________|
    '-------' ''',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9 * scale,
                            color: green,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                  color: green.withValues(alpha: 0.5),
                                  blurRadius: 4)
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      // Big ASCII name
                      _EntryAnimated(
                        animation: state._nameIn,
                        rise: 0,
                        child: Text(
                          '>> HAPPY BIRTHDAY ${name.toUpperCase()} <<',
                          style: GoogleFonts.spaceMono(
                            fontSize: nameSize * 0.6,
                            color: green,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            shadows: [Shadow(color: green, blurRadius: 8)],
                          ),
                        ),
                      ),
                      if (wish.isNotEmpty) ...[
                        SizedBox(height: 6 * scale),
                        _EntryAnimated(
                          animation: state._wishIn,
                          rise: 0,
                          child: Text(
                            '→ $wish',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11 * scale,
                              color: green.withValues(alpha: 0.85),
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      SizedBox(height: 4 * scale),
                      _TermLine(
                        state: state,
                        scale: scale,
                        delay: 0.7,
                        children: [
                          _TermSpan('[',
                              color: Colors.white.withValues(alpha: 0.5)),
                          _TermSpan('DONE', color: green, bold: true),
                          _TermSpan('] birthday.exe exited with code 0 🎉',
                              color: Colors.white.withValues(alpha: 0.7)),
                        ],
                      ),
                      const Spacer(),
                      // Prompt with cursor
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _EntryAnimated(
                            animation: state._emojisIn,
                            rise: 0,
                            child: Text(
                              'yara@birthday:~',
                              style: GoogleFonts.spaceMono(
                                fontSize: 11 * scale,
                                color: green,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 6 * scale),
                          _BlinkingCursor(color: green, scale: scale),
                        ],
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

class _TermLine extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final double delay;
  final List<_TermSpan> children;
  const _TermLine({
    required this.state,
    required this.scale,
    required this.delay,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2 * scale),
      child: _EntryAnimated(
        animation: state._entranceCtrl,
        rise: 4,
        child: RichText(
          text: TextSpan(
            style: GoogleFonts.spaceMono(fontSize: 11 * scale),
            children: children.map((c) => c.build()).toList(),
          ),
        ),
      ),
    );
  }
}

class _TermSpan {
  final String text;
  final Color color;
  final bool bold;
  _TermSpan(this.text, {required this.color, this.bold = false});

  TextSpan build() => TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          shadows: bold
              ? [Shadow(color: color.withValues(alpha: 0.5), blurRadius: 3)]
              : null,
        ),
      );
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  final double scale;
  const _BlinkingCursor({required this.color, required this.scale});

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
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
      builder: (_, __) => Opacity(
        opacity: 0.3 + 0.7 * _c.value,
        child: Container(
          width: 7 * widget.scale,
          height: 14 * widget.scale,
          color: widget.color,
          margin: EdgeInsets.only(top: 1 * widget.scale),
        ),
      ),
    );
  }
}

class _MatrixRainPainter extends CustomPainter {
  final double progress;
  _MatrixRainPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint();
    for (int i = 0; i < 18; i++) {
      final x = rng.nextDouble() * size.width;
      final t = (rng.nextDouble() + progress) % 1.0;
      final y = t * size.height;
      final alpha = (1 - t).clamp(0.0, 1.0) * 0.15;
      paint.color = const Color(0xFF4ADE80).withValues(alpha: alpha);
      // Falling characters (just vertical lines of varying length)
      for (int j = 0; j < 6; j++) {
        final ly = y - j * 8;
        if (ly < 0) break;
        final la = alpha * (1 - j / 6);
        paint.color = const Color(0xFF4ADE80).withValues(alpha: la);
        canvas.drawRect(Rect.fromLTWH(x, ly, 1.5, 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixRainPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _TerminalScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4ADE80).withValues(alpha: 0.04);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TerminalScanlinePainter oldDelegate) => false;
}
