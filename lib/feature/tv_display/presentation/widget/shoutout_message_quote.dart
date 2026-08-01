import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'blinking_cursor.dart';
import 'quote_glyph.dart';
import 'typewriter_text.dart';

/// Message Quote component with decorative QuoteGlyphs, Typewriter text, and Blinking Cursor.
class ShoutoutMessageQuote extends StatelessWidget {
  final String text;
  final Color accent;
  final double fontSize;
  final double scale;
  final int currentIndex;
  final Animation<double> entryAnim;
  final Animation<double> orbAnim;
  final String? fontFamily;

  const ShoutoutMessageQuote({
    super.key,
    required this.text,
    required this.accent,
    required this.fontSize,
    required this.scale,
    required this.currentIndex,
    required this.entryAnim,
    required this.orbAnim,
    this.fontFamily,
  });

  TextStyle _getFontStyle() {
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      height: 1.3,
      letterSpacing: 0.5,
    );
    if (fontFamily != null && fontFamily!.isNotEmpty) {
      return GoogleFonts.getFont(fontFamily!, textStyle: base);
    }
    return GoogleFonts.spaceGrotesk(textStyle: base);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 36 * scale,
        vertical: 28 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -22 * scale,
            left: -14 * scale,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 600),
              scale: entryAnim.value,
              child: QuoteGlyph(
                color: accent,
                size: 56 * scale,
                align: Alignment.topLeft,
              ),
            ),
          ),
          Positioned(
            bottom: -28 * scale,
            right: -14 * scale,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 600),
              scale: entryAnim.value,
              child: QuoteGlyph(
                color: accent,
                size: 56 * scale,
                align: Alignment.bottomRight,
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Colors.white70,
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white70,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds),
                  child: AnimatedBuilder(
                    animation: orbAnim,
                    builder: (context, child) {
                      return TypewriterText(
                        key: ValueKey('tw_${currentIndex}_$text'),
                        text: text,
                        textAlign: TextAlign.center,
                        style: _getFontStyle(),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 6 * scale),
              Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: BlinkingCursor(
                  color: accent,
                  height: fontSize * 0.9,
                  width: 4 * scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
