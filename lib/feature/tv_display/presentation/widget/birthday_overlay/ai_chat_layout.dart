part of 'birthday_overlay.dart';

// ═══════════════════════════════════════════════════════════════
// LAYOUT 11 — AI CHAT (ChatGPT-style conversation)
// ═══════════════════════════════════════════════════════════════

class _AiChatLayout extends StatelessWidget {
  final _BirthdayOverlayState state;
  final double scale;
  final BoxConstraints box;
  final String? imageUrl;
  final String name;
  final String wish;
  final Color accent;

  const _AiChatLayout({
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
    final nameSize = min(box.maxWidth * 0.045, 48.0) * scale;
    final aiReply =
        wish.isNotEmpty ? wish : 'Wishing you the brightest year yet ✨';

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
                constraints: BoxConstraints(maxWidth: box.maxWidth * 0.55),
                child: child,
              ),
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: const Color(0xFFF7F7F5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header bar
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale, vertical: 12 * scale),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.black.withValues(alpha: 0.08))),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10 * scale,
                      height: 10 * scale,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10A37F),
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      'Birthday-GPT',
                      style: GoogleFonts.interTight(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF202123),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '● online',
                      style: GoogleFonts.interTight(
                        fontSize: 10 * scale,
                        color: const Color(0xFF10A37F),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Chat body
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User message
                    _EntryAnimated(
                      animation: state._nameIn,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14 * scale, vertical: 10 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFF202123),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16 * scale),
                                  topRight: Radius.circular(16 * scale),
                                  bottomLeft: Radius.circular(16 * scale),
                                  bottomRight: Radius.circular(4 * scale),
                                ),
                              ),
                              child: Text(
                                "It's my birthday today 🎂",
                                style: GoogleFonts.interTight(
                                  fontSize: 14 * scale,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8 * scale),
                          if (imageUrl != null && imageUrl!.isNotEmpty)
                            ClipOval(
                              child: SizedBox(
                                width: 28 * scale,
                                height: 28 * scale,
                                child: _BirthdayImage(
                                  state: state,
                                  url: imageUrl,
                                  scale: scale,
                                  box: box,
                                  accent: accent,
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 28 * scale,
                              height: 28 * scale,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF202123),
                              ),
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 16 * scale),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    // AI reply
                    _EntryAnimated(
                      animation: state._wishIn,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28 * scale,
                            height: 28 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [accent, const Color(0xFFFF007A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(Icons.auto_awesome,
                                color: Colors.white, size: 14 * scale),
                          ),
                          SizedBox(width: 8 * scale),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Birthday-GPT',
                                  style: GoogleFonts.interTight(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF202123),
                                  ),
                                ),
                                SizedBox(height: 2 * scale),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Happy birthday, ',
                                        style: GoogleFonts.interTight(
                                          fontSize: nameSize * 0.5,
                                          color: const Color(0xFF202123),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '$name',
                                        style: GoogleFonts.interTight(
                                          fontSize: nameSize * 0.5,
                                          color: accent,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '! 🎉 $aiReply',
                                        style: GoogleFonts.interTight(
                                          fontSize: nameSize * 0.5,
                                          color: const Color(0xFF202123),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 6 * scale),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ChatIcon(
                                        icon: Icons.thumb_up_outlined,
                                        scale: scale),
                                    SizedBox(width: 4 * scale),
                                    _ChatIcon(
                                        icon: Icons.thumb_down_outlined,
                                        scale: scale),
                                    SizedBox(width: 4 * scale),
                                    _ChatIcon(
                                        icon: Icons.refresh, scale: scale),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10 * scale),
                    // Typing dots
                    _EntryAnimated(
                      animation: state._emojisIn,
                      rise: 0,
                      child: Row(
                        children: [
                          Container(
                            width: 28 * scale,
                            height: 28 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [accent, const Color(0xFFFF007A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(Icons.auto_awesome,
                                color: Colors.white, size: 14 * scale),
                          ),
                          SizedBox(width: 8 * scale),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale, vertical: 8 * scale),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(
                                  color: Colors.black.withValues(alpha: 0.08)),
                            ),
                            child: _TypingDots(scale: scale),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14 * scale),
                    // Input bar
                    _EntryAnimated(
                      animation: state._emojisIn,
                      rise: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14 * scale, vertical: 10 * scale),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(
                              color: Colors.black.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Ask Birthday-GPT…',
                              style: GoogleFonts.interTight(
                                fontSize: 13 * scale,
                                color: Colors.black.withValues(alpha: 0.4),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 24 * scale,
                              height: 24 * scale,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF202123),
                              ),
                              child: Icon(Icons.arrow_upward,
                                  color: Colors.white, size: 14 * scale),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatIcon extends StatelessWidget {
  final IconData icon;
  final double scale;
  const _ChatIcon({required this.icon, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4 * scale),
      child: Icon(icon,
          size: 14 * scale, color: Colors.black.withValues(alpha: 0.5)),
    );
  }
}

class _TypingDots extends StatefulWidget {
  final double scale;
  const _TypingDots({required this.scale});

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
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
          children: List.generate(3, (i) {
            final phase = (_c.value - i * 0.15) % 1.0;
            final dy = -3 * sin(phase * 2 * pi).abs();
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2 * widget.scale),
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Container(
                  width: 5 * widget.scale,
                  height: 5 * widget.scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
