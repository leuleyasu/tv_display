import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:night_track_tv/core/config/business_type_tv_theme.dart';
import 'package:night_track_tv/core/models/settings_model.dart';
import 'package:night_track_tv/feature/tv_display/domain/models/idle_content.dart';
import 'package:night_track_tv/feature/tv_display/presentation/theme/tv_display_colors.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/backgrounds/nightclub_background.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/floating_particles.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_footer.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_qr_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/idle_suggestion_card.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/shoutout_top_bar.dart';
import 'package:night_track_tv/feature/tv_display/presentation/widget/world_cup_overlay.dart';

/// Specialized High-Energy Nightclub Display View.
class NightclubIdleView extends StatelessWidget {
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

  const NightclubIdleView({
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
    List<Shadow> shadows = const [],
  }) {
    final family = settings?.fontFamily;
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color,
      height: height,
      shadows: shadows,
    );
    if (family != null && family.isNotEmpty) {
      return GoogleFonts.getFont(family, textStyle: base);
    }
    return GoogleFonts.spaceGrotesk(textStyle: base);
  }

  @override
  Widget build(BuildContext context) {
    final tvTheme = BusinessTypeTvTheme.of('nightclub');
    return Scaffold(
      backgroundColor: tvTheme.bgColor,
      body: LayoutBuilder(
        builder: (ctx, box) {
          final double scale = min(box.maxWidth / 1920, box.maxHeight / 1080);
          final slide = effectiveSlides[idleSlideIndex];
          final accent = TvDisplayColors.accentPink;
          final greeting = tvTheme.getGreeting(now);

          final double baseFont = settings?.fontSize ?? 72.0;
          final double orgNameSize = (settings?.idleOrgNameSize ?? baseFont * 0.72) * scale;
          final double headlineSize = (settings?.idleHeadlineSize ?? baseFont * 1.0) * scale;
          final double subtitleSize = (settings?.idleSubtitleSize ?? baseFont * 0.28) * scale;
          final double ctaSize = (settings?.idleCtaSize ?? baseFont * 0.22) * scale;
          final double cardLabelSize = (settings?.idleCardLabelSize ?? baseFont * 0.17) * scale;
          final double cardHintSize = (settings?.idleCardHintSize ?? baseFont * 0.11) * scale;
          final double footerMonoSize = (settings?.idleFooterSize ?? baseFont * 0.16) * scale;
          final double greetingSize = (settings?.idleGreetingSize ?? baseFont * 0.19) * scale;

          final labelStyle = _getFontStyle(
            fontSize: cardLabelSize,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          );

          return Stack(
            children: [
              NightclubBackground(box: box, orbAnim: orbAnim),
              ShoutoutTopBar(
                scale: scale,
                businessType: 'nightclub',
                orgName: orgName,
                now: now,
                orbAnim: orbAnim,
              ),
              if (isWorldCupEnabled) WorldCupOverlay(scale: scale),
              Positioned.fill(
                child: IgnorePointer(
                  child: FloatingParticles(
                    seed: idleSlideIndex + 7,
                    accent: accent,
                  ),
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        greeting,
                        style: GoogleFonts.spaceMono(
                          fontSize: greetingSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 8,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      SizedBox(height: 14 * scale),
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [accent, Colors.white, accent],
                        ).createShader(bounds),
                        child: Text(
                          orgName.isNotEmpty ? orgName.toUpperCase() : 'NIGHTCLUB',
                          style: _getFontStyle(
                            fontSize: orgNameSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                          ),
                        ),
                      ),
                      SizedBox(height: 30 * scale),
                      AnimatedBuilder(
                        animation: Listenable.merge([idleBreathAnim, orbAnim]),
                        builder: (context, _) {
                          final breath = 1.0 + (idleBreathAnim.value - 0.5) * 0.05;
                          return Transform.scale(
                            scale: breath,
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [Colors.white, accent, Colors.white],
                              ).createShader(bounds),
                              child: Text(
                                slide.headline,
                                key: ValueKey('hl_$idleSlideIndex'),
                                textAlign: TextAlign.center,
                                style: _getFontStyle(
                                  fontSize: headlineSize,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 6,
                                  shadows: [
                                    Shadow(
                                      color: accent.withValues(alpha: 0.5),
                                      blurRadius: 40 * scale,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        slide.subtitle,
                        style: _getFontStyle(
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2,
                          color: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                      SizedBox(height: 40 * scale),
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
                      Text(
                        tvTheme.qrPromptCta,
                        style: _getFontStyle(
                          fontSize: ctaSize,
                          letterSpacing: 6,
                          fontWeight: FontWeight.w800,
                          color: accent.withValues(alpha: 0.9),
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
                    monoFontSize: footerMonoSize,
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
