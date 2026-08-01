import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/idle_content.dart';

/// Interactive Suggestion Card for TV Signage Idle Screens.
class IdleSuggestionCard extends StatefulWidget {
  final IdleSuggestion suggestion;
  final Color accent;
  final double scale;
  final bool active;
  final TextStyle labelStyle;
  final double hintFontSize;
  final double cardWidth;
  final double cardHeight;

  const IdleSuggestionCard({
    super.key,
    required this.suggestion,
    required this.accent,
    required this.scale,
    required this.active,
    required this.labelStyle,
    required this.hintFontSize,
    this.cardWidth = 190,
    this.cardHeight = 130,
  });

  @override
  State<IdleSuggestionCard> createState() => IdleSuggestionCardState();
}

class IdleSuggestionCardState extends State<IdleSuggestionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.suggestion;
    final scale = widget.scale;
    final active = widget.active;
    final cardScale = widget.cardWidth / 190;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glow = active ? _pulse.value : 0.0;
        final scaleAnim = active ? 1.0 + _pulse.value * 0.06 : 1.0;
        return Transform.scale(
          scale: scaleAnim,
          child: Container(
            width: widget.cardWidth * scale,
            height: widget.cardHeight * scale,
            padding: EdgeInsets.symmetric(
              horizontal: 12 * scale * cardScale,
              vertical: 12 * scale * cardScale,
            ),
            decoration: BoxDecoration(
              color: active
                  ? widget.accent.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12 * cardScale),
              border: Border.all(
                color: active
                    ? widget.accent.withValues(alpha: 0.55 + glow * 0.45)
                    : Colors.white.withValues(alpha: 0.08),
                width: active ? 2 : 1,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: widget.accent.withValues(alpha: 0.4 * glow),
                        blurRadius: 28 * cardScale,
                        spreadRadius: 1 * cardScale,
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(10 * scale * cardScale),
                  decoration: BoxDecoration(
                    color: active
                        ? widget.accent.withValues(alpha: 0.22)
                        : Colors.white.withValues(alpha: 0.04),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    s.icon,
                    color: active
                        ? widget.accent
                        : Colors.white.withValues(alpha: 0.35),
                    size: 26 * scale * cardScale,
                  ),
                ),
                SizedBox(height: 10 * scale * cardScale),
                Text(
                  s.label,
                  textAlign: TextAlign.center,
                  style: widget.labelStyle.copyWith(
                    color: active
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                SizedBox(height: 4 * scale * cardScale),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: active ? 1.0 : 0.0,
                  child: Text(
                    'TAP TO START',
                    style: GoogleFonts.spaceMono(
                      fontSize: widget.hintFontSize,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                      color: widget.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
