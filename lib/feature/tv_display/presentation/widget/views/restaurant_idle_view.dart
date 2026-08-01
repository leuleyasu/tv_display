import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/backgrounds/restaurant_background.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_footer.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_qr_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_suggestion_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/shoutout_top_bar.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/world_cup_overlay.dart';

/// Specialized Warm Culinary Restaurant Display View.
class RestaurantIdleView extends StatelessWidget {
  final List<IdleSlide> effectiveSlides;
  final List<IdleSuggestion> effectiveSuggestions;
  final int idleSlideIndex;
  final SettingsModel? settings;
  final String orgName;
  final DateTime now;
  final String? qrCodeUrl;
  final double energyLevel;
  final bool isWorldCupEnabled;
  final Animation<double> fadeAnim;
  final Animation<double> idleBreathAnim;
  final Animation<double> orbAnim;
  final Animation<double> idleRadarAnim;

  const RestaurantIdleView({
    super.key,
    required this.effectiveSlides,
    required this.effectiveSuggestions,
    required this.idleSlideIndex,
    required this.settings,
    required this.orgName,
    required this.now,
    required this.qrCodeUrl,
    required this.energyLevel,
    required this.isWorldCupEnabled,
    required this.fadeAnim,
    required this.idleBreathAnim,
    required this.orbAnim,
    required this.idleRadarAnim,
  });

  TextStyle _getFontStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w500,
    double letterSpacing = 0,
    Color color = Colors.white,
    double height = 1.0,
  }) {
    final family = settings?.fontFamily;
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
      height: height,
    );
    if (family != null && family.isNotEmpty) {
      return GoogleFonts.getFont(family, textStyle: base);
    }
    return GoogleFonts.playfairDisplay(textStyle: base);
  }

  @override
  Widget build(BuildContext context) {
    final tvTheme = BusinessTypeTvTheme.of('restaurant');
    return Scaffold(
      backgroundColor: tvTheme.bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final slide = effectiveSlides[idleSlideIndex];
          final accent = tvTheme.primaryAccent;
          final greeting = tvTheme.getGreeting(now);

          final double baseFont = settings?.fontSize ?? 72.0;
          final double orgNameSize = (settings?.idleOrgNameSize ?? baseFont * 0.75) * scale;
          final double headlineSize = (settings?.idleHeadlineSize ?? baseFont * 0.95) * scale;
          final double subtitleSize = (settings?.idleSubtitleSize ?? baseFont * 0.28) * scale;
          final double ctaSize = (settings?.idleCtaSize ?? baseFont * 0.22) * scale;
          final double cardLabelSize = (settings?.idleCardLabelSize ?? baseFont * 0.17) * scale;
          final double cardHintSize = (settings?.idleCardHintSize ?? baseFont * 0.11) * scale;

          final labelStyle = _getFontStyle(
            fontSize: cardLabelSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          );

          return Stack(
            children: [
              RestaurantBackground(box: box, orbAnim: orbAnim),
              ShoutoutTopBar(
                scale: scale,
                businessType: 'restaurant',
                orgName: orgName,
                now: now,
                orbAnim: orbAnim,
              ),
              if (isWorldCupEnabled) WorldCupOverlay(scale: scale),
              Center(
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting.toUpperCase(),
                        style: GoogleFonts.cinzel(
                          fontSize: (settings?.idleGreetingSize ?? baseFont * 0.2) * scale,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 6,
                          color: const Color(0xFFFBBF24).withValues(alpha: 0.8),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      Text(
                        orgName.isNotEmpty ? orgName.toUpperCase() : 'RESTAURANT & DINING',
                        style: _getFontStyle(
                          fontSize: orgNameSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      Text(
                        slide.headline,
                        textAlign: TextAlign.center,
                        style: _getFontStyle(
                          fontSize: headlineSize,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFEF3C7),
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        slide.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 36 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              effectiveSuggestions.length,
                              (i) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10 * scale),
                                child: IdleSuggestionCard(
                                  suggestion: effectiveSuggestions[i],
                                  accent: accent,
                                  scale: scale,
                                  active: i == slide.suggestionIndex,
                                  labelStyle: labelStyle,
                                  hintFontSize: cardHintSize,
                                  cardWidth: settings?.idleCardWidth ?? 190,
                                  cardHeight: settings?.idleCardHeight ?? 130,
                                ),
                              ),
                            ),
                          ),
                          IdleQrCard(
                            qrCodeUrl: qrCodeUrl,
                            scale: scale,
                            tvTheme: tvTheme,
                            radarAnim: idleRadarAnim,
                            customQrSize: settings?.qrCodeSize,
                          ),
                        ],
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        tvTheme.qrPromptCta,
                        style: GoogleFonts.inter(
                          fontSize: ctaSize,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFBBF24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 24 * scale,
                left: 0,
                right: 0,
                child: Center(
                  child: IdleFooter(
                    scale: scale,
                    monoFontSize: (settings?.idleFooterSize ?? baseFont * 0.16) * scale,
                    tvTheme: tvTheme,
                    energyLevel: energyLevel,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
