part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 9 — HUD (Tactical sci-fi, corner brackets, target reticle)
// ═══════════════════════════════════════════════════════════════

class _HudLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;
  final String? badgeText;

  const _HudLayout({
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
    final nameSize = min(box.maxWidth * 0.05, 64.0) * scale;
    final cyan = const Color(0xFF00FFD1);

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
            color: const Color(0xFF02060E),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Subtle vignette
                Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.2,
                      colors: [Color(0xFF0a2540), Color(0xFF020b18)],
                    ),
                  ),
                ),
                // CRT scanlines
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _HudScanlinePainter()),
                  ),
                ),
                // Animated scan line moving down
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: state._glowCtrl,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _HudScanLinePainter(
                          progress: state._glowCtrl.value,
                          color: cyan,
                        ),
                      );
                    },
                  ),
                ),
                // Corner brackets
                ..._buildCorners(cyan, scale),
                // Top label
                Positioned(
                  top: 18 * scale,
                  left: 0,
                  right: 0,
                  child: _EntryAnimated(
                    animation: state._nameIn,
                    rise: 0,
                    child: Text(
                      '◆ TARGET ACQUIRED ◆',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceMono(
                        fontSize: 10 * scale,
                        color: cyan,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: cyan, blurRadius: 8)],
                      ),
                    ),
                  ),
                ),
                // Left data column
                Positioned(
                  top: 60 * scale,
                  left: 22 * scale,
                  child: _HudDataColumn(
                    state: state,
                    scale: scale,
                    color: cyan,
                    items: [
                      ('SYS', 'BDAY.OS'),
                      ('AGE', badgeText != null ? '$badgeText YR' : '+1.0 YR'),
                      (
                        'LVL',
                        badgeText != null
                            ? '→ ${int.tryParse(badgeText!) != null ? (int.parse(badgeText!) + 1).toString() : "∞"}'
                            : '→ 26'
                      ),
                      ('JOY', '99.7%'),
                    ],
                  ),
                ),
                // Right data column
                Positioned(
                  top: 60 * scale,
                  right: 22 * scale,
                  child: _HudDataColumn(
                    state: state,
                    scale: scale,
                    color: cyan,
                    alignEnd: true,
                    items: [
                      ('SCAN', '100%'),
                      ('CAKE', 'FULL'),
                      ('WISH', '██▒▒'),
                      ('LOVE', '∞'),
                    ],
                  ),
                ),
                // Center reticle with image
                Center(
                  child: SizedBox(
                    width: 130 * scale,
                    height: 130 * scale,
                    child: AnimatedBuilder(
                      animation: state._glowCtrl,
                      child: Padding(
                        padding: EdgeInsets.all(8 * scale),
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
                        return Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cyan, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: cyan.withValues(
                                    alpha: 0.5 *
                                        (0.5 + state._glowCtrl.value * 0.5)),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                    ),
                  ),
                ),
                // Crosshair lines through center
                Center(
                  child: SizedBox(
                    width: 160 * scale,
                    height: 160 * scale,
                    child:
                        CustomPaint(painter: _HudCrosshairPainter(color: cyan)),
                  ),
                ),
                // Big name (bottom)
                Positioned(
                  left: 24 * scale,
                  right: 24 * scale,
                  bottom: 60 * scale,
                  child: _EntryAnimated(
                    animation: state._nameIn,
                    child: Text(
                      name.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: nameSize,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(color: cyan, blurRadius: 14),
                          Shadow(
                              color: cyan.withValues(alpha: 0.6),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ),
                if (wish.isNotEmpty)
                  Positioned(
                    left: 24 * scale,
                    right: 24 * scale,
                    bottom: 30 * scale,
                    child: _EntryAnimated(
                      animation: state._wishIn,
                      child: Text(
                        '> $wish',
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
                // Bottom status bar
                Positioned(
                  left: 22 * scale,
                  right: 22 * scale,
                  bottom: 14 * scale,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HudPulse(color: cyan, scale: scale, label: 'SCANNING'),
                      _HudBar(
                          color: cyan, scale: scale, label: 'HP', fill: 0.85),
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

  List<Widget> _buildCorners(Color cyan, double scale) {
    Widget corner({double? top, double? left, double? right, double? bottom}) {
      return Positioned(
        top: top,
        left: left,
        right: right,
        bottom: bottom,
        child: Container(
          width: 24 * scale,
          height: 24 * scale,
          decoration: BoxDecoration(
            border: Border(
              top: top != null
                  ? BorderSide(color: cyan, width: 2)
                  : BorderSide.none,
              left: left != null
                  ? BorderSide(color: cyan, width: 2)
                  : BorderSide.none,
              right: right != null
                  ? BorderSide(color: cyan, width: 2)
                  : BorderSide.none,
              bottom: bottom != null
                  ? BorderSide(color: cyan, width: 2)
                  : BorderSide.none,
            ),
            boxShadow: [
              BoxShadow(color: cyan.withValues(alpha: 0.5), blurRadius: 6)
            ],
          ),
        ),
      );
    }

    return [
      corner(top: 12 * scale, left: 12 * scale, right: null, bottom: null),
      corner(top: 12 * scale, left: null, right: 12 * scale, bottom: null),
      corner(top: null, left: 12 * scale, right: null, bottom: 12 * scale),
      corner(top: null, left: null, right: 12 * scale, bottom: 12 * scale),
    ];
  }
}

class _HudDataColumn extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final Color color;
  final bool alignEnd;
  final List<(String, String)> items;
  const _HudDataColumn({
    required this.state,
    required this.scale,
    required this.color,
    required this.items,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return _EntryAnimated(
      animation: state._nameIn,
      rise: 0,
      child: Column(
        crossAxisAlignment:
            alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: items
            .map((it) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4 * scale),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.spaceMono(
                        fontSize: 10 * scale,
                        letterSpacing: 1,
                      ),
                      children: [
                        TextSpan(
                          text: '${it.$1} ',
                          style:
                              TextStyle(color: color.withValues(alpha: 0.55)),
                        ),
                        TextSpan(
                          text: it.$2,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 4)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _HudPulse extends StatefulWidget {
  final Color color;
  final double scale;
  final String label;
  const _HudPulse(
      {required this.color, required this.scale, required this.label});

  @override
  State<_HudPulse> createState() => _HudPulseState();
}

class _HudPulseState extends State<_HudPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
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
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6 * widget.scale,
              height: 6 * widget.scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.7),
                    blurRadius: 6 * (0.5 + _c.value),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6 * widget.scale),
            Text(
              widget.label,
              style: GoogleFonts.spaceMono(
                fontSize: 9 * widget.scale,
                color: widget.color,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HudBar extends StatelessWidget {
  final Color color;
  final double scale;
  final String label;
  final double fill;
  const _HudBar(
      {required this.color,
      required this.scale,
      required this.label,
      required this.fill});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 9 * scale,
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        SizedBox(width: 6 * scale),
        Container(
          width: 50 * scale,
          height: 5 * scale,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: fill,
            child: Container(color: color),
          ),
        ),
      ],
    );
  }
}

class _HudScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFD1).withValues(alpha: 0.05);
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HudScanlinePainter oldDelegate) => false;
}

class _HudScanLinePainter extends CustomPainter {
  final double progress;
  final Color color;
  _HudScanLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0),
          color.withValues(alpha: 0.6),
          color.withValues(alpha: 0)
        ],
      ).createShader(Rect.fromLTWH(0, y - 2, size.width, 4));
    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), paint);
  }

  @override
  bool shouldRepaint(covariant _HudScanLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _HudCrosshairPainter extends CustomPainter {
  final Color color;
  _HudCrosshairPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), paint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _HudCrosshairPainter oldDelegate) => false;
}
