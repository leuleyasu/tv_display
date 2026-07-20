part of 'birthday_overlay.dart';

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
